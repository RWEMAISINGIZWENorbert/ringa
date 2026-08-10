import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:ringa/services/camera_service.dart';
import 'package:ringa/services/pose_detector_service.dart';
import 'package:ringa/widgets/loading_indicator.dart';
import 'package:ringa/widgets/pose_overlay_painter.dart';


class PushupCounterScreen extends StatefulWidget {
  const PushupCounterScreen({super.key});

  @override
  State<PushupCounterScreen> createState() => _PushupCounterScreenState();
}

class _PushupCounterScreenState extends State<PushupCounterScreen> {
  final CameraService _cameraService = CameraService();
  final PoseDetectorService _poseDetectorService = PoseDetectorService();

  Pose? _currentPose;
  Size? _imageSize;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _cameraService.initialize(useFrontCamera: true);
    setState(() {}); // rebuild once controller is ready

    _cameraService.startImageStream((CameraImage image) async {
      final camera = _cameraService.activeCameraDescription;
      if (camera == null) return;

      _imageSize = Size(image.width.toDouble(), image.height.toDouble());

      final pose = await _poseDetectorService.processImage(image, camera);
      if (pose != null && mounted) {
        setState(() => _currentPose = pose);
      }
    });
  }

  @override
  void dispose() {
    _cameraService.stopImageStream();
    _cameraService.dispose();
    _poseDetectorService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _cameraService.controller;

    if (controller == null || !controller.value.isInitialized) {
      return const Scaffold(body: Center(child: LoadingIndicator()));
    }

    return Scaffold(
    backgroundColor: Colors.black,
    body: Center(
      child: AspectRatio(
        // camera plugin reports aspectRatio as landscape (width/height);
        // invert it since we're displaying in portrait
        aspectRatio: 1 / controller.value.aspectRatio,
        child: Stack(
          fit: StackFit.expand,
          children: [
            CameraPreview(controller), // no manual Transform/mirror here anymore
            if (_currentPose != null && _imageSize != null)
              CustomPaint(
                painter: PoseOverlayPainter(
                  pose: _currentPose!,
                  imageSize: _imageSize!, // raw Size(image.width, image.height), unswapped
                  rotation: InputImageRotation.rotation270deg, // from your confirmed log
                  cameraLensDirection: CameraLensDirection.front,
                ),
              ),
          ],
        ),
      ),
    ),
  );
  }
}