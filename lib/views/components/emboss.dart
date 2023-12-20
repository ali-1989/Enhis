import 'package:flutter/material.dart';

class Emboss extends StatelessWidget {
  final Offset offset;
  final MaterialColor shadowColor;
  final Color backgroundColor;
  final BorderRadius? borderRadius;
  final List<BoxShadow> shadows;
  final Widget child;

  const Emboss({
    super.key,
    this.offset = const Offset(-0.5,-0.5),
    this.shadowColor = Colors.grey,
    this.backgroundColor = Colors.transparent,
    this.borderRadius,
    this.shadows = const [],
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
          borderRadius: borderRadius ?? BorderRadius.circular(12),
          color: backgroundColor,
          boxShadow: [
            BoxShadow(
                color: shadowColor,
                offset: offset,
              blurRadius: 1,
            ),

            ...shadows,
          ]
      ),
      child: child,
    );
  }
}
