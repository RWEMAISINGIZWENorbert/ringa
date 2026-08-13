import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ringa/blocs/push_up/push_up_event.dart';
import 'package:ringa/blocs/push_up/push_up_state.dart';
import '../../logic/angle_calculator.dart';

class PushupBloc extends Bloc<PushupEvent, PushupState> {
  // Hysteresis thresholds — different triggers for down vs up to prevent
  // jitter around a single threshold from causing false/double counts.
  static const double downThreshold = 90.0;
  static const double upThreshold = 160.0;

  PushupBloc() : super(PushupState.initial()) {
    on<PoseDetected>(_onPoseDetected);
    on<ResetCounter>(_onResetCounter);
  }

  void _onPoseDetected(PoseDetected event, Emitter<PushupState> emit) {
    final angle = AngleCalculator.averageElbowAngle(event.pose);

    // No confident angle this frame — still update lastPose so the
    // overlay keeps tracking, but don't touch count/position logic.
    if (angle == null) {
      emit(state.copyWith(lastPose: event.pose));
      return;
    }

    RepPosition newPosition = state.position;
    int newCount = state.count;

    if (angle < downThreshold && state.position != RepPosition.down) {
      newPosition = RepPosition.down;
    } else if (angle > upThreshold && state.position == RepPosition.down) {
      newPosition = RepPosition.up;
      newCount = state.count + 1; // rep completed: down -> up transition
    }

    emit(state.copyWith(
      count: newCount,
      position: newPosition,
      currentElbowAngle: angle,
      lastPose: event.pose,
    ));
  }

  void _onResetCounter(ResetCounter event, Emitter<PushupState> emit) {
    emit(PushupState.initial());
  }
}