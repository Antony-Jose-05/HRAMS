import 'package:flutter/material.dart';
import 'sphere_widget.dart';

class DashboardBackground extends StatelessWidget {
  final Widget child;

  const DashboardBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Container(
      width: size.width,
      height: size.height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFF8FAFC),
            Color(0xFFF1F5F9),
            Color(0xFFE2E8F0),
            Color(0xFFF8FAFC),
          ],
        ),
      ),
      child: Stack(
        children: [
          // Floating sphere decorations
          Positioned(
            right: -30,
            top: size.height * 0.06,
            child: const SphereWidget(
              size: 110,
              colors: [
                Color(0xFF3B5DF5),
                Color(0xFF1E3A8A),
                Color(0xFF172554),
              ],
              opacity: 0.4,
            ),
          ),
          Positioned(
            left: -40,
            top: size.height * 0.3,
            child: const SphereWidget(
              size: 80,
              colors: [
                Color(0xFF7B6EF6),
                Color(0xFF4338CA),
                Color(0xFF312E81),
              ],
              opacity: 0.3,
            ),
          ),
          Positioned(
            right: 20,
            bottom: size.height * 0.25,
            child: const SphereWidget(
              size: 60,
              colors: [
                Color(0xFF00D4FF),
                Color(0xFF0284C7),
                Color(0xFF075985),
              ],
              opacity: 0.25,
            ),
          ),
          Positioned(
            left: size.width * 0.35,
            bottom: size.height * 0.1,
            child: const SphereWidget(
              size: 45,
              colors: [
                Color(0xFF94A3B8),
                Color(0xFF64748B),
                Color(0xFF475569),
              ],
              opacity: 0.2,
            ),
          ),
          // Main content
          child,
        ],
      ),
    );
  }
}
