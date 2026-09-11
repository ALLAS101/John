import 'package:flutter/material.dart';

/// The Today screen's single moment of visual warmth: a static radial glow
/// centered above the content, non-interactive. 660x520 logical px,
/// positioned so its center sits 180px above the screen's top edge (see the
/// "Dawn glow" row of the Design Tokens table).
class DawnGlow extends StatelessWidget {
  const DawnGlow({super.key, required this.gradient});

  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -180,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: Center(
          child: Container(
            width: 660,
            height: 520,
            decoration: BoxDecoration(gradient: gradient),
          ),
        ),
      ),
    );
  }
}
