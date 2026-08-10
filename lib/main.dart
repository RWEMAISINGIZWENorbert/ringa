import 'package:flutter/material.dart';
import 'package:ringa/screens/push_up_counter_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ringa',
      debugShowCheckedModeBanner: false,
      home: const PushupCounterScreen(),
    );
  }
}
