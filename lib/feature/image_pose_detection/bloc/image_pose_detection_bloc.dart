import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:image_picker/image_picker.dart';

part 'image_pose_detection_event.dart';

part 'image_pose_detection_state.dart';

class ImagePoseDetectionBloc extends Bloc<ImagePoseDetectionEvent, ImagePoseDetectionState> {
  ImagePoseDetectionBloc() : super(const ImagePoseDetectionInitial()) {
    on<ImagePoseDetectionPickRequested>(_onPickRequested);
    on<ImagePoseDetectionResetRequested>(_onResetRequested);
  }

  final ImagePicker _imagePicker = ImagePicker();
  final PoseDetector _poseDetector = PoseDetector(
    options: PoseDetectorOptions(mode: PoseDetectionMode.single, model: PoseDetectionModel.accurate),
  );

  Future<void> _onPickRequested(ImagePoseDetectionPickRequested event, Emitter<ImagePoseDetectionState> emit) async {
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final inputImage = InputImage.fromFilePath(pickedFile.path);
    final poses = await _poseDetector.processImage(inputImage);

    emit(ImagePoseDetectionLoaded(imagePath: pickedFile.path, resultText: 'Detected Poses: ${poses.length}'));
  }

  void _onResetRequested(ImagePoseDetectionResetRequested event, Emitter<ImagePoseDetectionState> emit) {
    emit(const ImagePoseDetectionInitial());
  }

  @override
  Future<void> close() {
    _poseDetector.close();
    return super.close();
  }
}
