import 'package:flutter/material.dart';
import 'dart:math' as math;

class ResponsiveLayoutWrapper extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;

  const ResponsiveLayoutWrapper({
    super.key,
    required this.child,
    this.maxWidth = 500,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: math.min(maxWidth, constraints.maxWidth),
            ),
            child: Padding(
              padding: padding ?? EdgeInsets.zero,
              child: child,
            ),
          ),
        );
      },
    );
  }
}
