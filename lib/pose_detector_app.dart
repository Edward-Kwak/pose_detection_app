import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pose_detection_app/const/const.dart';
import 'package:pose_detection_app/features/image_pose_detection/presentation/image_pose_detection_view.dart';
import 'package:pose_detection_app/utils/pose_painter_util.dart';

class PoseDetectorApp extends StatefulWidget {
  const PoseDetectorApp({super.key});

  @override
  State<PoseDetectorApp> createState() => _PoseDetectorAppState();
}

class _PoseDetectorAppState extends State<PoseDetectorApp> {
  File? _image;
  ImagePicker imagePicker = ImagePicker();
  String? resultText;
  final PoseDetector poseDetector = PoseDetector(
    options: PoseDetectorOptions(mode: PoseDetectionMode.stream, model: PoseDetectionModel.accurate),
  );

  CustomPaint? customPaint;

  @override
  void dispose() {
    poseDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(appTitle)),
      body: ImagePoseDetectionView(image: _image, resultText: resultText, onPressGetImageBtn: _getImage),
    );
  }

  Future _getImage(ImageSource source) async {
    setState(() => _image = null);

    final pickedFile = await imagePicker.pickImage(source: source);
    if (pickedFile != null) {
      _processFile(pickedFile.path);
      return;
    }
  }

  Future _processFile(String path) async {
    setState(() => _image = File(path));

    final inputImage = InputImage.fromFilePath(path);
    _processImage(inputImage);
  }

  Future<void> _processImage(InputImage inputImage) async {
    setState(() => resultText = '');
    final poses = await poseDetector.processImage(inputImage);

    if (inputImage.metadata?.size != null && inputImage.metadata?.rotation != null) {
      final painter = PosePainter(poses, inputImage.metadata!.size, inputImage.metadata!.rotation, CameraLensDirection.back);
      setState(() => customPaint = CustomPaint(painter: painter));
    } else {
      resultText = 'Detected Poses: ${poses.length}';
      setState(() {});
    }
  }
}
