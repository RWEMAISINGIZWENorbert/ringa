import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ringa/blocs/push_up/push_up_bloc.dart';
import 'package:ringa/blocs/push_up/push_up_state.dart';

class CounterDisplay extends StatelessWidget {
  const CounterDisplay({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PushupBloc, PushupState>(
      buildWhen: (previous, current) =>
          previous.count != current.count ||
          previous.position != current.position,
      builder: (context, state) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${state.count}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                state.position.name.toUpperCase(),
                style: TextStyle(
                  color: state.position == RepPosition.down
                      ? Colors.orangeAccent
                      : Colors.greenAccent,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}