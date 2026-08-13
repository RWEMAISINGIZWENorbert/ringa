import 'package:equatable/equatable.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

enum RepPosition { up, down, unknown }

class PushupState extends Equatable {
  final int count;
  final RepPosition position;
  final double? currentElbowAngle;
  final Pose? lastPose;

  const PushupState({
    required this.count,
    required this.position,
    this.currentElbowAngle,
    this.lastPose,
  });

  factory PushupState.initial() => const PushupState(
        count: 0,
        position: RepPosition.unknown,
      );

  PushupState copyWith({
    int? count,
    RepPosition? position,
    double? currentElbowAngle,
    Pose? lastPose,
  }) {
    return PushupState(
      count: count ?? this.count,
      position: position ?? this.position,
      currentElbowAngle: currentElbowAngle ?? this.currentElbowAngle,
      lastPose: lastPose ?? this.lastPose,
    );
  }

  @override
  // NOTE: lastPose deliberately excluded from props — see explanation below
  List<Object?> get props => [count, position, currentElbowAngle];
}