import 'dart:ui' as ui;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:pose_detection_app/utils/translate_util.dart';

class PosePainter extends CustomPainter {
  PosePainter(this.poses, this.imageSize, this.rotation, this.cameraLensDirection);

  final List<Pose> poses;
  final Size imageSize;
  final InputImageRotation rotation;
  final CameraLensDirection cameraLensDirection;

  @override
  void paint(Canvas canvas, Size size) {
    final jointPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 4.0
          ..color = Colors.red;

    for (final pose in poses) {
      pose.landmarks.forEach((key, value) {
        canvas.drawCircle(
          Offset(
            translateX(value.x, size, imageSize, rotation, cameraLensDirection),
            translateY(value.y, size, imageSize, rotation, cameraLensDirection),
          ),
          1,
          jointPaint,
        );
      });
    }
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    return oldDelegate.imageSize != imageSize || oldDelegate.poses != poses;
  }
}
