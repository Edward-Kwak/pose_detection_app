import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pose_detection_app/feature/image_pose_detection/bloc/image_pose_detection_bloc.dart';

class ImagePoseDetectionScreen extends StatelessWidget {
  const ImagePoseDetectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ImagePoseDetectionBloc, ImagePoseDetectionState>(
      buildWhen: (prev, curr) => curr is ImagePoseDetectionLoaded || curr is ImagePoseDetectionInitial,
      builder: (context, state) {
        return Column(
          children: [
            switch (state) {
              ImagePoseDetectionLoaded(:final imagePath) => SizedBox(
                height: 400,
                child: Center(child: Image.file(File(imagePath))),
              ),
              _ => Container(
                height: 200,
                margin: const EdgeInsets.all(32),
                decoration: BoxDecoration(border: Border.all()),
                child: const Center(child: Text('자세 인식할 사진을 불러와 주세요.')),
              ),
            },
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.read<ImagePoseDetectionBloc>().add(const ImagePoseDetectionPickRequested()),
              child: const Text('갤러리에서 이미지 가져오기'),
            ),
            const SizedBox(height: 16),
            if (state is ImagePoseDetectionLoaded) Expanded(child: SingleChildScrollView(child: Text(state.resultText))),
          ],
        );
      },
    );
  }
}
