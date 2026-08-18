import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:ringa/logic/angle_calculator.dart';

PoseLandmark landmark(PoseLandmarkType type, double x, double y) {
  return PoseLandmark(type: type, x: x, y: y, z: 0, likelihood: 0.9);
}

void main() {
  group('AngleCalculator', () {
    test('returns 180 degrees for a straight line (arm fully extended)', () {
      final pose = Pose(landmarks: {
        PoseLandmarkType.leftShoulder: landmark(PoseLandmarkType.leftShoulder, 0, 0),
        PoseLandmarkType.leftElbow: landmark(PoseLandmarkType.leftElbow, 10, 0),
        PoseLandmarkType.leftWrist: landmark(PoseLandmarkType.leftWrist, 20, 0),
      });

      final angle = AngleCalculator.angleBetween(
        pose,
        PoseLandmarkType.leftShoulder,
        PoseLandmarkType.leftElbow,
        PoseLandmarkType.leftWrist,
      );

      expect(angle, closeTo(180.0, 0.1));
    });

    test('returns 90 degrees for a right-angle bend', () {
      final pose = Pose(landmarks: {
        PoseLandmarkType.leftShoulder: landmark(PoseLandmarkType.leftShoulder, 0, 10),
        PoseLandmarkType.leftElbow: landmark(PoseLandmarkType.leftElbow, 0, 0),
        PoseLandmarkType.leftWrist: landmark(PoseLandmarkType.leftWrist, 10, 0),
      });

      final angle = AngleCalculator.angleBetween(
        pose,
        PoseLandmarkType.leftShoulder,
        PoseLandmarkType.leftElbow,
        PoseLandmarkType.leftWrist,
      );

      expect(angle, closeTo(90.0, 0.1));
    });

    test('returns null when a landmark is missing', () {
      final pose = Pose(landmarks: {
        PoseLandmarkType.leftShoulder: landmark(PoseLandmarkType.leftShoulder, 0, 0),
        // leftElbow missing
        PoseLandmarkType.leftWrist: landmark(PoseLandmarkType.leftWrist, 20, 0),
      });

      final angle = AngleCalculator.angleBetween(
        pose,
        PoseLandmarkType.leftShoulder,
        PoseLandmarkType.leftElbow,
        PoseLandmarkType.leftWrist,
      );

      expect(angle, isNull);
    });

    test('returns null when likelihood is below threshold', () {
      final pose = Pose(landmarks: {
        PoseLandmarkType.leftShoulder: landmark(PoseLandmarkType.leftShoulder, 0, 0),
        PoseLandmarkType.leftElbow: PoseLandmark(
          type: PoseLandmarkType.leftElbow, x: 10, y: 0, z: 0, likelihood: 0.2,
        ),
        PoseLandmarkType.leftWrist: landmark(PoseLandmarkType.leftWrist, 20, 0),
      });

      final angle = AngleCalculator.angleBetween(
        pose,
        PoseLandmarkType.leftShoulder,
        PoseLandmarkType.leftElbow,
        PoseLandmarkType.leftWrist,
      );

      expect(angle, isNull);
    });

    test('averageElbowAngle falls back to one side when other is missing', () {
      final pose = Pose(landmarks: {
        PoseLandmarkType.rightShoulder: landmark(PoseLandmarkType.rightShoulder, 0, 10),
        PoseLandmarkType.rightElbow: landmark(PoseLandmarkType.rightElbow, 0, 0),
        PoseLandmarkType.rightWrist: landmark(PoseLandmarkType.rightWrist, 10, 0),
        // left side entirely missing
      });

      final angle = AngleCalculator.averageElbowAngle(pose);
      expect(angle, closeTo(90.0, 0.1));
    });
  });
}