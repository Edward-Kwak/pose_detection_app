import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:pose_detection_app/feature/real_time_pose_detection/bloc/real_time_pose_detection_bloc.dart';
import 'package:pose_detection_app/utils/pose_painter_util.dart';
import 'package:pose_detection_app/widget/active_tab_index.dart';

class RealTimePoseDetectionScreen extends StatefulWidget {
  const RealTimePoseDetectionScreen({super.key});

  @override
  State<RealTimePoseDetectionScreen> createState() => _RealTimePoseDetectionScreenState();
}

class _RealTimePoseDetectionScreenState extends State<RealTimePoseDetectionScreen> with WidgetsBindingObserver {
  static List<CameraDescription> _cameras = [];
  CameraController? _controller;
  int _cameraIndex = -1;
  bool _isCameraRunning = false;
  bool _isInitializing = false;

  final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final isActive = ActiveTabIndex.of(context) == 1;
    if (isActive) {
      _startCameraIfNeeded();
    } else {
      _stopCameraIfRunning();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
        _stopCameraIfRunning();
      case AppLifecycleState.resumed:
        if (ActiveTabIndex.of(context) == 1) {
          _startCameraIfNeeded();
        }
      default:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stopLiveFeed();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RealTimePoseDetectionBloc, RealTimePoseDetectionState>(
      buildWhen:
          (prev, curr) =>
              prev.isCameraInitialized != curr.isCameraInitialized || prev.changingCameraLens != curr.changingCameraLens,
      builder: (context, state) {
        if (_cameras.isEmpty || _controller == null || !state.isCameraInitialized) {
          return Container();
        }

        return Container(
          color: Colors.black,
          child: Stack(
            fit: StackFit.expand,
            children: <Widget>[
              Center(
                child: switch (state.changingCameraLens) {
                  true => const Center(child: Text('Changing camera lens')),
                  false => _cameraPreviewWithPose(),
                },
              ),
              _switchLiveCameraToggle(),
              _zoomControl(),
            ],
          ),
        );
      },
    );
  }

  Future<void> _startCameraIfNeeded() async {
    if (_isCameraRunning || _isInitializing) return;
    _isInitializing = true;
    try {
      if (_cameras.isEmpty) {
        _cameras = await availableCameras();
      }
      if (_cameraIndex == -1) {
        for (var i = 0; i < _cameras.length; i++) {
          if (_cameras[i].lensDirection == CameraLensDirection.back) {
            _cameraIndex = i;
            break;
          }
        }
      }
      if (_cameraIndex != -1) {
        await _startLiveFeed();
        _isCameraRunning = true;
      }
    } finally {
      _isInitializing = false;
    }
  }

  Future<void> _stopCameraIfRunning() async {
    if (!_isCameraRunning) return;

    _isCameraRunning = false;
    if (mounted) {
      context.read<RealTimePoseDetectionBloc>().add(const RealTimePoseDetectionCameraStopped());
    }
    await _stopLiveFeed();
  }

  Future<void> _startLiveFeed() async {
    final camera = _cameras[_cameraIndex];
    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888,
    );
    await _controller?.initialize();
    if (!mounted) return;

    final minZoom = await _controller?.getMinZoomLevel() ?? 1.0;
    final maxZoom = await _controller?.getMaxZoomLevel() ?? 1.0;

    _controller?.startImageStream(_processCameraImage);
    if (mounted) {
      context.read<RealTimePoseDetectionBloc>().add(RealTimePoseDetectionCameraInitialized(minZoom: minZoom, maxZoom: maxZoom));
    }
  }

  Widget _cameraPreviewWithPose() {
    return BlocBuilder<RealTimePoseDetectionBloc, RealTimePoseDetectionState>(
      buildWhen: (prev, curr) => prev.poses != curr.poses,
      builder: (context, state) {
        if (_controller == null) return const SizedBox.shrink();

        CustomPaint? customPaint;
        if (state.poses != null && state.imageSize != null && state.rotation != null && state.cameraLensDirection != null) {
          customPaint = CustomPaint(
            painter: PosePainter(state.poses!, state.imageSize!, state.rotation!, state.cameraLensDirection!),
          );
        }

        return CameraPreview(_controller!, child: customPaint);
      },
    );
  }

  Widget _switchLiveCameraToggle() => Positioned(
    bottom: 16,
    right: 16,
    child: SizedBox(
      height: 50.0,
      width: 50.0,
      child: FloatingActionButton(
        heroTag: Object(),
        onPressed: _switchLiveCamera,
        child: Icon(Platform.isIOS ? Icons.flip_camera_ios_outlined : Icons.flip_camera_android_outlined, size: 25),
      ),
    ),
  );

  Widget _zoomControl() => BlocBuilder<RealTimePoseDetectionBloc, RealTimePoseDetectionState>(
    buildWhen:
        (prev, curr) =>
            prev.currentZoomLevel != curr.currentZoomLevel ||
            prev.minAvailableZoom != curr.minAvailableZoom ||
            prev.maxAvailableZoom != curr.maxAvailableZoom,
    builder: (context, state) {
      return Positioned(
        bottom: 16,
        left: 0,
        right: 0,
        child: Align(
          alignment: Alignment.bottomCenter,
          child: SizedBox(
            width: 250,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Slider(
                    value: state.currentZoomLevel,
                    min: state.minAvailableZoom,
                    max: state.maxAvailableZoom,
                    activeColor: Colors.white,
                    inactiveColor: Colors.white30,
                    onChanged: (value) async {
                      context.read<RealTimePoseDetectionBloc>().add(RealTimePoseDetectionZoomChanged(zoomLevel: value));
                      await _controller?.setZoomLevel(value);
                    },
                  ),
                ),
                Container(
                  width: 50,
                  decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(10.0)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                      child: Text('${state.currentZoomLevel.toStringAsFixed(1)}x', style: const TextStyle(color: Colors.white)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );

  void _processCameraImage(CameraImage image) {
    final inputImage = _inputImageFromCameraImage(image);
    if (inputImage == null) return;

    context.read<RealTimePoseDetectionBloc>().add(
      RealTimePoseDetectionFrameReceived(inputImage: inputImage, cameraLensDirection: _cameras[_cameraIndex].lensDirection),
    );
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (_controller == null) return null;

    final camera = _cameras[_cameraIndex];
    final sensorOrientation = camera.sensorOrientation;

    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation = _orientations[_controller!.value.deviceOrientation];
      if (rotationCompensation == null) return null;
      if (camera.lensDirection == CameraLensDirection.front) {
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        rotationCompensation = (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    }

    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null ||
        (Platform.isAndroid && format != InputImageFormat.nv21) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888)) {
      return null;
    }

    if (image.planes.length != 1) return null;

    final plane = image.planes.first;

    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }

  Future<void> _switchLiveCamera() async {
    context.read<RealTimePoseDetectionBloc>().add(const RealTimePoseDetectionLensSwitchStarted());

    _cameraIndex = (_cameraIndex + 1) % _cameras.length;
    _isCameraRunning = false;
    await _stopLiveFeed();
    await _startLiveFeedForSwitch();

    _isCameraRunning = true;
  }

  Future<void> _startLiveFeedForSwitch() async {
    final camera = _cameras[_cameraIndex];
    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid ? ImageFormatGroup.nv21 : ImageFormatGroup.bgra8888,
    );
    await _controller?.initialize();
    if (!mounted) return;

    final minZoom = await _controller?.getMinZoomLevel() ?? 1.0;
    final maxZoom = await _controller?.getMaxZoomLevel() ?? 1.0;

    _controller?.startImageStream(_processCameraImage);
    if (mounted) {
      context.read<RealTimePoseDetectionBloc>().add(
        RealTimePoseDetectionLensSwitchCompleted(minZoom: minZoom, maxZoom: maxZoom),
      );
    }
  }

  Future<void> _stopLiveFeed() async {
    final controller = _controller;
    _controller = null;
    await controller?.stopImageStream();
    await controller?.dispose();
  }
}
