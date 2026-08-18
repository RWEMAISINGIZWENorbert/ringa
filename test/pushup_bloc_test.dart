import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:ringa/blocs/push_up/push_up_bloc.dart';
import 'package:ringa/blocs/push_up/push_up_event.dart';
import 'package:ringa/blocs/push_up/push_up_state.dart';


// A minimal fake Pose — content doesn't matter since we inject the angle extractor
Pose fakePose() => Pose(landmarks: {});

void main() {
  group('PushupBloc', () {
    blocTest<PushupBloc, PushupState>(
      'counts one rep for a full down->up cycle',
      build: () {
        // Simulate a realistic angle sequence: 170(up) -> 60(down) -> 170(up)
        final angles = [170.0, 120.0, 60.0, 90.0, 130.0, 170.0];
        int i = 0;
        return PushupBloc(angleExtractor: (_) => angles[i++]);
      },
      act: (bloc) {
        for (var i = 0; i < 6; i++) {
          bloc.add(PoseDetected(fakePose()));
        }
      },
      verify: (bloc) {
        expect(bloc.state.count, 1);
        expect(bloc.state.position, RepPosition.up);
      },
    );

    blocTest<PushupBloc, PushupState>(
      'does NOT count a partial rep that never crosses downThreshold',
      build: () {
        // Never goes below 90 (downThreshold) — should stay at 0
        final angles = [170.0, 140.0, 110.0, 140.0, 170.0];
        int i = 0;
        return PushupBloc(angleExtractor: (_) => angles[i++]);
      },
      act: (bloc) {
        for (var i = 0; i < 5; i++) {
          bloc.add(PoseDetected(fakePose()));
        }
      },
      verify: (bloc) {
        expect(bloc.state.count, 0);
      },
    );

    blocTest<PushupBloc, PushupState>(
      'counts multiple consecutive reps correctly',
      build: () {
        // 3 full reps: down/up/down/up/down/up
        final angles = [
          170.0, 60.0, 170.0, // rep 1
          170.0, 55.0, 165.0, // rep 2
          170.0, 65.0, 170.0, // rep 3
        ];
        int i = 0;
        return PushupBloc(angleExtractor: (_) => angles[i++]);
      },
      act: (bloc) {
        for (var i = 0; i < 9; i++) {
          bloc.add(PoseDetected(fakePose()));
        }
      },
      verify: (bloc) {
        expect(bloc.state.count, 3);
      },
    );

    blocTest<PushupBloc, PushupState>(
      'ignores jitter/noise around threshold without double-counting',
      build: () {
        // Angle bounces around 85-95 (near downThreshold) then goes to a
        // real up position — hysteresis should prevent multiple down
        // transitions from being treated as multiple reps
        final angles = [
          170.0, 88.0, 92.0, 87.0, 91.0, 60.0, 170.0,
        ];
        int i = 0;
        return PushupBloc(angleExtractor: (_) => angles[i++]);
      },
      act: (bloc) {
        for (var i = 0; i < 7; i++) {
          bloc.add(PoseDetected(fakePose()));
        }
      },
      verify: (bloc) {
        expect(bloc.state.count, 1); // exactly one rep, not multiple
      },
    );

    blocTest<PushupBloc, PushupState>(
      'ResetCounter returns to initial state',
      build: () {
        final angles = [170.0, 60.0, 170.0];
        int i = 0;
        return PushupBloc(angleExtractor: (_) => angles[i++]);
      },
      act: (bloc) {
        bloc.add(PoseDetected(fakePose()));
        bloc.add(PoseDetected(fakePose()));
        bloc.add(PoseDetected(fakePose()));
        bloc.add(const ResetCounter());
      },
      verify: (bloc) {
        expect(bloc.state.count, 0);
        expect(bloc.state.position, RepPosition.unknown);
      },
    );

    blocTest<PushupBloc, PushupState>(
      'null angle (low confidence) does not break the state machine',
      build: () {
        final angles = [170.0, null, null, 60.0, null, 170.0];
        int i = 0;
        return PushupBloc(angleExtractor: (_) => angles[i++]);
      },
      act: (bloc) {
        for (var i = 0; i < 6; i++) {
          bloc.add(PoseDetected(fakePose()));
        }
      },
      verify: (bloc) {
        expect(bloc.state.count, 1); // still counts despite dropout frames
      },
    );
  });
}