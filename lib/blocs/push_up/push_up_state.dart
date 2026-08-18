import 'package:equatable/equatable.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

enum RepPosition { up, down, unknown }

class PushupState extends Equatable {
  final int count;
  final RepPosition position;
  final double? currentElbowAngle;
  final Pose? lastPose;
  final int frameId; // increments every processed frame — guarantees emit never gets skipped

  const PushupState({
    required this.count,
    required this.position,
    required this.frameId,
    this.currentElbowAngle,
    this.lastPose,
  });

  factory PushupState.initial() => const PushupState(
        count: 0,
        position: RepPosition.unknown,
        frameId: 0,
      );

  PushupState copyWith({
    int? count,
    RepPosition? position,
    double? currentElbowAngle,
    Pose? lastPose,
    int? frameId,
  }) {
    return PushupState(
      count: count ?? this.count,
      position: position ?? this.position,
      currentElbowAngle: currentElbowAngle ?? this.currentElbowAngle,
      lastPose: lastPose ?? this.lastPose,
      frameId: frameId ?? this.frameId,
    );
  }

  @override
  // frameId included so every emit is treated as distinct, even when
  // count/position/angle are unchanged (e.g. a low-confidence frame).
  // lastPose stays excluded since Pose has no value equality anyway.
  List<Object?> get props => [count, position, currentElbowAngle, frameId];
}