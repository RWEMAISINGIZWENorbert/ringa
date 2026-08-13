import 'package:equatable/equatable.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

abstract class PushupEvent extends Equatable {
  const PushupEvent();

  @override
  List<Object?> get props => [];
}

class PoseDetected extends PushupEvent {
  final Pose pose;
  const PoseDetected(this.pose);

  @override
  List<Object?> get props => [pose];
}

class ResetCounter extends PushupEvent {
  const ResetCounter();
}