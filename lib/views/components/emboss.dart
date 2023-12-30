import 'package:flutter/material.dart';

class Emboss extends StatelessWidget {
  final Offset? offset;
  final MaterialColor shadowColor;
  final Color backgroundColor;
  final BorderRadius? borderRadius;
  final List<BoxShadow> shadows;
  final bool deBoss;
  final Widget child;

  const Emboss({
    super.key,
    this.offset,
    this.shadowColor = Colors.grey,
    this.backgroundColor = Colors.white,
    this.borderRadius,
    this.deBoss = false,
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
            if(shadows.isEmpty)
            BoxShadow(
                color: shadowColor,
                offset: offset ?? (deBoss? const Offset(-0.8,-0.8) : const Offset(0.5,0.5)),
              blurRadius: deBoss? 1.5: 0.7,
              spreadRadius: 0,
            ),

            if(shadows.isEmpty)
              BoxShadow(
              color: Colors.white,
              offset: deBoss? const Offset(0.7,0.7) : const Offset(-0.7,-0.7),
              blurRadius: 0.5,
            ),

            ...shadows,
          ]
      ),
      child: ClipRRect(
          borderRadius: borderRadius ?? BorderRadius.circular(12),
          child: child
      ),
    );
  }
}
