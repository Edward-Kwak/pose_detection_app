part of 'image_pose_detection_bloc.dart';

sealed class ImagePoseDetectionEvent extends Equatable {
  const ImagePoseDetectionEvent();

  @override
  List<Object?> get props => [];
}

final class ImagePoseDetectionPickRequested extends ImagePoseDetectionEvent {
  const ImagePoseDetectionPickRequested();
}

final class ImagePoseDetectionResetRequested extends ImagePoseDetectionEvent {
  const ImagePoseDetectionResetRequested();
}
