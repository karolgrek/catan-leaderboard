import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../constants/app_colors.dart';
import '../../constants/app_constants.dart';

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

  @override
  void paint(Canvas canvas, Size size) {
    final Paint bgPaint = Paint()..color = AppColors.parchmentBase;
    canvas.drawRect(Offset.zero & size, bgPaint);

    const double radius = AppConstants.hexRadius;
    final double hexWidth = math.sqrt(3) * radius;
    const double vertDist = 1.5 * radius;

    final Paint fillPaint = Paint()..style = PaintingStyle.fill;
    final Paint strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..color = AppColors.primaryBrick.withValues(
        alpha: AppConstants.hexStrokeAlpha,
      )
      ..strokeWidth = AppConstants.hexStrokeWidth;

    int row = 0;
    for (double y = 0; y < size.height + radius * 2; y += vertDist) {
      int col = 0;
      final double offsetX = (row % 2 == 1) ? hexWidth / 2 : 0.0;
      for (double x = -hexWidth / 2 + offsetX;
          x < size.width + hexWidth;
          x += hexWidth) {
        final Path hexPath = _createPointyHexPath(x, y, radius);

        final int colorIndex =
            (row * 3 + col * 2) % AppColors.resourcePalette.length;
        fillPaint.color = AppColors.resourcePalette[colorIndex].withValues(
          alpha: AppConstants.hexColorAlpha,
        );

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
