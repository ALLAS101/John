import 'package:flutter/material.dart';

/// Hand-drawn line icons matching the inline SVGs in the design handoff
/// (24x24 viewBox, 1.6-1.9 stroke, round caps/joins — see the Assets section
/// of design_handoff_john_3_16/README.md). Kept as CustomPainters instead of
/// pulling in an icon-font package, since these exact glyphs (sunrise,
/// flame, 2x2 grid, mic capsule...) aren't in Material/Cupertino's sets.
class _StrokeIconPainter extends CustomPainter {
  _StrokeIconPainter({
    required this.build,
    required this.color,
    required this.strokeWidth,
    this.fill,
  });

  /// Builds the path(s) in the source 24x24 coordinate space.
  final void Function(Canvas canvas, Paint stroke, Paint? fill) build;
  final Color color;
  final double strokeWidth;
  final Color? fill;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 24, size.height / 24);
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fillPaint = fill == null
        ? null
        : (Paint()
          ..color = fill!
          ..style = PaintingStyle.fill);
    build(canvas, stroke, fillPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _StrokeIconPainter oldDelegate) {
    return oldDelegate.color != color ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.fill != fill;
  }
}

class _Icon extends StatelessWidget {
  const _Icon({
    required this.size,
    required this.color,
    required this.draw,
    this.strokeWidth = 1.6,
    this.fill,
  });

  final double size;
  final Color color;
  final double strokeWidth;
  final Color? fill;
  final void Function(Canvas canvas, Paint stroke, Paint? fill) draw;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size.square(size),
      painter: _StrokeIconPainter(
        build: draw,
        color: color,
        strokeWidth: strokeWidth,
        fill: fill,
      ),
    );
  }
}

/// Tab bar / greeting: sunrise (sun + horizon rays).
class SunriseIcon extends StatelessWidget {
  const SunriseIcon({super.key, required this.color, this.size = 22});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return _Icon(
      size: size,
      color: color,
      draw: (canvas, stroke, _) {
        canvas.drawCircle(const Offset(12, 13), 4, stroke);
        final rays = Path()
          ..moveTo(12, 5)
          ..lineTo(12, 7)
          ..moveTo(5, 13)
          ..lineTo(3, 13)
          ..moveTo(21, 13)
          ..lineTo(19, 13)
          ..moveTo(6.5, 7.5)
          ..lineTo(5, 6)
          ..moveTo(17.5, 7.5)
          ..lineTo(19, 6)
          ..moveTo(2, 19)
          ..lineTo(22, 19);
        canvas.drawPath(rays, stroke);
      },
    );
  }
}

/// Tab bar: journal (open book).
class BookIcon extends StatelessWidget {
  const BookIcon({super.key, required this.color, this.size = 22});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return _Icon(
      size: size,
      color: color,
      draw: (canvas, stroke, _) {
        final cover = Path()
          ..moveTo(5, 4)
          ..lineTo(14, 4)
          ..arcToPoint(
            const Offset(17, 7),
            radius: const Radius.circular(3),
            clockwise: true,
          )
          ..lineTo(17, 20)
          ..lineTo(8, 20)
          ..arcToPoint(
            const Offset(5, 17),
            radius: const Radius.circular(3),
            clockwise: true,
          )
          ..close();
        canvas.drawPath(cover, stroke);
        final lines = Path()
          ..moveTo(8.5, 8.5)
          ..lineTo(13.5, 8.5)
          ..moveTo(8.5, 12)
          ..lineTo(13.5, 12)
          ..moveTo(8.5, 15.5)
          ..lineTo(11.5, 15.5);
        canvas.drawPath(lines, stroke);
      },
    );
  }
}

/// Tab bar: plan (checklist).
class ChecklistIcon extends StatelessWidget {
  const ChecklistIcon({super.key, required this.color, this.size = 22});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return _Icon(
      size: size,
      color: color,
      draw: (canvas, stroke, _) {
        final path = Path()
          ..moveTo(3, 7)
          ..lineTo(5, 9)
          ..lineTo(8, 6)
          ..moveTo(3, 16)
          ..lineTo(5, 18)
          ..lineTo(8, 15)
          ..moveTo(12, 8)
          ..lineTo(21, 8)
          ..moveTo(12, 17)
          ..lineTo(21, 17);
        canvas.drawPath(path, stroke);
      },
    );
  }
}

/// Tab bar: widget (2x2 grid).
class GridIcon extends StatelessWidget {
  const GridIcon({super.key, required this.color, this.size = 22});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return _Icon(
      size: size,
      color: color,
      draw: (canvas, stroke, _) {
        for (final origin in const [
          Offset(3.5, 3.5),
          Offset(13.5, 3.5),
          Offset(3.5, 13.5),
          Offset(13.5, 13.5),
        ]) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              origin & const Size(7, 7),
              const Radius.circular(2),
            ),
            stroke,
          );
        }
      },
    );
  }
}

/// Streak pill: flame.
class FlameIcon extends StatelessWidget {
  const FlameIcon({super.key, required this.color, this.size = 13});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return _Icon(
      size: size,
      color: color,
      strokeWidth: 1.8,
      draw: (canvas, stroke, _) {
        final path = Path()
          ..moveTo(12, 3)
          ..cubicTo(12, 3, 17, 7.5, 17, 12)
          ..arcToPoint(
            const Offset(7, 12),
            radius: const Radius.circular(5),
            clockwise: true,
          )
          ..cubicTo(7, 10, 8, 8.5, 9, 7.5);
        canvas.drawPath(path, stroke);
      },
    );
  }
}

/// Listen button: filled play triangle.
class PlayIcon extends StatelessWidget {
  const PlayIcon({super.key, required this.color, this.size = 15});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return _Icon(
      size: size,
      color: Colors.transparent,
      fill: color,
      draw: (canvas, _, fill) {
        final path = Path()
          ..moveTo(8, 5.5)
          ..lineTo(8, 18.5)
          ..lineTo(19, 12)
          ..close();
        canvas.drawPath(path, fill!);
      },
    );
  }
}

/// Save toggle: bookmark. `filled` mirrors the design's saved/unsaved state
/// (solid gold fill vs. outline-only).
class BookmarkIcon extends StatelessWidget {
  const BookmarkIcon({
    super.key,
    required this.filled,
    required this.fillColor,
    required this.strokeColor,
    this.size = 19,
  });

  final bool filled;
  final Color fillColor;
  final Color strokeColor;
  final double size;

  @override
  Widget build(BuildContext context) {
    return _Icon(
      size: size,
      color: strokeColor,
      strokeWidth: 1.7,
      fill: filled ? fillColor : null,
      draw: (canvas, stroke, fill) {
        final path = Path()
          ..moveTo(6, 4)
          ..lineTo(18, 4)
          ..lineTo(18, 21)
          ..lineTo(12, 16.8)
          ..lineTo(6, 21)
          ..close();
        if (fill != null) canvas.drawPath(path, fill);
        canvas.drawPath(path, stroke);
      },
    );
  }
}

/// Journal footer hint: keyboard.
class KeyboardIcon extends StatelessWidget {
  const KeyboardIcon({super.key, required this.color, this.size = 14});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return _Icon(
      size: size,
      color: color,
      strokeWidth: 1.7,
      draw: (canvas, stroke, _) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Offset(4, 4) & const Size(16, 16),
            const Radius.circular(4),
          ),
          stroke,
        );
        canvas.drawLine(const Offset(8, 12), const Offset(16, 12), stroke);
      },
    );
  }
}

/// Mic button glyph: capsule + pickup arc + stand.
class MicIcon extends StatelessWidget {
  const MicIcon({super.key, required this.color, this.size = 21});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return _Icon(
      size: size,
      color: color,
      strokeWidth: 1.9,
      draw: (canvas, stroke, _) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            const Offset(9, 3) & const Size(6, 10),
            const Radius.circular(3),
          ),
          stroke,
        );
        final arc = Path()
          ..moveTo(5.5, 11)
          ..arcToPoint(
            const Offset(18.5, 11),
            radius: const Radius.circular(6.5),
            clockwise: false,
          );
        canvas.drawPath(arc, stroke);
        canvas.drawLine(const Offset(12, 17.5), const Offset(12, 21), stroke);
      },
    );
  }
}

/// "Write about this" link: arrow-right.
class ArrowRightIcon extends StatelessWidget {
  const ArrowRightIcon({super.key, required this.color, this.size = 14});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return _Icon(
      size: size,
      color: color,
      strokeWidth: 1.8,
      draw: (canvas, stroke, _) {
        final path = Path()
          ..moveTo(5, 12)
          ..lineTo(18, 12)
          ..moveTo(13, 7)
          ..lineTo(18, 12)
          ..lineTo(13, 17);
        canvas.drawPath(path, stroke);
      },
    );
  }
}

/// Plan day checkbox: check mark.
class CheckIcon extends StatelessWidget {
  const CheckIcon({super.key, required this.color, this.size = 12});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return _Icon(
      size: size,
      color: color,
      strokeWidth: 2.6,
      draw: (canvas, stroke, _) {
        final path = Path()
          ..moveTo(5, 12.5)
          ..lineTo(9.5, 17)
          ..lineTo(19, 7);
        canvas.drawPath(path, stroke);
      },
    );
  }
}
