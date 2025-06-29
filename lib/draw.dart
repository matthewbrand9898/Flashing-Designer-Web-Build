import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import 'helper_functions.dart';

class Draw extends CustomPainter {
  Draw({
    required this.points,
    required this.bottomNavbarIndex,
    required this.lengthPositions,
    required this.lengthPositions_Offsets,
    required this.anglePositions_Offsets,
    required this.anglePositions,
    required this.scaleFactor,
    required this.boundingBox,
    required this.showCFUI,
    required this.cF1_state,
    required this.cF2_state,
    required this.cF1_position,
    required this.cF1_length,
    required this.cF2_position,
    required this.cF2_length,
    required this.Hide_90_45Angles,
    required this.TaperedState,
    required this.Tapered,
  });
  final int TaperedState;
  final bool Tapered;
  final Rect boundingBox;
  final List<Offset> points;
  final List<Offset> lengthPositions;
  final List<Offset> lengthPositions_Offsets;
  final List<Offset> anglePositions;
  final List<Offset> anglePositions_Offsets;
  final bool showCFUI;
  final int cF1_state;
  final Offset cF1_position;
  final double cF1_length;
  final int cF2_state;
  final Offset cF2_position;
  final double cF2_length;
  final int bottomNavbarIndex;
  final double scaleFactor;
  final bool Hide_90_45Angles;

  void drawDashedLine({
    required Canvas canvas,
    required Offset p1,
    required Offset p2,
    required Iterable<double> pattern,
    required Paint paint,
  }) {
    assert(pattern.length.isEven);
    final distance = (p2 - p1).distance;
    final normalizedPattern = pattern.map((width) => width / distance).toList();
    final points = <Offset>[];
    double t = 0;
    int i = 0;
    while (t < 1) {
      points.add(Offset.lerp(p1, p2, t)!);
      t += normalizedPattern[i++]; // dashWidth
      points.add(Offset.lerp(p1, p2, t.clamp(0, 1))!);
      t += normalizedPattern[i++]; // dashSpace
      i %= normalizedPattern.length;
    }
    canvas.drawPoints(PointMode.lines, points, paint);
  }

  @override
  void paint(Canvas canvas, Size size) {
    TextSpan cf1TextSpan = TextSpan(
      text: cF1_state == 1 ? "CF L" : "CF R",
      style: const TextStyle(
          fontFamily: "OpenSans", color: Colors.white, fontSize: 20),
    );

    final cf1Text = TextPainter(
      textAlign: TextAlign.start,
      text: cf1TextSpan,
      textDirection: TextDirection.ltr,
      textScaler: TextScaler.linear((1 / scaleFactor)),
    );
    cf1Text.layout(
      minWidth: 0,
      maxWidth: size.width,
    );

    TextSpan cf2TextSpan = TextSpan(
      text: cF2_state == 1 ? "CF L" : "CF R",
      style: const TextStyle(
          fontFamily: "OpenSans", color: Colors.white, fontSize: 20),
    );

    final cf2Text = TextPainter(
      textAlign: TextAlign.start,
      text: cf2TextSpan,
      textDirection: TextDirection.ltr,
      textScaler: TextScaler.linear((1 / scaleFactor)),
    );
    cf2Text.layout(
      minWidth: 0,
      maxWidth: size.width,
    );

    Paint linesPaint = Paint();
    linesPaint.style = PaintingStyle.stroke;
    linesPaint.color = Colors.grey.shade600;
    linesPaint.strokeWidth = clampDouble(4.0 / scaleFactor, 2.5, 100);
    linesPaint.strokeCap = StrokeCap.round;

    Paint taperPaint = Paint();
    taperPaint.style = PaintingStyle.stroke;
    taperPaint.color = Colors.grey.shade600;
    taperPaint.strokeWidth = clampDouble(2.0 / scaleFactor, 1, 100);
    taperPaint.strokeCap = StrokeCap.round;

    Paint boxPaint = Paint();
    boxPaint.color = Colors.grey.shade100;
    boxPaint.strokeWidth = clampDouble(4.0 / scaleFactor, 2.5, 100);

    Paint pointsPaint = Paint();
    pointsPaint.color = Colors.deepPurple.shade500;
    pointsPaint.strokeWidth = 1.0;

    Paint pointerPaint = Paint();
    pointerPaint.color = Colors.deepPurple.shade500;
    pointsPaint.strokeWidth = 1.0;

    Paint cFPaint1 = Paint();
    cFPaint1.color = Colors.deepPurple.shade500;
    cFPaint1.strokeWidth = clampDouble(4.0 / scaleFactor, 2.5, 100);

    cFPaint1.style = cF1_state > 0 ? PaintingStyle.fill : PaintingStyle.stroke;

    Paint cFPaint2 = Paint();
    cFPaint2.color = Colors.deepPurple.shade500;
    cFPaint2.strokeWidth = clampDouble(4.0 / scaleFactor, 2.5, 100);

    cFPaint2.style = cF2_state > 0 ? PaintingStyle.fill : PaintingStyle.stroke;

    if (points.length > 1 && cF1_state > 0) {
      Offset cf_1NormalVector =
          calculatePerpendicularVector(points[0], points[1]);

      Offset cf_1Scaler = cF1_state == 1
          ? Offset(
              cf_1NormalVector.dx *
                  clampDouble(8 * (1 / scaleFactor), 4, double.infinity),
              cf_1NormalVector.dy *
                  clampDouble(8 * (1 / scaleFactor), 4, double.infinity))
          : -Offset(
              cf_1NormalVector.dx *
                  clampDouble(8 * (1 / scaleFactor), 4, double.infinity),
              cf_1NormalVector.dy *
                  clampDouble(8 * (1 / scaleFactor), 4, double.infinity));

      Offset cF_1Center = cF1_state == 1
          ? points[0] +
              (Offset(
                  cf_1NormalVector.dx *
                      clampDouble(4 * (1 / scaleFactor), 2, double.infinity),
                  cf_1NormalVector.dy *
                      clampDouble(4 * (1 / scaleFactor), 2, double.infinity)))
          : points[0] -
              (Offset(
                  cf_1NormalVector.dx *
                      clampDouble(4 * (1 / scaleFactor), 2, double.infinity),
                  cf_1NormalVector.dy *
                      clampDouble(4 * (1 / scaleFactor), 2, double.infinity)));
      Offset cF_1End = cF1_state == 1
          ? points[0] +
              (Offset(
                  cf_1NormalVector.dx *
                      clampDouble(8 * (1 / scaleFactor), 4, double.infinity),
                  cf_1NormalVector.dy *
                      clampDouble(8 * (1 / scaleFactor), 4, double.infinity)))
          : points[0] -
              (Offset(
                  cf_1NormalVector.dx *
                      clampDouble(8 * (1 / scaleFactor), 4, double.infinity),
                  cf_1NormalVector.dy *
                      clampDouble(8 * (1 / scaleFactor), 4, double.infinity)));

      Offset CenterDir =
          calculateNormalizedDirectionVector(cF_1Center, points[0]);

      double startAngle = atan2(CenterDir.dy, CenterDir.dx);

      canvas.drawArc(
        Rect.fromCircle(
            center: cF_1Center,
            radius: clampDouble(4 * (1 / scaleFactor), 2, double.infinity)),
        startAngle,
        cF1_state == 1 ? -pi : pi,
        false,
        linesPaint,
      );
      canvas.drawLine(
          cF_1End,
          cF_1End +
              Offset(
                  calculateNormalizedDirectionVector(points[0], points[1]).dx *
                      (cF1_length * 2.6666666666666666666666666666667),
                  calculateNormalizedDirectionVector(points[0], points[1]).dy *
                      (cF1_length * 2.6666666666666666666666666666667)),
          linesPaint);

      if (bottomNavbarIndex == 1) {
        Offset midPoint = calculateMidpoint(
            cF_1End,
            cF_1End +
                Offset(
                    calculateNormalizedDirectionVector(points[0], points[1])
                            .dx *
                        (cF1_length * 2.6666666666666666666666666666667),
                    calculateNormalizedDirectionVector(points[0], points[1])
                            .dy *
                        (cF1_length * 2.6666666666666666666666666666667)));

        double xOffsetValue = clampDouble(
            (cF1_position.dx +
                cf_1Scaler.dx -
                Offset(
                        (25 *
                            ((1 / -scaleFactor) *
                                calculateNormalizedDirectionVector(
                                        midPoint, cF1_position + cf_1Scaler)
                                    .dx)),
                        (25 *
                            ((1 / -scaleFactor) *
                                calculateNormalizedDirectionVector(
                                        midPoint, cF1_position + cf_1Scaler)
                                    .dy)))
                    .dx -
                midPoint.dx),
            -7,
            7);

        Offset pointDir = calculateNormalizedDirectionVector(
            cF1_position +
                cf_1Scaler -
                Offset(
                    (25 *
                        ((1 / -scaleFactor) *
                            calculateNormalizedDirectionVector(
                                    midPoint, cF1_position + cf_1Scaler)
                                .dx)),
                    (25 *
                        ((1 / -scaleFactor) *
                            calculateNormalizedDirectionVector(
                                    midPoint, cF1_position + cf_1Scaler)
                                .dy))) -
                Offset(xOffsetValue / scaleFactor, 0),
            midPoint);
        double angle = atan2(pointDir.dy, pointDir.dx);

        angle = (angle * 180 / pi) - 90;
        double pointLength = 20;

        Offset cf_1PointerDir = calculateNormalizedDirectionVector(
            midPoint, cF1_position + cf_1Scaler);
        Offset rotatedTop = rotatePoint(
            cF1_position +
                cf_1Scaler -
                Offset((25 * ((1 / -scaleFactor) * cf_1PointerDir.dx)),
                    (25 * ((1 / -scaleFactor) * cf_1PointerDir.dy))) -
                Offset(xOffsetValue / scaleFactor, 0) +
                Offset(0, pointLength / scaleFactor),
            cF1_position +
                cf_1Scaler -
                Offset((25 * ((1 / -scaleFactor) * cf_1PointerDir.dx)),
                    (25 * ((1 / -scaleFactor) * cf_1PointerDir.dy))) -
                Offset(xOffsetValue / scaleFactor, 0),
            angle);
        Offset rotatedLeft = rotatePoint(
            cF1_position +
                cf_1Scaler -
                Offset((25 * ((1 / -scaleFactor) * cf_1PointerDir.dx)),
                    (25 * ((1 / -scaleFactor) * cf_1PointerDir.dy))) -
                Offset(xOffsetValue / scaleFactor, 0) +
                Offset(-13 / scaleFactor, 0),
            cF1_position +
                cf_1Scaler -
                Offset((25 * ((1 / -scaleFactor) * cf_1PointerDir.dx)),
                    (25 * ((1 / -scaleFactor) * cf_1PointerDir.dy))) -
                Offset(xOffsetValue / scaleFactor, 0),
            angle);
        Offset rotatedRight = rotatePoint(
            cF1_position +
                cf_1Scaler -
                Offset((25 * ((1 / -scaleFactor) * cf_1PointerDir.dx)),
                    (25 * ((1 / -scaleFactor) * cf_1PointerDir.dy))) -
                Offset(xOffsetValue / scaleFactor, 0) +
                Offset(13 / scaleFactor, 0),
            cF1_position +
                cf_1Scaler -
                Offset((25 * ((1 / -scaleFactor) * cf_1PointerDir.dx)),
                    (25 * ((1 / -scaleFactor) * cf_1PointerDir.dy))) -
                Offset(xOffsetValue / scaleFactor, 0),
            angle);

        var path = Path();
        path.moveTo(rotatedTop.dx, rotatedTop.dy);
        path.lineTo(rotatedLeft.dx, rotatedLeft.dy);
        path.lineTo(rotatedRight.dx, rotatedRight.dy);
        path.close();

        canvas.drawPath(path, pointerPaint);
      }
    }

    if (points.length > 1 && cF2_state > 0) {
      Offset cf_2NormalVector = calculatePerpendicularVector(
          points[points.length - 1], points[points.length - 2]);

      Offset cf_2Scaler = cF2_state == 1
          ? Offset(
              cf_2NormalVector.dx *
                  clampDouble(8 * (1 / scaleFactor), 4, double.infinity),
              cf_2NormalVector.dy *
                  clampDouble(8 * (1 / scaleFactor), 4, double.infinity))
          : -Offset(
              cf_2NormalVector.dx *
                  clampDouble(8 * (1 / scaleFactor), 4, double.infinity),
              cf_2NormalVector.dy *
                  clampDouble(8 * (1 / scaleFactor), 4, double.infinity));

      Offset cF_2Center = cF2_state == 1
          ? points[points.length - 1] +
              (Offset(
                  cf_2NormalVector.dx *
                      clampDouble(4 * (1 / scaleFactor), 2, double.infinity),
                  cf_2NormalVector.dy *
                      clampDouble(4 * (1 / scaleFactor), 2, double.infinity)))
          : points[points.length - 1] -
              (Offset(
                  cf_2NormalVector.dx *
                      clampDouble(4 * (1 / scaleFactor), 2, double.infinity),
                  cf_2NormalVector.dy *
                      clampDouble(4 * (1 / scaleFactor), 2, double.infinity)));
      Offset cF_2End = cF2_state == 1
          ? points[points.length - 1] +
              (Offset(
                  cf_2NormalVector.dx *
                      clampDouble(8 * (1 / scaleFactor), 4, double.infinity),
                  cf_2NormalVector.dy *
                      clampDouble(8 * (1 / scaleFactor), 4, double.infinity)))
          : points[points.length - 1] -
              (Offset(
                  cf_2NormalVector.dx *
                      clampDouble(8 * (1 / scaleFactor), 4, double.infinity),
                  cf_2NormalVector.dy *
                      clampDouble(8 * (1 / scaleFactor), 4, double.infinity)));

      Offset CenterDir = calculateNormalizedDirectionVector(
          cF_2Center, points[points.length - 1]);

      double startAngle = atan2(CenterDir.dy, CenterDir.dx);

      canvas.drawArc(
        Rect.fromCircle(
            center: cF_2Center,
            radius: clampDouble(4 * (1 / scaleFactor), 2, double.infinity)),
        startAngle,
        cF2_state == 1 ? -pi : pi,
        false,
        linesPaint,
      );
      canvas.drawLine(
          cF_2End,
          cF_2End +
              Offset(
                  calculateNormalizedDirectionVector(points[points.length - 1],
                              points[points.length - 2])
                          .dx *
                      (cF2_length * 2.6666666666666666666666666666667),
                  calculateNormalizedDirectionVector(points[points.length - 1],
                              points[points.length - 2])
                          .dy *
                      (cF2_length * 2.6666666666666666666666666666667)),
          linesPaint);

      if (bottomNavbarIndex == 1) {
        Offset midPoint = calculateMidpoint(
            cF_2End,
            cF_2End +
                Offset(
                    calculateNormalizedDirectionVector(
                                points[points.length - 1],
                                points[points.length - 2])
                            .dx *
                        (cF2_length * 2.6666666666666666666666666666667),
                    calculateNormalizedDirectionVector(
                                points[points.length - 1],
                                points[points.length - 2])
                            .dy *
                        (cF2_length * 2.6666666666666666666666666666667)));

        double xOffsetValue = clampDouble(
            (cF2_position.dx +
                cf_2Scaler.dx -
                Offset(
                        (25 *
                            ((1 / -scaleFactor) *
                                calculateNormalizedDirectionVector(
                                        midPoint, cF2_position + cf_2Scaler)
                                    .dx)),
                        (25 *
                            ((1 / -scaleFactor) *
                                calculateNormalizedDirectionVector(
                                        midPoint, cF2_position + cf_2Scaler)
                                    .dy)))
                    .dx -
                midPoint.dx),
            -7,
            7);

        Offset pointDir = calculateNormalizedDirectionVector(
            cF2_position +
                cf_2Scaler -
                Offset(
                    (25 *
                        ((1 / -scaleFactor) *
                            calculateNormalizedDirectionVector(
                                    midPoint, cF2_position + cf_2Scaler)
                                .dx)),
                    (25 *
                        ((1 / -scaleFactor) *
                            calculateNormalizedDirectionVector(
                                    midPoint, cF2_position + cf_2Scaler)
                                .dy))) -
                Offset(xOffsetValue / scaleFactor, 0),
            midPoint);
        double angle = atan2(pointDir.dy, pointDir.dx);

        angle = (angle * 180 / pi) - 90;
        double pointLength = 20;

        Offset cf_2PointerDir = calculateNormalizedDirectionVector(
            midPoint, cF2_position + cf_2Scaler);

        Offset rotatedTop = rotatePoint(
            cF2_position +
                cf_2Scaler -
                Offset((25 * ((1 / -scaleFactor) * cf_2PointerDir.dx)),
                    (25 * ((1 / -scaleFactor) * cf_2PointerDir.dy))) -
                Offset(xOffsetValue / scaleFactor, 0) +
                Offset(0, (pointLength / scaleFactor)),
            cF2_position +
                cf_2Scaler -
                Offset((25 * ((1 / -scaleFactor) * cf_2PointerDir.dx)),
                    (25 * ((1 / -scaleFactor) * cf_2PointerDir.dy))) -
                Offset(xOffsetValue / scaleFactor, 0),
            angle);
        Offset rotatedLeft = rotatePoint(
            cF2_position +
                cf_2Scaler -
                Offset((25 * ((1 / -scaleFactor) * cf_2PointerDir.dx)),
                    (25 * ((1 / -scaleFactor) * cf_2PointerDir.dy))) -
                Offset(xOffsetValue / scaleFactor, 0) +
                Offset(-13 / scaleFactor, 0),
            cF2_position +
                cf_2Scaler -
                Offset((25 * ((1 / -scaleFactor) * cf_2PointerDir.dx)),
                    (25 * ((1 / -scaleFactor) * cf_2PointerDir.dy))) -
                Offset(xOffsetValue / scaleFactor, 0),
            angle);
        Offset rotatedRight = rotatePoint(
            cF2_position +
                cf_2Scaler -
                Offset((25 * ((1 / -scaleFactor) * cf_2PointerDir.dx)),
                    (25 * ((1 / -scaleFactor) * cf_2PointerDir.dy))) -
                Offset(xOffsetValue / scaleFactor, 0) +
                Offset(13 / scaleFactor, 0),
            cF2_position +
                cf_2Scaler -
                Offset((25 * ((1 / -scaleFactor) * cf_2PointerDir.dx)),
                    (25 * ((1 / -scaleFactor) * cf_2PointerDir.dy))) -
                Offset(xOffsetValue / scaleFactor, 0),
            angle);

        var path = Path();
        path.moveTo(rotatedTop.dx, rotatedTop.dy);
        path.lineTo(rotatedLeft.dx, rotatedLeft.dy);
        path.lineTo(rotatedRight.dx, rotatedRight.dy);
        path.close();

        canvas.drawPath(path, pointerPaint);
      }
    }

    for (int i = 0; i < points.length; i++) {
      if (i < points.length - 1) {
        canvas.drawLine(points[i], points[i + 1], linesPaint);
      }

      if (bottomNavbarIndex == 1 && Tapered) {
        if (TaperedState == 1) {
          drawDashedLine(
              canvas: canvas,
              p1: points[i],
              p2: Offset(points[i].dx - 190, points[i].dy + 100),
              pattern: [20, 10],
              paint: taperPaint);
        } else {
          drawDashedLine(
              canvas: canvas,
              p1: points[i],
              p2: Offset(points[i].dx + 190, points[i].dy - 100),
              pattern: [20, 10],
              paint: taperPaint);
        }
      }
    }
    for (int i = 0; i < points.length; i++) {
      canvas.drawCircle(
          points[i], clampDouble(2.5 / scaleFactor, 1.5, 100), pointsPaint);
    }
    if (bottomNavbarIndex == 1) {
      for (int i = 0; i < lengthPositions.length; i++) {
        Offset midPoint = calculateMidpoint(points[i], points[i + 1]);
        double xOffsetValue = clampDouble(
            ((lengthPositions[i].dx - lengthPositions_Offsets[i].dx) -
                midPoint.dx),
            -5,
            5);
        Offset pointDir = calculateNormalizedDirectionVector(
            lengthPositions[i] -
                lengthPositions_Offsets[i] -
                Offset(xOffsetValue / scaleFactor, 0),
            midPoint);
        double angle = atan2(pointDir.dy, pointDir.dx);

        angle = (angle * 180 / pi) - 90;
        double pointLength = 20;

        Offset rotatedTop = rotatePoint(
            lengthPositions[i] -
                lengthPositions_Offsets[i] -
                Offset(xOffsetValue / scaleFactor, 0) +
                Offset(0, pointLength / scaleFactor),
            lengthPositions[i] -
                lengthPositions_Offsets[i] -
                Offset(xOffsetValue / scaleFactor, 0),
            angle);
        Offset rotatedLeft = rotatePoint(
            lengthPositions[i] -
                lengthPositions_Offsets[i] -
                Offset(xOffsetValue / scaleFactor, 0) +
                Offset(-12 / scaleFactor, 0),
            lengthPositions[i] -
                lengthPositions_Offsets[i] -
                Offset(xOffsetValue / scaleFactor, 0),
            angle);
        Offset rotatedRight = rotatePoint(
            lengthPositions[i] -
                lengthPositions_Offsets[i] -
                Offset(xOffsetValue / scaleFactor, 0) +
                Offset(12 / scaleFactor, 0),
            lengthPositions[i] -
                lengthPositions_Offsets[i] -
                Offset(xOffsetValue / scaleFactor, 0),
            angle);

        var path = Path();
        path.moveTo(rotatedTop.dx, rotatedTop.dy);
        path.lineTo(rotatedLeft.dx, rotatedLeft.dy);
        path.lineTo(rotatedRight.dx, rotatedRight.dy);
        path.close();

        canvas.drawPath(path, pointerPaint);
      }

      for (int i = 0; i < anglePositions.length; i++) {
        int HideAngleVal =
            calculateAngle(points[i], points[i + 1], points[i + 2]).round();

        if (HideAngleVal == 45 && Hide_90_45Angles ||
            HideAngleVal == 90 && Hide_90_45Angles ||
            HideAngleVal == 135 && Hide_90_45Angles) {
          continue;
        }
        double xOffsetValue = clampDouble(
            ((anglePositions[i].dx - anglePositions_Offsets[i].dx) -
                points[i + 1].dx),
            -5,
            5);
        Offset pointDir = calculateNormalizedDirectionVector(
            anglePositions[i] -
                anglePositions_Offsets[i] -
                Offset(xOffsetValue / scaleFactor, 0),
            points[i + 1]);
        double angle = atan2(pointDir.dy, pointDir.dx);

        double lengthScaler = cos(angle - 1.5708);
        angle = (angle * 180 / pi) - 90;
        double pointLength = 24;

        lengthScaler > 0
            ? pointLength = 24 - (lengthScaler * 3)
            : pointLength = 24 + (lengthScaler * 3);
        Offset rotatedTop = rotatePoint(
            anglePositions[i] -
                anglePositions_Offsets[i] -
                Offset(xOffsetValue / scaleFactor, 0) +
                Offset(0, pointLength / scaleFactor),
            anglePositions[i] -
                anglePositions_Offsets[i] -
                Offset(xOffsetValue / scaleFactor, 0),
            angle);
        Offset rotatedLeft = rotatePoint(
            anglePositions[i] -
                anglePositions_Offsets[i] -
                Offset(xOffsetValue / scaleFactor, 0) +
                Offset(-12.8 / scaleFactor, 0),
            anglePositions[i] -
                anglePositions_Offsets[i] -
                Offset(xOffsetValue / scaleFactor, 0),
            angle);
        Offset rotatedRight = rotatePoint(
            anglePositions[i] -
                anglePositions_Offsets[i] -
                Offset(xOffsetValue / scaleFactor, 0) +
                Offset(12.8 / scaleFactor, 0),
            anglePositions[i] -
                anglePositions_Offsets[i] -
                Offset(xOffsetValue / scaleFactor, 0),
            angle);

        var path = Path();
        path.moveTo(rotatedTop.dx, rotatedTop.dy);
        path.lineTo(rotatedLeft.dx, rotatedLeft.dy);
        path.lineTo(rotatedRight.dx, rotatedRight.dy);
        path.close();

        canvas.drawPath(path, pointerPaint);
      }
    }

    if (showCFUI && points.length > 1) {
      Offset cFdir_1 = calculateNormalizedDirectionVector(points[1], points[0]);
      cFdir_1 *= 25 + (30 / scaleFactor);

      canvas.drawCircle(points[0] + cFdir_1, 25 * (1 / scaleFactor), cFPaint1);

      if (cF1_state > 0) {
        cf1Text.paint(
            canvas,
            points[0] +
                cFdir_1 -
                Offset(cf1Text.width / 2, cf1Text.height / 2));
      }

      Offset cFdir_2 = calculateNormalizedDirectionVector(
          points[points.length - 2], points[points.length - 1]);
      cFdir_2 *= 25 + (30 / scaleFactor);

      canvas.drawCircle(points[points.length - 1] + cFdir_2,
          25 * (1 / scaleFactor), cFPaint2);

      if (cF2_state > 0) {
        cf2Text.paint(
            canvas,
            points[points.length - 1] +
                cFdir_2 -
                Offset(cf2Text.width / 2, cf2Text.height / 2));
      }
    }
  }

  @override
  bool shouldRepaint(Draw oldDelegate) => true;
}
