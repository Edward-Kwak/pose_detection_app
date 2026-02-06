import 'package:flutter/material.dart';
import 'package:pose_detection_app/const/const.dart';
import 'package:pose_detection_app/pose_detector_app.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appTitle,
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple), useMaterial3: true),
      home: const PoseDetectorApp(),
    );
  }
}
