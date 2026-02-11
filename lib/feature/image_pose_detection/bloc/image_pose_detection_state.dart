part of 'image_pose_detection_bloc.dart';

sealed class ImagePoseDetectionState extends Equatable {
  const ImagePoseDetectionState();

  @override
  List<Object?> get props => [];
}

final class ImagePoseDetectionInitial extends ImagePoseDetectionState {
  const ImagePoseDetectionInitial();
}

final class ImagePoseDetectionLoaded extends ImagePoseDetectionState {
  const ImagePoseDetectionLoaded({
    required this.imagePath,
    required this.resultText,
  });

  final String imagePath;
  final String resultText;

  @override
  List<Object?> get props => [imagePath, resultText];
}
