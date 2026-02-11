import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePoseDetectionView extends StatelessWidget {
  const ImagePoseDetectionView({super.key, required this.onPressGetImageBtn, this.image, this.resultText});

  final File? image;
  final String? resultText;
  final Function(ImageSource source) onPressGetImageBtn;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        image != null
            ? SizedBox(height: 400, child: Center(child: Image.file(image!)))
            : Container(
              height: 200,
              margin: EdgeInsets.all(32),
              decoration: BoxDecoration(border: Border.all()),
              child: Center(child: Text('자세 인식할 사진을 불러와 주세요.')),
            ),
        SizedBox(height: 16),
        ElevatedButton(onPressed: () => onPressGetImageBtn(ImageSource.gallery), child: Text('갤러리에서 이미지 가져오기')),
        SizedBox(height: 16),
        image != null ? Expanded(child: SingleChildScrollView(child: Text(resultText ?? ''))) : SizedBox.shrink(),
      ],
    );
  }
}
