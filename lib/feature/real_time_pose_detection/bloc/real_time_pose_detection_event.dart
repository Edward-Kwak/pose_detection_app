part of 'real_time_pose_detection_bloc.dart';

sealed class RealTimePoseDetectionEvent extends Equatable {
  const RealTimePoseDetectionEvent();

  @override
  List<Object?> get props => [];
}

final class RealTimePoseDetectionFrameReceived extends RealTimePoseDetectionEvent {
  const RealTimePoseDetectionFrameReceived({
    required this.inputImage,
    required this.cameraLensDirection,
  });

  final InputImage inputImage;
  final CameraLensDirection cameraLensDirection;

  @override
  List<Object?> get props => [inputImage, cameraLensDirection];
}

final class RealTimePoseDetectionCameraInitialized extends RealTimePoseDetectionEvent {
  const RealTimePoseDetectionCameraInitialized({
    required this.minZoom,
    required this.maxZoom,
  });

  final double minZoom;
  final double maxZoom;

  @override
  List<Object?> get props => [minZoom, maxZoom];
}

final class RealTimePoseDetectionCameraStopped extends RealTimePoseDetectionEvent {
  const RealTimePoseDetectionCameraStopped();
}

final class RealTimePoseDetectionZoomChanged extends RealTimePoseDetectionEvent {
  const RealTimePoseDetectionZoomChanged({required this.zoomLevel});

  final double zoomLevel;

  @override
  List<Object?> get props => [zoomLevel];
}

final class RealTimePoseDetectionLensSwitchStarted extends RealTimePoseDetectionEvent {
  const RealTimePoseDetectionLensSwitchStarted();
}

final class RealTimePoseDetectionLensSwitchCompleted extends RealTimePoseDetectionEvent {
  const RealTimePoseDetectionLensSwitchCompleted({
    required this.minZoom,
    required this.maxZoom,
  });

  final double minZoom;
  final double maxZoom;

  @override
  List<Object?> get props => [minZoom, maxZoom];
}
