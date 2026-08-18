import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:ringa/blocs/push_up/push_up_event.dart';
import 'package:ringa/blocs/push_up/push_up_state.dart';
import 'package:ringa/logic/angle_calculator.dart';

typedef AngleExtractor = double? Function(Pose pose);

class PushupBloc extends Bloc<PushupEvent, PushupState> {
  static const double downThreshold = 90.0;
  static const double upThreshold = 160.0;

  final AngleExtractor _extractAngle;

  PushupBloc({AngleExtractor? angleExtractor})
      : _extractAngle = angleExtractor ?? AngleCalculator.averageElbowAngle,
        super(PushupState.initial()) {
    on<PoseDetected>(_onPoseDetected);
    on<ResetCounter>(_onResetCounter);
  }

  void _onPoseDetected(PoseDetected event, Emitter<PushupState> emit) {
    final angle = _extractAngle(event.pose);
    final nextFrameId = state.frameId + 1;

    if (angle == null) {
      emit(state.copyWith(lastPose: event.pose, frameId: nextFrameId));
      return;
    }

    RepPosition newPosition = state.position;
    int newCount = state.count;

    if (angle < downThreshold && state.position != RepPosition.down) {
      newPosition = RepPosition.down;
    } else if (angle > upThreshold && state.position == RepPosition.down) {
      newPosition = RepPosition.up;
      newCount = state.count + 1;
    }

    emit(state.copyWith(
      count: newCount,
      position: newPosition,
      currentElbowAngle: angle,
      lastPose: event.pose,
      frameId: nextFrameId,
    ));
  }

  void _onResetCounter(ResetCounter event, Emitter<PushupState> emit) {
    emit(PushupState.initial());
  }
}