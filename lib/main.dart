import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ringa/blocs/push_up/push_up_bloc.dart';
import 'package:ringa/screens/push_up_counter_screen.dart';
import 'package:ringa/test_utils/video_frame_replay_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) => PushupBloc(),
      child: MaterialApp(
        title: 'Ringa',
        debugShowCheckedModeBanner: false,
        // home: const PushupCounterScreen(),
        home: const VideoReplayTestScreen(),
      ),
    );
  }
}
