import 'dart:math' as math;
import 'package:flutter/material.dart';

class CatanHexBackground extends StatelessWidget {
  final Widget child;

  const CatanHexBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: const _CatanHexMosaicPainter(),
      child: child,
    );
  }
}

class _CatanHexMosaicPainter extends CustomPainter {
  const _CatanHexMosaicPainter();

  static const Color _baseColor = Color(0xFFF3EAD8);
  static const double _colorAlpha = 0.20;

  static const List<Color> _resourceColors = [
    Color(0xFFE5B53B), // Wheat (Golden Amber)
    Color(0xFF88B664), // Sheep (Pasture Green)
    Color(0xFF7A8B99), // Ore (Mountain Slate)
    Color(0xFFD16B47), // Brick (Terracotta Clay)
    Color(0xFF4E7D52), // Wood (Forest Pine)
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final Paint bgPaint = Paint()..color = _baseColor;
    canvas.drawRect(Offset.zero & size, bgPaint);

    const double radius = 34.0;
    final double hexWidth = math.sqrt(3) * radius;
    const double vertDist = 1.5 * radius;

    final Paint fillPaint = Paint()..style = PaintingStyle.fill;
    final Paint strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = const Color(0xFFC63B12).withValues(alpha: 0.16)
      ..strokeWidth = 1.2;

    int row = 0;
    for (double y = 0; y < size.height + radius * 2; y += vertDist) {
      int col = 0;
      final double offsetX = (row % 2 == 1) ? hexWidth / 2 : 0.0;
      for (double x = -hexWidth / 2 + offsetX;
          x < size.width + hexWidth;
          x += hexWidth) {
        final Path hexPath = _createPointyHexPath(x, y, radius);

        // Variant A: Full Mosaic of all 5 Catan resources
        final int colorIndex = (row * 3 + col * 2) % _resourceColors.length;
        fillPaint.color =
            _resourceColors[colorIndex].withValues(alpha: _colorAlpha);

        canvas.drawPath(hexPath, fillPaint);
        canvas.drawPath(hexPath, strokePaint);

        col++;
      }
      row++;
    }
  }

  Path _createPointyHexPath(double cx, double cy, double r) {
    final Path path = Path();
    for (int i = 0; i < 6; i++) {
      final double angle = (math.pi / 3) * i - (math.pi / 6);
      final double x = cx + r * math.cos(angle);
      final double y = cy + r * math.sin(angle);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
