import 'package:flutter/material.dart';

//Draws the detector output over the camera preview.
//
//Green is the tight box ML Kit returned. Amber is the padded square region
//that actually gets cropped and fed to the model - if that one is cutting off
//the chin or including too much background, tune `margin` in cropFace().
class FaceBoxPainter extends CustomPainter {
  const FaceBoxPainter({
    required this.faceBox,
    required this.imageSize,
    this.cropBox,
    this.mirror = true,
  });

  //Both rects are in upright-image coordinates, not widget coordinates.
  final Rect faceBox;
  final Rect? cropBox;

  //Size of the upright (post-rotation) frame the boxes were measured against.
  final Size imageSize;

  //Detection runs on the raw, unmirrored buffer while the front camera preview
  //is displayed mirrored, so the boxes need flipping to line up. If the box
  //tracks the opposite way to your face, set this to false.
  final bool mirror;

  @override
  void paint(Canvas canvas, Size size) {
    if (imageSize.isEmpty) return;

    final scaleX = size.width / imageSize.width;
    final scaleY = size.height / imageSize.height;

    Rect toWidget(Rect rect) {
      var left = rect.left * scaleX;
      var right = rect.right * scaleX;
      if (mirror) {
        final flipped = size.width - right;
        right = size.width - left;
        left = flipped;
      }
      return Rect.fromLTRB(left, rect.top * scaleY, right, rect.bottom * scaleY);
    }

    if (cropBox != null) {
      canvas.drawRect(
        toWidget(cropBox!),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = Colors.amber,
      );
    }

    canvas.drawRect(
      toWidget(faceBox),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = Colors.greenAccent,
    );
  }

  @override
  bool shouldRepaint(FaceBoxPainter old) =>
      old.faceBox != faceBox ||
      old.cropBox != cropBox ||
      old.imageSize != imageSize ||
      old.mirror != mirror;
}
