import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A circular drag control with infinite rotatability and adjustable sensitivity.
/// - sensitivity > 1 = slower (divide raw drag by this)
/// - sensitivity < 1 = faster (multiply raw drag by this)
class InfiniteCircularAngleDrag extends StatefulWidget {
  /// Size of the square widget.
  final double size;

  /// Thickness of the ring.
  final double strokeWidth;

  /// Radius of the draggable handle.
  final double handleRadius;

  /// Initial total angle in degrees (can be >360 or negative; will be wrapped).
  final double initialAngle;

  /// Drag sensitivity: how many pixels of drag = 1° of rotation.
  /// e.g. 3.0 means you must drag 3px for each 1°.
  final double sensitivity;

  /// Called with the **total** angle in degrees, unbounded internally but wrapped 0–360 on the callback.
  final ValueChanged<double> onAngleChanged;

  /// Ring color.
  final Color ringColor;

  /// Handle color.
  final Color handleColor;

  const InfiniteCircularAngleDrag({
    Key? key,
    this.size = 200,
    this.strokeWidth = 4,
    this.handleRadius = 10,
    this.initialAngle = 0,
    this.sensitivity = 1.0,
    required this.onAngleChanged,
    this.ringColor = Colors.deepPurple,
    this.handleColor = Colors.deepPurple,
  }) : super(key: key);

  @override
  _InfiniteCircularAngleDragState createState() =>
      _InfiniteCircularAngleDragState();
}

class _InfiniteCircularAngleDragState extends State<InfiniteCircularAngleDrag> {
  late double _accumulatedAngle; // full rotation, unwrapped
  late double _lastPointerAngle; // in degrees

  @override
  void initState() {
    super.initState();
    // seed accumulator with initialAngle
    _accumulatedAngle = widget.initialAngle;
    // dummy init; will be set on first touch
    _lastPointerAngle = 0;
  }

  double get _visibleAngle {
    // wrap into 0–360
    var v = _accumulatedAngle % 360;
    return v < 0 ? v + 360 : v;
  }

  void _handlePanStart(DragStartDetails details) {
    final center = Offset(widget.size / 2, widget.size / 2);
    final pos = details.localPosition;
    _lastPointerAngle =
        math.atan2(pos.dy - center.dy, pos.dx - center.dx) * 180 / math.pi;
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    final center = Offset(widget.size / 2, widget.size / 2);
    final pos = details.localPosition;
    final currentPointerAngle =
        math.atan2(pos.dy - center.dy, pos.dx - center.dx) * 180 / math.pi;

    // compute raw delta, correcting for wrap‑around
    double rawDelta = currentPointerAngle - _lastPointerAngle;
    if (rawDelta > 180) rawDelta -= 360;
    if (rawDelta < -180) rawDelta += 360;

    // apply sensitivity (pixels per degree)
    double deltaDegrees = rawDelta / widget.sensitivity;

    _accumulatedAngle += deltaDegrees;
    _lastPointerAngle = currentPointerAngle;

    widget.onAngleChanged(_visibleAngle);
    setState(() {}); // repaint handle at new angle
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onPanStart: _handlePanStart,
      onPanUpdate: _handlePanUpdate,
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(
          painter: _RingAndHandlePainter(
            angle: _visibleAngle,
            ringColor: widget.ringColor,
            handleColor: widget.handleColor,
            strokeWidth: widget.strokeWidth,
            handleRadius: widget.handleRadius,
          ),
        ),
      ),
    );
  }
}

class _RingAndHandlePainter extends CustomPainter {
  final double angle;
  final Color ringColor, handleColor;
  final double strokeWidth, handleRadius;

  _RingAndHandlePainter({
    required this.angle,
    required this.ringColor,
    required this.handleColor,
    required this.strokeWidth,
    required this.handleRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // draw semi‑transparent ring
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = ringColor.withValues(alpha: 0.3);
    canvas.drawCircle(center, radius, ringPaint);

    // draw handle at ‘angle’
    final rad = angle * math.pi / 180;
    final handleCenter = Offset(
      center.dx + math.cos(rad) * radius,
      center.dy + math.sin(rad) * radius,
    );
    final handlePaint = Paint()..color = handleColor;
    canvas.drawCircle(handleCenter, handleRadius, handlePaint);
  }

  @override
  bool shouldRepaint(covariant _RingAndHandlePainter old) {
    return old.angle != angle ||
        old.strokeWidth != strokeWidth ||
        old.handleRadius != handleRadius ||
        old.ringColor != ringColor ||
        old.handleColor != handleColor;
  }
}
