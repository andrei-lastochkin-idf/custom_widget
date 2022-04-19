import 'dart:math';
import 'package:flutter/material.dart';

class CircleHighlightedDiagram extends StatefulWidget {
  const CircleHighlightedDiagram({
    Key? key,
    required this.height,
    required this.highlightedPercent,
  }) : super(key: key);

  final double height;
  final double highlightedPercent;

  @override
  _CircleHighlightedDiagramState createState() =>
      _CircleHighlightedDiagramState();
}

class _CircleHighlightedDiagramState extends State<CircleHighlightedDiagram>
    with TickerProviderStateMixin {
  late final Animation<double> animation;
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    animation = Tween(begin: 0.0, end: 360.0).animate(controller);

    controller.forward();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: animation,
        builder: (BuildContext context, Widget? child) {
          return Stack(
            children: [
              CustomPaint(
                child: SizedBox(
                  height: widget.height,
                  width: widget.height,
                ),
                painter: CommonSectionPainter(animation.value),
              ),
              CustomPaint(
                child: SizedBox(
                  height: widget.height,
                  width: widget.height,
                ),
                painter: HighlightedSectionPainter(
                  widget.highlightedPercent,
                  animation.value,
                ),
              ),
            ],
          );
        },
      );

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }
}

class HighlightedSectionPainter extends CustomPainter {
  final double percent;
  final double processAngle;

  HighlightedSectionPainter(
    this.percent,
    this.processAngle,
  );

  final arcStyle = Paint()
    ..strokeCap = StrokeCap.round
    ..style = PaintingStyle.fill
    ..color = Colors.red;

  final strokeStyle = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..color = Colors.red
    ..strokeWidth = 10;

  final labelStyle = const TextStyle(
    color: Colors.white,
    fontSize: 16,
  );

  @override
  void paint(Canvas canvas, Size size) {
    final sweepAngle = 0.01 * percent * processAngle * pi / 180;

    final center = Offset(size.width / 2, size.height / 2);

    final diameter = size.height;

    _drawArc(
      canvas,
      center,
      diameter,
      sweepAngle,
    );

    _drawRoundedBorders(
      canvas,
      center,
      diameter,
      sweepAngle,
    );

    _drawLabel(
      canvas,
      center,
      diameter,
      sweepAngle,
      percent.toString(),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  void _drawArc(
    Canvas canvas,
    Offset center,
    double diameter,
    double sweepAngle,
  ) {
    final rect = Rect.fromCenter(
      center: center,
      width: diameter,
      height: diameter,
    );

    canvas.drawArc(
      rect,
      3 * pi / 2,
      sweepAngle,
      true,
      arcStyle,
    );
  }

  void _drawRoundedBorders(
    Canvas canvas,
    Offset center,
    double diameter,
    double sweepAngle,
  ) {
    final strokeWidth = strokeStyle.strokeWidth;

    final dx1 = (diameter + strokeWidth) / 2 * cos(-pi / 2);
    final dy1 = (diameter - strokeWidth) / 2 * sin(-pi / 2);
    final p1 = center + Offset(dx1, dy1);

    final dx2 = (diameter - strokeWidth) / 2 * cos(-pi / 2 + sweepAngle);
    final dy2 = (diameter - strokeWidth) / 2 * sin(-pi / 2 + sweepAngle);
    final p2 = center + Offset(dx2, dy2);

    canvas.drawLine(
      center,
      p1,
      strokeStyle,
    );
    canvas.drawLine(
      center,
      p2,
      strokeStyle,
    );
  }

  TextPainter _getTextPainter(
    String text,
    TextStyle style,
    double maxWidth,
    TextAlign align,
  ) {
    final span = TextSpan(
      text: text,
      style: style,
    );

    final textPainter = TextPainter(
      text: span,
      textDirection: TextDirection.ltr,
      textAlign: align,
    );

    textPainter.layout(
      minWidth: 0,
      maxWidth: maxWidth,
    );

    return textPainter;
  }

  void _drawLabel(
    Canvas canvas,
    Offset center,
    double diameter,
    double sweepAngle,
    String label,
  ) {
    final dx = 0.25 * diameter * cos(-pi / 2 + sweepAngle / 2);
    final dy = 0.25 * diameter * sin(-pi / 2 + sweepAngle / 2);
    var position = center + Offset(dx, dy);

    final textPainter = _getTextPainter(
      label,
      labelStyle,
      0.5 * diameter,
      TextAlign.center,
    );

    position =
        position + Offset(-textPainter.width / 2.0, -textPainter.height / 2.0);

    textPainter.paint(
      canvas,
      position,
    );
  }
}

class CommonSectionPainter extends CustomPainter {
  final double processAngle;

  CommonSectionPainter(this.processAngle);

  final arcStyle = Paint()
    ..style = PaintingStyle.fill
    ..color = Colors.white;

  @override
  void paint(Canvas canvas, Size size) {
    final sweepAngle = processAngle * pi / 180;

    final center = Offset(size.width / 2, size.height / 2);

    final diameter = size.height * 0.9;

    _drawArc(
      canvas,
      center,
      diameter,
      sweepAngle,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;

  void _drawArc(
    Canvas canvas,
    Offset center,
    double diameter,
    double sweepAngle,
  ) {
    final rect = Rect.fromCenter(
      center: center,
      width: diameter,
      height: diameter,
    );

    canvas.drawArc(
      rect,
      -pi / 2,
      sweepAngle,
      true,
      arcStyle,
    );
  }
}
