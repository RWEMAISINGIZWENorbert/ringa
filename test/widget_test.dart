// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';

import 'package:ringa/main.dart';
import 'package:ringa/widgets/pose_overlay_painter.dart';

PoseLandmark lm(PoseLandmarkType t, double x, double y) =>
    PoseLandmark(type: t, x: x, y: y, z: 0, likelihood: 0.9);


void main() {
  // testWidgets('Counter increments smoke test', (WidgetTester tester) async {
  //   // Build our app and trigger a frame.
  //   await tester.pumpWidget(const MyApp());

  //   // Verify that our counter starts at 0.
  //   expect(find.text('0'), findsOneWidget);
  //   expect(find.text('1'), findsNothing);

  //   // Tap the '+' icon and trigger a frame.
  //   await tester.tap(find.byIcon(Icons.add));
  //   await tester.pump();

  //   // Verify that our counter has incremented.
  //   expect(find.text('0'), findsNothing);
  //   expect(find.text('1'), findsOneWidget);
  // });

  testWidgets('PoseOverlayPainter renders skeleton at expected position',
      (tester) async {
    final pose = Pose(landmarks: {
      PoseLandmarkType.leftShoulder: lm(PoseLandmarkType.leftShoulder, 100, 100),
      PoseLandmarkType.leftElbow: lm(PoseLandmarkType.leftElbow, 100, 200),
      PoseLandmarkType.leftWrist: lm(PoseLandmarkType.leftWrist, 100, 300),
    });

    await tester.pumpWidget(MaterialApp(
      home: RepaintBoundary(
        key: const Key('pose_overlay_boundary'),
        child: CustomPaint(
          size: const Size(400, 600),
          painter: PoseOverlayPainter(
            pose: pose,
            imageSize: const Size(480, 640),
            rotation: InputImageRotation.rotation270deg,
            cameraLensDirection: CameraLensDirection.front,
          ),
        ),
      ),
    ));

    await expectLater(
      find.byKey(const Key('pose_overlay_boundary')),
      matchesGoldenFile('goldens/pose_overlay_basic.png'),
    );
  });
}
