import 'dart:io';
import 'package:camera/camera.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:flutter/services.dart';

class PoseDetectorService {
  final PoseDetector _poseDetector = PoseDetector(
    options: PoseDetectorOptions(
      mode: PoseDetectionMode.stream, // optimized for continuous video, not single images
    ),
  );

  bool _isProcessing = false;

  Future<Pose?> processImage(
    CameraImage image,
    CameraDescription camera,
  ) async {
    if (_isProcessing) return null; // drop frame if still busy
    _isProcessing = true;

    try {
      final inputImage = _convertCameraImage(image, camera);
      if (inputImage == null) return null;

      final poses = await _poseDetector.processImage(inputImage);

      if (poses.isNotEmpty) {
        final pose = poses.first;
        // _logLandmarks(pose);
        return pose;
      }
      return null;
    } finally {
      _isProcessing = false;
    }
  }

  InputImage? _convertCameraImage(CameraImage image, CameraDescription camera) {
    final sensorOrientation = camera.sensorOrientation;

    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      // // Front camera: ML Kit expects rotation compensated for mirroring
      // var rotationCompensation = sensorOrientation;
      // if (camera.lensDirection == CameraLensDirection.front) {
      //   rotationCompensation = (360 - sensorOrientation) % 360;
      // }
      // rotation = InputImageRotationValue.fromRawValue(rotationCompensation);

      // App is portrait-locked, so no live device-rotation compensation needed —
     // sensorOrientation alone gives the correct rotation for both lens directions.
     rotation = InputImageRotationValue.fromRawValue(sensorOrientation);

    }
    rotation ??= InputImageRotation.rotation0deg;
  
  print('====================================sensorOrientation: ${camera.sensorOrientation}, lensDirection: ${camera.lensDirection}, resolvedRotation: $rotation');


    final format = Platform.isAndroid
        ? InputImageFormat.nv21
        : InputImageFormat.bgra8888;

    // Concatenate all planes into a single byte buffer
    final WriteBuffer allBytes = WriteBuffer();
    for (final plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes.first.bytesPerRow,
      ),
    );
  }

  void _logLandmarks(Pose pose) {
    for (final landmark in pose.landmarks.values) {
      // ignore: avoid_print
      print(
        '${landmark.type.name}: x=${landmark.x.toStringAsFixed(1)}, '
        'y=${landmark.y.toStringAsFixed(1)}, '
        'likelihood=${landmark.likelihood.toStringAsFixed(2)}',
      );
    }
  }

  void dispose() {
    _poseDetector.close();
  }
}