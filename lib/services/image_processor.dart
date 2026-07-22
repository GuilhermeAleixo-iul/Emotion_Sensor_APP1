import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' show Rect, Size;

import 'package:camera/camera.dart';
import 'package:flutter/services.dart' show DeviceOrientation;
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as img;

/// How pixel values are mapped before being handed to the TFLite model.
enum NormalizationMode {
  // `x / 127.5 - 1` -> [-1, 1]. Teachable Machine / MobileNet convention.
  signed,

  // `x / 255` -> [0, 1].
  unsigned,
}

enum ColorMode {
  rgb,
  grayscale,
  ferMatched,
}

class ImageProcessor {
  const ImageProcessor._();

  static const int inputSize = 224;

  //Native resolution of FER-2013, used by ColorMode.ferMatched.
  static const int ferSourceSize = 48;

  //Resizes and normalizes the given image to a Float32List suitable for input to the TFLite model.
  static Float32List toModelInput(
    img.Image image, {
    int size = inputSize,
    NormalizationMode mode = NormalizationMode.signed,
    ColorMode color = ColorMode.grayscale,
  }) {
    var work = image;
    if (color == ColorMode.ferMatched) {
      //Area averaging on the way down, which is what avoids aliasing when
      //throwing away this much resolution.
      work = img.copyResize(
        work,
        width: ferSourceSize,
        height: ferSourceSize,
        interpolation: img.Interpolation.average,
      );
    }

    //Bilinear, not the package default of nearest. Nearest aliases badly and
    //nothing in the training pipeline resized that way.
    final resized = (work.width == size && work.height == size)
        ? work
        : img.copyResize(
            work,
            width: size,
            height: size,
            interpolation: img.Interpolation.linear,
          );

    final bytes = resized.getBytes(order: img.ChannelOrder.rgb);

    final length = size * size * 3;
    if (bytes.length != length) {
      throw StateError(
        'Expected $length RGB bytes for ${size}x$size, got ${bytes.length}',
      );
    }

    final double scale = mode == NormalizationMode.signed ? 1 / 127.5 : 1 / 255.0;
    final double offset = mode == NormalizationMode.signed ? -1.0 : 0.0;

    final input = Float32List(length);
    if (color == ColorMode.rgb) {
      for (int i = 0; i < length; i++) {
        input[i] = bytes[i] * scale + offset;
      }
    } else {
      //ITU-R BT.601 luma - the standard weighting, and what FER-2013 itself
      //was grayscaled with. Replicated across all three channels because the
      //model still expects a 3-channel input.
      for (int i = 0; i < length; i += 3) {
        final luma =
            0.299 * bytes[i] + 0.587 * bytes[i + 1] + 0.114 * bytes[i + 2];
        final value = luma * scale + offset;
        input[i] = value;
        input[i + 1] = value;
        input[i + 2] = value;
      }
    }
    return input;
  }

  static const Map<DeviceOrientation, int> _deviceRotation = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  //Clockwise degrees the sensor buffer must be turned to sit upright.
  static int rotationDegreesFor(
    CameraDescription camera,
    DeviceOrientation deviceOrientation,
  ) {
    final compensation = _deviceRotation[deviceOrientation] ?? 0;
    if (camera.lensDirection == CameraLensDirection.front) {
      return (camera.sensorOrientation + compensation) % 360;
    }
    return (camera.sensorOrientation - compensation + 360) % 360;
  }

  //Packs a frame into tightly-stridden NV21: Y rows, then V/U interleaved.
  //
  //camera_android_camerax ignores ImageFormatGroup.nv21 and always hands back
  //3-plane YUV420, and ML Kit's fromByteBuffer only accepts NV21/YV12 - so the
  //repack has to happen here. A device that really does deliver NV21 arrives
  //as a single plane and is passed straight through.
  static Uint8List yuv420ToNv21(CameraImage image) {
    if (image.planes.length == 1) return image.planes.first.bytes;
    if (image.planes.length != 3) {
      throw StateError('Expected 1 or 3 planes, got ${image.planes.length}');
    }

    final width = image.width;
    final height = image.height;
    final yPlane = image.planes[0];
    final uPlane = image.planes[1];
    final vPlane = image.planes[2];

    final out = Uint8List(width * height + width * height ~/ 2);

    //Copy Y row by row so any row padding is dropped.
    var offset = 0;
    for (int row = 0; row < height; row++) {
      final start = row * yPlane.bytesPerRow;
      out.setRange(offset, offset + width, yPlane.bytes, start);
      offset += width;
    }

    //Chroma is quarter resolution; pixelStride is 2 when the planes are
    //already semi-planar and 1 when they are fully planar.
    final uvRowStride = uPlane.bytesPerRow;
    final uvPixelStride = uPlane.bytesPerPixel ?? 1;
    for (int row = 0; row < height ~/ 2; row++) {
      for (int col = 0; col < width ~/ 2; col++) {
        final index = row * uvRowStride + col * uvPixelStride;
        out[offset++] = vPlane.bytes[index]; //NV21 stores V before U
        out[offset++] = uPlane.bytes[index];
      }
    }
    return out;
  }

  //Boxes come back already rotated, in the upright coordinate space.
  static InputImage? inputImageFromNv21(
    Uint8List nv21,
    int width,
    int height,
    int rotationDegrees,
  ) {
    final rotation = InputImageRotationValue.fromRawValue(rotationDegrees);
    if (rotation == null) return null;
    return InputImage.fromBytes(
      bytes: nv21,
      metadata: InputImageMetadata(
        size: Size(width.toDouble(), height.toDouble()),
        rotation: rotation,
        format: InputImageFormat.nv21,
        bytesPerRow: width,
      ),
    );
  }

  //Takes the packed buffer from [yuv420ToNv21] so the frame is only
  //deinterleaved once and both ML Kit and the crop read the same bytes.
  static img.Image nv21ToRgb(Uint8List nv21, int width, int height) {
    final uvStart = width * height;

    final out = img.Image(width: width, height: height);
    for (int y = 0; y < height; y++) {
      final yRow = y * width;
      final uvRow = uvStart + (y >> 1) * width;
      for (int x = 0; x < width; x++) {
        final luma = nv21[yRow + x];
        final uvIndex = uvRow + (x >> 1) * 2;
        final v = nv21[uvIndex] - 128;
        final u = nv21[uvIndex + 1] - 128;

        out.setPixelRgb(
          x,
          y,
          (luma + 1.402 * v).round().clamp(0, 255),
          (luma - 0.344136 * u - 0.714136 * v).round().clamp(0, 255),
          (luma + 1.772 * u).round().clamp(0, 255),
        );
      }
    }
    return out;
  }

  //Must use the same degrees passed to ML Kit so box coordinates line up.
  static img.Image orientUpright(img.Image frame, int rotationDegrees) {
    if (rotationDegrees % 360 == 0) return frame;
    return img.copyRotate(frame, angle: rotationDegrees);
  }

  static Face? largestFace(List<Face> faces) {
    if (faces.isEmpty) return null;
    return faces.reduce((a, b) {
      final areaA = a.boundingBox.width * a.boundingBox.height;
      final areaB = b.boundingBox.width * b.boundingBox.height;
      return areaA >= areaB ? a : b;
    });
  }

  //Pads the tight ML Kit box out to FER-style framing, then crops it square.
  static Rect? cropRect(
    Rect box,
    int imageWidth,
    int imageHeight, {
    double margin = 0.25,
    bool square = true,
  }) {
    var halfWidth = box.width * (0.5 + margin);
    var halfHeight = box.height * (0.5 + margin);
    if (square) {
      final half = math.max(halfWidth, halfHeight);
      halfWidth = half;
      halfHeight = half;
    }

    final left = (box.center.dx - halfWidth).round().clamp(0, imageWidth - 1);
    final top = (box.center.dy - halfHeight).round().clamp(0, imageHeight - 1);
    final right =
        (box.center.dx + halfWidth).round().clamp(left + 1, imageWidth);
    final bottom =
        (box.center.dy + halfHeight).round().clamp(top + 1, imageHeight);

    if (right - left < 2 || bottom - top < 2) return null;
    return Rect.fromLTRB(
      left.toDouble(),
      top.toDouble(),
      right.toDouble(),
      bottom.toDouble(),
    );
  }

  static img.Image? cropFace(
    img.Image upright,
    Rect box, {
    double margin = 0.25,
    bool square = true,
    bool mirror = false,
  }) {
    final rect = cropRect(
      box,
      upright.width,
      upright.height,
      margin: margin,
      square: square,
    );
    if (rect == null) return null;

    final face = img.copyCrop(
      upright,
      x: rect.left.toInt(),
      y: rect.top.toInt(),
      width: rect.width.toInt(),
      height: rect.height.toInt(),
    );
    return mirror ? img.flipHorizontal(face) : face;
  }
}
