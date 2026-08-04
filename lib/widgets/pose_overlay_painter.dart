import 'package:flutter/material.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class PoseOverlayPainter extends CustomPainter {
  final Pose pose;
  final Size imageSize; // size of the camera image (before rotation)
  final Size widgetSize; // size of the CameraPreview widget on screen

  PoseOverlayPainter({
    required this.pose,
    required this.imageSize,
    required this.widgetSize,
  });

  // Pairs of landmarks to connect with lines, forming the skeleton
  static const List<List<PoseLandmarkType>> connections = [
    [PoseLandmarkType.leftShoulder, PoseLandmarkType.rightShoulder],
    [PoseLandmarkType.leftShoulder, PoseLandmarkType.leftElbow],
    [PoseLandmarkType.leftElbow, PoseLandmarkType.leftWrist],
    [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightElbow],
    [PoseLandmarkType.rightElbow, PoseLandmarkType.rightWrist],
    [PoseLandmarkType.leftShoulder, PoseLandmarkType.leftHip],
    [PoseLandmarkType.rightShoulder, PoseLandmarkType.rightHip],
    [PoseLandmarkType.leftHip, PoseLandmarkType.rightHip],
    [PoseLandmarkType.leftHip, PoseLandmarkType.leftKnee],
    [PoseLandmarkType.leftKnee, PoseLandmarkType.leftAnkle],
    [PoseLandmarkType.rightHip, PoseLandmarkType.rightKnee],
    [PoseLandmarkType.rightKnee, PoseLandmarkType.rightAnkle],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()
      ..color = Colors.greenAccent
      ..style = PaintingStyle.fill;

    final linePaint = Paint()
      ..color = Colors.greenAccent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Camera image is typically rotated 90deg relative to portrait widget,
    // so we swap width/height when computing scale factors.
    final double scaleX = widgetSize.width / imageSize.height;
    final double scaleY = widgetSize.height / imageSize.width;

    Offset mapPoint(PoseLandmark landmark) {
      // Swap x/y to account for the 90-degree sensor rotation on most phones
      final double x = landmark.y * scaleX;
      final double y = landmark.x * scaleY;
      return Offset(x, y);
    }

    // Draw connecting lines first (so dots sit on top)
    for (final connection in connections) {
      final start = pose.landmarks[connection[0]];
      final end = pose.landmarks[connection[1]];
      if (start != null && end != null) {
        canvas.drawLine(mapPoint(start), mapPoint(end), linePaint);
      }
    }

    // Draw landmark dots
    for (final landmark in pose.landmarks.values) {
      canvas.drawCircle(mapPoint(landmark), 5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant PoseOverlayPainter oldDelegate) {
    return oldDelegate.pose != pose;
  }
}