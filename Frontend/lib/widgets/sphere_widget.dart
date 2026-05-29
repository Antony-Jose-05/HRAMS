import 'dart:ui';
import 'package:flutter/material.dart';

class SphereWidget extends StatelessWidget {
  final double size;
  final List<Color> colors;
  final Alignment lightSource;
  final double opacity;
  final double blur;

  const SphereWidget({
    super.key,
    required this.size,
    required this.colors,
    this.lightSource = const Alignment(-0.35, -0.35),
    this.opacity = 1.0,
    this.blur = 0.0,
  });

  @override
  Widget build(BuildContext context) {
    Widget sphere = Opacity(
      opacity: opacity,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            center: lightSource,
            radius: 0.7,
            colors: colors,
            stops: const [0.0, 0.55, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: colors.last.withValues(alpha: 0.3),
              blurRadius: size * 0.25,
              offset: Offset(size * 0.1, size * 0.15),
              spreadRadius: -size * 0.05,
            ),
          ],
        ),
      ),
    );

    if (blur > 0.0) {
      return ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: sphere,
        ),
      );
    }

    return sphere;
  }
}
