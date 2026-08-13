import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:ringa/blocs/push_up/push_up_bloc.dart';
import 'package:ringa/blocs/push_up/push_up_event.dart';
import 'package:ringa/blocs/push_up/push_up_state.dart';
import 'package:ringa/services/camera_service.dart';
import 'package:ringa/services/pose_detector_service.dart';
import 'package:ringa/widgets/counter_display.dart';
import 'package:ringa/widgets/loading_indicator.dart';
import 'package:ringa/widgets/pose_overlay_painter.dart';


class PushupCounterScreen extends StatelessWidget {
  const PushupCounterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PushupBloc(),
      child: const _PushupCounterView(),
    );
  }
}

class _PushupCounterView extends StatefulWidget {
  const _PushupCounterView();

  @override
  State<_PushupCounterView> createState() => _PushupCounterViewState();
}

class _PushupCounterViewState extends State<_PushupCounterView> {
  final CameraService _cameraService = CameraService();
  final PoseDetectorService _poseDetectorService = PoseDetectorService();

  Size? _imageSize;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _cameraService.initialize(useFrontCamera: true);
    if (!mounted) return;
    setState(() {}); // only used to rebuild once controller is ready — no pose state here

    _cameraService.startImageStream((CameraImage image) async {
      final camera = _cameraService.activeCameraDescription;
      if (camera == null) return;

      _imageSize = Size(image.width.toDouble(), image.height.toDouble());

      final pose = await _poseDetectorService.processImage(image, camera);
      if (pose != null && mounted) {
        // dispatch to bloc instead of setState
        context.read<PushupBloc>().add(PoseDetected(pose));
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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: AspectRatio(
              aspectRatio: 1 / controller.value.aspectRatio,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CameraPreview(controller),
                  if (_imageSize != null)
                    BlocBuilder<PushupBloc, PushupState>(
                      buildWhen: (previous, current) =>
                          current.lastPose != null,
                      builder: (context, state) {
                        if (state.lastPose == null) {
                          return const SizedBox.shrink(
                            child: Text('go in the position', style: TextStyle(color: Colors.white)),
                          );
                        }
                        return CustomPaint(
                          painter: PoseOverlayPainter(
                            pose: state.lastPose!,
                            imageSize: _imageSize!,
                            rotation: InputImageRotation.rotation270deg,
                            cameraLensDirection: CameraLensDirection.front,
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ),
          // Counter overlay, pinned to top
          const Positioned(
            top: 48,
            left: 0,
            right: 0,
            child: Center(child: CounterDisplay()),
          ),
          // Reset button
          Positioned(
            bottom: 32,
            right: 24,
            child: FloatingActionButton(
              onPressed: () => context.read<PushupBloc>().add(const ResetCounter()),
              child: const Icon(Icons.refresh),
            ),
          ),
        ],
      ),
    );
  }
}