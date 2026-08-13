import 'dart:math';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

class AngleCalculator {
  /// Returns the angle (in degrees) at [mid], formed by the lines
  /// mid->first and mid->last. Returns null if any landmark is missing
  /// or has low confidence.
  static double? angleBetween(
    Pose pose,
    PoseLandmarkType first,
    PoseLandmarkType mid,
    PoseLandmarkType last, {
    double minLikelihood = 0.6,
  }) {
    final a = pose.landmarks[first];
    final b = pose.landmarks[mid];
    final c = pose.landmarks[last];

    if (a == null || b == null || c == null) return null;
    if (a.likelihood < minLikelihood ||
        b.likelihood < minLikelihood ||
        c.likelihood < minLikelihood) {
      return null;
    }

    final radians = atan2(c.y - b.y, c.x - b.x) - atan2(a.y - b.y, a.x - b.x);
    double degrees = (radians * 180.0 / pi).abs();
    if (degrees > 180) degrees = 360 - degrees;
    return degrees;
  }

  /// Convenience: average of left + right elbow angle, falling back to
  /// whichever side is confidently visible if only one side is detected.
  static double? averageElbowAngle(Pose pose) {
    final left = angleBetween(
      pose,
      PoseLandmarkType.leftShoulder,
      PoseLandmarkType.leftElbow,
      PoseLandmarkType.leftWrist,
    );
    final right = angleBetween(
      pose,
      PoseLandmarkType.rightShoulder,
      PoseLandmarkType.rightElbow,
      PoseLandmarkType.rightWrist,
    );

    if (left != null && right != null) return (left + right) / 2;
    return left ?? right;
  }
}