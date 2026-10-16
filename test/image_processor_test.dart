import 'dart:ui' show Rect;

import 'package:app/services/image_processor.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

img.Image _blank(int w, int h) {
  final im = img.Image(width: w, height: h);
  for (var y = 0; y < h; y++) {
    for (var x = 0; x < w; x++) {
      im.setPixelRgb(x, y, 0, 0, 0);
    }
  }
  return im;
}

void main() {
  test('square crop pads a tight box by the margin', () {
    final face = ImageProcessor.cropFace(
      _blank(100, 100),
      const Rect.fromLTWH(40, 40, 20, 20),
    );
    expect(face, isNotNull);
    expect(face!.width, 30);
    expect(face.height, 30);
  });

  test('non-square box is squared off the longer side', () {
    final face = ImageProcessor.cropFace(
      _blank(100, 100),
      const Rect.fromLTWH(40, 30, 20, 40),
    );
    expect(face!.width, face.height);
    expect(face.width, 60);
  });

  test('box at the frame edge clamps instead of crashing', () {
    final face = ImageProcessor.cropFace(
      _blank(100, 100),
      const Rect.fromLTWH(0, 0, 20, 20),
    );
    expect(face, isNotNull);
    expect(face!.width, 25);
  });

  test('mirror flips the crop horizontally', () {
    final frame = _blank(100, 100);
    frame.setPixelRgb(38, 50, 255, 255, 255); // left edge of the crop window

    final plain = ImageProcessor.cropFace(
      frame,
      const Rect.fromLTWH(40, 40, 20, 20),
      mirror: false,
    )!;
    final flipped = ImageProcessor.cropFace(
      frame,
      const Rect.fromLTWH(40, 40, 20, 20),
      mirror: true,
    )!;

    expect(plain.getPixel(3, 15).r, 255);
    expect(flipped.getPixel(plain.width - 1 - 3, 15).r, 255);
  });

  test('degenerate box returns null rather than a bad crop', () {
    final face = ImageProcessor.cropFace(
      _blank(100, 100),
      const Rect.fromLTWH(-500, -500, 1, 1),
    );
    expect(face, isNull);
  });

  test('normalization maps the byte range to the documented bounds', () {
    final black = ImageProcessor.toModelInput(_blank(4, 4), size: 4);
    expect(black.first, closeTo(-1.0, 1e-6));

    final white = _blank(4, 4);
    for (var y = 0; y < 4; y++) {
      for (var x = 0; x < 4; x++) {
        white.setPixelRgb(x, y, 255, 255, 255);
      }
    }
    expect(ImageProcessor.toModelInput(white, size: 4).first, closeTo(1.0, 1e-6));
    expect(
      ImageProcessor.toModelInput(white, size: 4, mode: NormalizationMode.unsigned)
          .first,
      closeTo(1.0, 1e-6),
    );
    expect(
      ImageProcessor.toModelInput(_blank(4, 4),
              size: 4, mode: NormalizationMode.unsigned)
          .first,
      closeTo(0.0, 1e-6),
    );
  });

  test('grayscale collapses the channels to BT.601 luma', () {
    final red = _blank(4, 4);
    for (var y = 0; y < 4; y++) {
      for (var x = 0; x < 4; x++) {
        red.setPixelRgb(x, y, 255, 0, 0);
      }
    }

    final gray = ImageProcessor.toModelInput(red, size: 4);
    // 0.299 * 255 = 76.245 -> 76.245 / 127.5 - 1
    expect(gray[0], closeTo(-0.402, 1e-3));
    // All three channels carry the same value.
    expect(gray[1], closeTo(gray[0], 1e-6));
    expect(gray[2], closeTo(gray[0], 1e-6));
  });

  test('rgb mode keeps the channels distinct', () {
    final red = _blank(4, 4);
    for (var y = 0; y < 4; y++) {
      for (var x = 0; x < 4; x++) {
        red.setPixelRgb(x, y, 255, 0, 0);
      }
    }

    final rgb = ImageProcessor.toModelInput(red, size: 4, color: ColorMode.rgb);
    expect(rgb[0], closeTo(1.0, 1e-6)); // red channel saturated
    expect(rgb[1], closeTo(-1.0, 1e-6)); // green empty
    expect(rgb[2], closeTo(-1.0, 1e-6)); // blue empty
  });

  test('ferMatched still yields a full-size grayscale tensor', () {
    final input = ImageProcessor.toModelInput(
      _blank(96, 96),
      size: 8,
      color: ColorMode.ferMatched,
    );
    expect(input.length, 8 * 8 * 3);
    expect(input[0], closeTo(input[1], 1e-6));
  });
}
