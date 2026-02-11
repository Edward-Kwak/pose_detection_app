import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

part 'real_time_pose_detection_event.dart';
part 'real_time_pose_detection_state.dart';

class RealTimePoseDetectionBloc extends Bloc<RealTimePoseDetectionEvent, RealTimePoseDetectionState> {
  RealTimePoseDetectionBloc() : super(const RealTimePoseDetectionState()) {
    on<RealTimePoseDetectionFrameReceived>(_onFrameReceived);
    on<RealTimePoseDetectionCameraInitialized>(_onCameraInitialized);
    on<RealTimePoseDetectionCameraStopped>(_onCameraStopped);
    on<RealTimePoseDetectionZoomChanged>(_onZoomChanged);
    on<RealTimePoseDetectionLensSwitchStarted>(_onLensSwitchStarted);
    on<RealTimePoseDetectionLensSwitchCompleted>(_onLensSwitchCompleted);
  }

  final PoseDetector _poseDetector = PoseDetector(
    options: PoseDetectorOptions(
      mode: PoseDetectionMode.stream,
      model: PoseDetectionModel.accurate,
    ),
  );

  bool _isProcessing = false;

  Future<void> _onFrameReceived(
    RealTimePoseDetectionFrameReceived event,
    Emitter<RealTimePoseDetectionState> emit,
  ) async {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      final poses = await _poseDetector.processImage(event.inputImage);
      final metadata = event.inputImage.metadata;

      if (metadata?.size != null && metadata?.rotation != null) {
        emit(state.copyWith(
          poses: poses,
          imageSize: metadata!.size,
          rotation: metadata.rotation,
          cameraLensDirection: event.cameraLensDirection,
        ));
      }
    } finally {
      _isProcessing = false;
    }
  }

  void _onCameraInitialized(
    RealTimePoseDetectionCameraInitialized event,
    Emitter<RealTimePoseDetectionState> emit,
  ) {
    emit(state.copyWith(
      isCameraInitialized: true,
      currentZoomLevel: event.minZoom,
      minAvailableZoom: event.minZoom,
      maxAvailableZoom: event.maxZoom,
    ));
  }

  void _onCameraStopped(
    RealTimePoseDetectionCameraStopped event,
    Emitter<RealTimePoseDetectionState> emit,
  ) {
    emit(state.copyWith(isCameraInitialized: false));
  }

  void _onZoomChanged(
    RealTimePoseDetectionZoomChanged event,
    Emitter<RealTimePoseDetectionState> emit,
  ) {
    emit(state.copyWith(currentZoomLevel: event.zoomLevel));
  }

  void _onLensSwitchStarted(
    RealTimePoseDetectionLensSwitchStarted event,
    Emitter<RealTimePoseDetectionState> emit,
  ) {
    emit(state.copyWith(changingCameraLens: true));
  }

  void _onLensSwitchCompleted(
    RealTimePoseDetectionLensSwitchCompleted event,
    Emitter<RealTimePoseDetectionState> emit,
  ) {
    emit(state.copyWith(
      changingCameraLens: false,
      isCameraInitialized: true,
      currentZoomLevel: event.minZoom,
      minAvailableZoom: event.minZoom,
      maxAvailableZoom: event.maxZoom,
    ));
  }

  @override
  Future<void> close() {
    _poseDetector.close();
    return super.close();
  }
}
