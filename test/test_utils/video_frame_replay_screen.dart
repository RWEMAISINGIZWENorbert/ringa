import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:ringa/blocs/push_up/push_up_bloc.dart';
import 'package:ringa/blocs/push_up/push_up_event.dart';
import 'package:ringa/services/pose_detector_service.dart';

/// Debug-only screen: runs pose detection against a folder of pre-extracted
/// JPEG frames (from a recorded pushup video) instead of the live camera.
/// Lets you replay the exact same motion repeatedly to test counting logic
/// and tune thresholds without doing physical reps each time.
class VideoReplayTestScreen extends StatefulWidget {
  const VideoReplayTestScreen({super.key});

  @override
  State<VideoReplayTestScreen> createState() => _VideoReplayTestScreenState();
}

class _VideoReplayTestScreenState extends State<VideoReplayTestScreen> {
  final PoseDetectorService _poseDetectorService = PoseDetectorService();
  Timer? _timer;
  int _frameIndex = 0;
  static const int totalFrames = 150; // however many frames you extracted

  @override
  void initState() {
    super.initState();
    _startReplay();
  }

  void _startReplay() {
    _timer = Timer.periodic(const Duration(milliseconds: 66), (_) async {
      if (_frameIndex >= totalFrames) {
        _timer?.cancel();
        return;
      }
      // Load frame N from assets/test_frames/frame_0001.jpg etc.
      final path = 'assets/test_frames/frame_${_frameIndex.toString().padLeft(4, '0')}.jpg';
      final inputImage = InputImage.fromFilePath(path);
      final poses = await _poseDetectorService.processStaticImage(inputImage);
      if (poses.isNotEmpty && mounted) {
        context.read<PushupBloc>().add(PoseDetected(poses.first));
      }
      _frameIndex++;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _poseDetectorService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PushupBloc, dynamic>(
      builder: (context, state) => Scaffold(
        body: Center(
          child: Text('Count: ${state.count}\nFrame: $_frameIndex/$totalFrames',
              style: const TextStyle(fontSize: 24)),
        ),
      ),
    );
  }
}