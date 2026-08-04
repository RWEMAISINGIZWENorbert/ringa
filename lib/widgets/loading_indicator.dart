import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class LoadingIndicator extends StatelessWidget {
  final double radius;
  final Color? color;

  const LoadingIndicator({super.key, this.radius = 12, this.color});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // We use CupertinoActivityIndicator to match the exact "petal" look from the screenshot
    return Center(
      child: ColorFiltered(
        colorFilter: ColorFilter.mode(
          color ?? theme.colorScheme.primary, // Defaults to the neon green
          BlendMode.srcIn,
        ),
        child: CupertinoActivityIndicator(radius: radius),
      ),
    );
  }
}
