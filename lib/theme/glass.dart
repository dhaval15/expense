import 'package:flutter/material.dart';

class Glass extends StatelessWidget {
  final Widget child;
  final int alpha;
  final EdgeInsets padding;
  final Color color;
  final double radius;

  const Glass({
    this.child,
    this.alpha = 60,
    this.padding = const EdgeInsets.all(8),
    this.color = Colors.black87,
    this.radius = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        color: color.withAlpha(alpha),
      ),
      padding: padding,
      child: Theme(
        data: ThemeData.dark(),
        child: child,
      ),
    );
  }
}
