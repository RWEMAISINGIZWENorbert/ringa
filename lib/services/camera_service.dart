import 'package:camera/camera.dart';

class CameraService {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];

  CameraController? get controller => _controller;

  Future<void> initialize({bool useFrontCamera = false}) async {
    _cameras = await availableCameras();

    final selectedCamera = _cameras.firstWhere(
      (cam) => useFrontCamera
          ? cam.lensDirection == CameraLensDirection.front
          : cam.lensDirection == CameraLensDirection.back,
      orElse: () => _cameras.first,
    );

    _controller = CameraController(
      selectedCamera,
      ResolutionPreset.medium, // good balance of speed vs accuracy
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.nv21, // required for ML Kit on Android
    );

    await _controller!.initialize();
  }

  void startImageStream(Function(CameraImage image) onImage) {
    _controller?.startImageStream(onImage);
  }

  Future<void> stopImageStream() async {
    if (_controller?.value.isStreamingImages ?? false) {
      await _controller?.stopImageStream();
    }
  }

  void dispose() {
    _controller?.dispose();
  }

  CameraDescription? get activeCameraDescription => _controller?.description;
}