part of 'real_time_pose_detection_bloc.dart';

class RealTimePoseDetectionState extends Equatable {
  const RealTimePoseDetectionState({
    this.isCameraInitialized = false,
    this.changingCameraLens = false,
    this.currentZoomLevel = 1.0,
    this.minAvailableZoom = 1.0,
    this.maxAvailableZoom = 1.0,
    this.poses,
    this.imageSize,
    this.rotation,
    this.cameraLensDirection,
  });

  final bool isCameraInitialized;
  final bool changingCameraLens;
  final double currentZoomLevel;
  final double minAvailableZoom;
  final double maxAvailableZoom;
  final List<Pose>? poses;
  final Size? imageSize;
  final InputImageRotation? rotation;
  final CameraLensDirection? cameraLensDirection;

  RealTimePoseDetectionState copyWith({
    bool? isCameraInitialized,
    bool? changingCameraLens,
    double? currentZoomLevel,
    double? minAvailableZoom,
    double? maxAvailableZoom,
    List<Pose>? poses,
    Size? imageSize,
    InputImageRotation? rotation,
    CameraLensDirection? cameraLensDirection,
  }) {
    return RealTimePoseDetectionState(
      isCameraInitialized: isCameraInitialized ?? this.isCameraInitialized,
      changingCameraLens: changingCameraLens ?? this.changingCameraLens,
      currentZoomLevel: currentZoomLevel ?? this.currentZoomLevel,
      minAvailableZoom: minAvailableZoom ?? this.minAvailableZoom,
      maxAvailableZoom: maxAvailableZoom ?? this.maxAvailableZoom,
      poses: poses ?? this.poses,
      imageSize: imageSize ?? this.imageSize,
      rotation: rotation ?? this.rotation,
      cameraLensDirection: cameraLensDirection ?? this.cameraLensDirection,
    );
  }

  @override
  List<Object?> get props => [
    isCameraInitialized,
    changingCameraLens,
    currentZoomLevel,
    minAvailableZoom,
    maxAvailableZoom,
    poses,
    imageSize,
    rotation,
    cameraLensDirection,
  ];
}
