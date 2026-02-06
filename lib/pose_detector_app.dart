import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pose_detection_app/const/const.dart';

class PoseDetectorApp extends StatefulWidget {
  const PoseDetectorApp({super.key});

  @override
  State<PoseDetectorApp> createState() => _PoseDetectorAppState();
}

class _PoseDetectorAppState extends State<PoseDetectorApp> {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(appTitle), actions: [IconButton(onPressed: () {}, icon: const Icon(Icons.refresh))]),
      body: Container(),
    );
  }

  Future _getImage(ImageSource source) async {}

  Future _processFile(String path) async {}

  Future<void> _processImage(InputImage inputImage) async {}
}
