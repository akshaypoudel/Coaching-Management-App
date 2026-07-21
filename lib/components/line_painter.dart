import 'package:flutter/material.dart';

class LinePainter extends CustomPainter {
  final List<double> values;

  LinePainter({required this.values});

  final List<String> months = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Dec",
  ];

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;

    /// MAIN LINE
    final linePaint = Paint()
      ..color = Colors.deepPurple
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    /// GLOW EFFECT
    final glowPaint = Paint()
      ..color = Colors.deepPurple.withValues(alpha: 0.15)
      ..strokeWidth = 10
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);

    /// GRID
    final gridPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.12)
      ..strokeWidth = 1;

    for (double i = 0; i <= size.height; i += 30) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), gridPaint);
    }

    final path = Path();

    /// HIGHEST VALUE
    final maxValue = values.reduce((a, b) => a > b ? a : b);

    /// SPACE BETWEEN POINTS
    final spacing = size.width / (values.length - 1);

    for (int i = 0; i < values.length; i++) {
      final x = spacing * i;

      /// CONVERT VALUE TO GRAPH HEIGHT
      final y = size.height - ((values[i] / maxValue) * size.height);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      /// POINT DOTS
      canvas.drawCircle(Offset(x, y), 5, Paint()..color = Colors.deepPurple);

      final textSpan = TextSpan(
        text: months[i],
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      textPainter.paint(
        canvas,
        Offset(x - (textPainter.width / 2), size.height + 8),
      );
    }

    /// DRAW GLOW
    canvas.drawPath(path, glowPaint);

    /// DRAW MAIN LINE
    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant LinePainter oldDelegate) {
    return oldDelegate.values != values;
  }
}
