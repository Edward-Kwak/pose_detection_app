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

    final leftPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0
          ..color = Colors.lightGreenAccent;

    final rightPaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0
          ..color = Colors.blueAccent;

    final bridgePaint =
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0
          ..color = Colors.redAccent;

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

      paintLine(PoseLandmarkType type1, PoseLandmarkType type2, Paint paintType) {
        final PoseLandmark joint1 = pose.landmarks[type1]!;
        final PoseLandmark joint2 = pose.landmarks[type2]!;

        canvas.drawLine(
          Offset(
            translateX(joint1.x, size, imageSize, rotation, cameraLensDirection),
            translateY(joint1.y, size, imageSize, rotation, cameraLensDirection),
          ),
          Offset(
            translateX(joint2.x, size, imageSize, rotation, cameraLensDirection),
            translateY(joint2.y, size, imageSize, rotation, cameraLensDirection),
          ),
          paintType,
        );
      }

      paintLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow, leftPaint);
      paintLine(PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist, leftPaint);

      paintLine(PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee, leftPaint);
      paintLine(PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle, leftPaint);

      paintLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow, rightPaint);
      paintLine(PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist, rightPaint);

      paintLine(PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee, rightPaint);
      paintLine(PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle, rightPaint);

      paintLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder, bridgePaint);
      paintLine(PoseLandmarkType.leftHip, PoseLandmarkType.rightHip, bridgePaint);
      paintLine(PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip, bridgePaint);
      paintLine(PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip, bridgePaint);
    }
  }

  @override
  bool shouldRepaint(covariant PosePainter oldDelegate) {
    return oldDelegate.imageSize != imageSize || oldDelegate.poses != poses;
  }
}
