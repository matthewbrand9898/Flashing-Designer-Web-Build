import 'dart:math' as math;
import 'dart:ui';

import 'package:flashing_designer/models/flashing.dart';
import 'package:flutter/material.dart';

import 'helper_functions.dart';

class FlashingCustomPainter extends CustomPainter {
  FlashingCustomPainter({
    required this.flashing,
    required this.taperedState,
  });

  Flashing flashing;
  final int taperedState;

  @override
  void paint(Canvas canvas, Size size) {
    Rect boundingBox = calculateBoundingBoxWithUi(
      flashing.points,
      flashing.lengthPositions,
      flashing.anglePositions,
    );

    if (flashing.tapered && taperedState == 0) {
      flashing.points = flashing.nearPoints;
      flashing.lengthPositions = flashing.nearLengthPositions;
      flashing.anglePositions = flashing.nearAnglePositions;
      flashing.lengthWidgetText = flashing.nearLengthWidgetText;
      flashing.lengthPositionsOffsets = flashing.nearLengthPositionsOffsets;
      flashing.anglePositionsOffsets = flashing.nearAnglePositionsOffsets;

      boundingBox = calculateBoundingBoxWithUi(
        flashing.points,
        flashing.lengthPositions,
        flashing.anglePositions,
      );
    } else if (flashing.tapered && taperedState == 1) {
      flashing.points = flashing.farPoints;
      flashing.lengthPositions = flashing.farLengthPositions;
      flashing.anglePositions = flashing.farAnglePositions;
      flashing.lengthWidgetText = flashing.farLengthWidgetText;
      flashing.lengthPositionsOffsets = flashing.farLengthPositionsOffsets;
      flashing.anglePositionsOffsets = flashing.farAnglePositionsOffsets;
      boundingBox = calculateBoundingBoxWithUi(
        flashing.points,
        flashing.lengthPositions,
        flashing.anglePositions,
      );
    }

    int girth = 0;
    for (int i = 0; i < flashing.lengthWidgetText.length; i++) {
      girth += flashing.lengthWidgetText[i];
    }

    girth = girth + flashing.cf1Length.toInt() + flashing.cf2Length.toInt();

    if (flashing.points.length >= 2) {
      double distance = 0;
      int longestPointIndex = 0;
      for (int i = 0; i < flashing.points.length - 1; i++) {
        if ((flashing.points[i] - flashing.points[i + 1]).distance > distance) {
          distance = (flashing.points[i] - flashing.points[i + 1]).distance;
          longestPointIndex = i;
        }
      }
      var normalVector = flashing.colourSide == 1
          ? calculatePerpendicularVector(flashing.points[longestPointIndex],
              flashing.points[longestPointIndex + 1])
          : -calculatePerpendicularVector(flashing.points[longestPointIndex],
              flashing.points[longestPointIndex + 1]);
      var angle = math.atan2(normalVector.dy, normalVector.dx);
      var midpoint = Offset(
          (2 * flashing.points[longestPointIndex].dx +
                  flashing.points[longestPointIndex + 1].dx) /
              3,
          (2 * flashing.points[longestPointIndex].dy +
                  flashing.points[longestPointIndex + 1].dy) /
              3);

      flashing.colourRotation = angle - (math.pi / 2);
      flashing.colourPosition = midpoint + (normalVector * 3);
      flashing.colourMidpoint = midpoint;
    }

    void drawDashedLine(
      Canvas canvas,
      Offset start,
      double angle,
      Paint paint, {
      double dashWidth = 5.0,
      double dashSpace = 3.0,
      double maxLength = 1000.0, // how far the line should go
    }) {
      final dx = math.cos(angle);
      final dy = math.sin(angle);
      double drawn = 0.0;

      // keep stepping until we reach maxLength
      while (drawn < maxLength) {
        final double x1 = start.dx + dx * drawn;
        final double y1 = start.dy + dy * drawn;
        final double nextDraw = math.min(drawn + dashWidth, maxLength);
        final double x2 = start.dx + dx * nextDraw;
        final double y2 = start.dy + dy * nextDraw;

        canvas.drawLine(Offset(x1, y1), Offset(x2, y2), paint);
        drawn += dashWidth + dashSpace;
      }
    }

    //region variables

    final backgroundPaint = Paint()
      ..color = Colors.white; // change to desired color
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, size.height), backgroundPaint);

    Paint linesPaint = Paint();
    linesPaint.style = PaintingStyle.stroke;
    linesPaint.color = Colors.grey.shade700;
    linesPaint.strokeWidth = size.width > 1024 ? 5 : 2.5;
    linesPaint.strokeCap = StrokeCap.round;

    double containerScale = 20000 / size.width;
    double scale = 20000 / boundingBox.longestSide;
    Rect scaledBoundingBox = Rect.fromLTRB(
        boundingBox.left / containerScale * scale,
        boundingBox.top / containerScale * scale,
        boundingBox.right / containerScale * scale,
        boundingBox.bottom / containerScale * scale);
    //endregion

    Offset ScalePointToCanvas(Offset point) {
      return Offset(
          (point.dx / containerScale * scale - (scaledBoundingBox.left)) +
              (((size.width - scaledBoundingBox.width) / 2)),
          (point.dy / containerScale * scale - (scaledBoundingBox.top)) +
              (((size.width - scaledBoundingBox.height) / 2)));
    }

    List<int> calculateLengthMarksFromWidgetText({
      required List<int> segmentLengths,
      required int cf1State,
      required int cf2State,
      required double cf1Length,
    }) {
      List<int> marks = [];
      double runningTotal = 0;

      final bool reverse = (cf1State > 0 && cf2State == 0);
      final List<int> lengths =
          reverse ? segmentLengths.reversed.toList() : segmentLengths;

      // Optional CF1 at the beginning (only in forward mode)
      if (!reverse && cf1State > 0) {
        runningTotal += cf1Length;
        marks.add(runningTotal.round());
      }

      for (int i = 0; i < lengths.length; i++) {
        runningTotal += lengths[i];

        // Internal marks only (skip first and last)
        final isInternal = i < lengths.length - 1;

        if (isInternal) {
          marks.add(runningTotal.round());
        }
      }

      // Final mark if either CF1 in reverse or CF2 in forward
      if ((reverse && cf1State > 0) || (!reverse && cf2State > 0)) {
        marks.add(runningTotal.round());
      }

      return marks;
    }

//region Top Row Info (scaled to fit)
    final double baseFontSize = size.width > 1024 ? 60 : 30;
    final double padding = size.width > 1024 ? 16 : 8;
    final double availableWidth = size.width - padding * 2;

    List<String> topRowParts = [];
    topRowParts.add(' ${flashing.material}');
    topRowParts.add('Girth: ${girth}mm');
    if (flashing.tapered) {
      topRowParts.add(' ${taperedState == 0 ? 'Near' : 'Far'}');
    }
    topRowParts.add(
        'Bends: ${(flashing.points.length - 2) + ((flashing.cf1State.clamp(0, 1) * 2) + (flashing.cf2State.clamp(0, 1) * 2))}');

    if (flashing.Job.isNotEmpty) topRowParts.add('Job: $flashing.job');
    if (flashing.flashingId.isNotEmpty)
      topRowParts.add('ID: ${flashing.flashingId}');

    final String combinedText = topRowParts.join(' • ');

// Helper to layout painter
    TextPainter buildPainter(double fontSize) {
      return TextPainter(
        text: TextSpan(
          text: combinedText,
          style: TextStyle(
            fontSize: fontSize,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        textAlign: TextAlign.left,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: double.infinity);
    }

// Initial layout
    double fontSize = baseFontSize;
    TextPainter painter = buildPainter(fontSize);

// Auto-scale down if it overflows
    if (painter.width > availableWidth) {
      final scale = availableWidth / painter.width;
      fontSize *= scale;
      painter = buildPainter(fontSize);
    }

// Final paint
    final Offset offset = Offset(padding, padding);
    painter.paint(canvas, offset);
//endregion

    //region DashedLines
    if (flashing.tapered) {
      double taperDashAngle =
          taperedState == 1 ? -5 * math.pi / 4.2 : -5 * math.pi / 4.2 + math.pi;
      for (int i = 0; i < flashing.points.length; i++) {
        drawDashedLine(
          canvas,
          Offset(
              (flashing.points[i].dx / containerScale * scale -
                      (scaledBoundingBox.left)) +
                  (((size.width - scaledBoundingBox.width) / 2)),
              (flashing.points[i].dy / containerScale * scale -
                      (scaledBoundingBox.top)) +
                  (((size.width - scaledBoundingBox.height) / 2))),
          taperDashAngle,
          linesPaint,
          dashWidth: (size.width > 1024 ? 10 : 5),
          dashSpace: (size.width > 1024 ? 16 : 8),
          maxLength: (size.width > 1024 ? 200 : 100),
        );
      }
    }

    //endregion

    //region Lengths (auto-sizing)
    if (taperedState != 1 || !flashing.tapered) {
      final double lengthsPadding = size.width > 1024 ? 16.0 : 8.0;
      final double maxWidth = size.width - lengthsPadding * 2;

// start with your “ideal” size
      double fontSize = size.width > 1024 ? 60 : 30;

// helper to build & layout a TextPainter at a given fontSize
      TextPainter lengthsLayoutPainter(double fs) {
        final lengthSpan = TextSpan(
          text: 'Lengths: ${flashing.Lengths}',
          style: TextStyle(
            color: Colors.black,
            fontSize: fs,
            fontWeight: FontWeight.bold,
          ),
        );
        final lengthsTextPaitner = TextPainter(
          text: lengthSpan,
          textAlign: TextAlign.left,
          textDirection: TextDirection.ltr,
        );
        lengthsTextPaitner.layout(); // no width constraint yet
        return lengthsTextPaitner;
      }

// layout at nominal
      TextPainter lengthsTextPainter = lengthsLayoutPainter(fontSize);

// if it overflows, scale it down
      if (lengthsTextPainter.width > maxWidth) {
        final scale = maxWidth / lengthsTextPainter.width;
        fontSize *= scale;
        lengthsTextPainter = lengthsLayoutPainter(fontSize);
      }

// now figure out your offset (right-aligned within padding)
      final lengthsDx = lengthsPadding;
      final lengthsDy = 0 +
          size.width -
          lengthsTextPainter.height -
          (size.width > 1024 ? 10 : 20);

// paint
      lengthsTextPainter.paint(canvas, Offset(lengthsDx, lengthsDy));
    }
//endregion
//region Marks
    final marks = calculateLengthMarksFromWidgetText(
      segmentLengths: flashing.lengthWidgetText,
      cf1State: flashing.cf1State,
      cf2State: flashing.cf2State,
      cf1Length: flashing.cf1Length,
    );

    if (marks.isNotEmpty) {
      final marksString = 'Marks: ${marks.join(', ')}';

      final double marksPadding = size.width > 1024 ? 16.0 : 8.0;
      final double fontSize = size.width > 1024 ? 60 : 30;
      final double maxWidth = size.width - marksPadding * 2;

      // Helper
      TextPainter marksPainter(double fs) {
        final span = TextSpan(
          text: marksString,
          style: TextStyle(
            color: Colors.black,
            fontSize: fs,
            fontWeight: FontWeight.bold,
          ),
        );
        final tp = TextPainter(
          text: span,
          textAlign: TextAlign.left,
          textDirection: TextDirection.ltr,
        );
        tp.layout();
        return tp;
      }

      double fs = fontSize;
      TextPainter tp = marksPainter(fs);

      if (tp.width > maxWidth) {
        fs *= maxWidth / tp.width;
        tp = marksPainter(fs);
      }

      final double marksDy = marksPadding +
          size.width -
          tp.height -
          (size.width > 1024
              ? (taperedState == 1 && flashing.tapered ? 40 : 85)
              : (taperedState == 1 && flashing.tapered
                  ? 30
                  : 65)); // place above lengths

      tp.paint(canvas, Offset(marksPadding, marksDy));
    }
//endregion

    //region Draw Lengths
    final double xPad = (size.width - scaledBoundingBox.width) / 2;
    final double yPad = (size.height - scaledBoundingBox.height) / 2;

    for (int i = 0; i < flashing.lengthPositions.length; i++) {
      // compute your direction vector exactly as before
      final Offset mid =
          calculateMidpoint(flashing.points[i], flashing.points[i + 1]);
      final Offset rawDir =
          flashing.lengthPositions[i] - flashing.lengthPositionsOffsets[i];
      final Offset lengthDirection =
          -calculateNormalizedDirectionVector(mid, rawDir) *
              10 *
              (size.width > 1024
                  ? ((boundingBox.longestSide / 300) * 5).clamp(2.1, 4.2)
                  : ((boundingBox.longestSide / 300) * 2).clamp(0.6, 2.2));

      // layout your text
      final textSpan = TextSpan(
        text: '${flashing.lengthWidgetText[i]}',
        style: TextStyle(
          color: Colors.black,
          fontSize: size.width > 1024 ? 50 : 25,
          fontWeight: FontWeight.bold,
        ),
      );
      final tp = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();

      // compute the actual on‑canvas center
      final double px =
          (flashing.lengthPositions[i].dx / containerScale * scale) -
              scaledBoundingBox.left +
              xPad -
              lengthDirection.dx;

      final double py =
          (flashing.lengthPositions[i].dy / containerScale * scale) -
              scaledBoundingBox.top +
              yPad -
              lengthDirection.dy;

      // paint centered
      tp.paint(
        canvas,
        Offset(px - tp.width / 2, py - tp.height / 2),
      );
    }
//endregion

    //region DrawAngles
    for (int i = 0; i < flashing.anglePositions.length; i++) {
      if (calculateAngle(flashing.points[i], flashing.points[i + 1],
                      flashing.points[i + 2])
                  .round() ==
              90 ||
          calculateAngle(flashing.points[i], flashing.points[i + 1],
                      flashing.points[i + 2])
                  .round() ==
              135) {
        continue;
      }
      // int longestLength = findLongestLengthForFlashingImage(points);
      final Offset angleDirection = -calculateNormalizedDirectionVector(
              flashing.points[i + 1],
              flashing.anglePositions[i] - flashing.anglePositionsOffsets[i]) *
          10 *
          (size.width > 1024
              ? ((boundingBox.longestSide / 300) * 5).clamp(2, 4)
              : ((boundingBox.longestSide / 300) * 2).clamp(0.5, 2));

      final textSpan = TextSpan(
        text:
            '${calculateAngle(flashing.points[i], flashing.points[i + 1], flashing.points[i + 2]).round()}°',
        style: TextStyle(
          color: Colors.black,
          fontSize: size.width > 1024 ? 45 : 22.5,
          fontWeight: FontWeight.bold,
        ),
      );

      final textPainter = TextPainter(
        text: textSpan,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );

      textPainter.layout();

      // Create rect from center
      final center = Offset(
          (flashing.anglePositions[i].dx / containerScale * scale -
                  (scaledBoundingBox.left)) +
              (((size.width - scaledBoundingBox.width) / 2)) -
              angleDirection.dx,
          (flashing.anglePositions[i].dy / containerScale * scale -
                  (scaledBoundingBox.top)) +
              (((size.width - scaledBoundingBox.height) / 2)) -
              angleDirection.dy);

      final textWidth = textPainter.width;
      final textHeight = textPainter.height;

      textPainter.paint(canvas,
          Offset(center.dx - (textWidth / 2), center.dy - (textHeight / 2)));
    }
    //endregion

    //region Colour Indicator
    final colorPoisionCorrected = Offset(
        (flashing.colourPosition.dx / containerScale * scale -
                (scaledBoundingBox.left)) +
            (((size.width - scaledBoundingBox.width) / 2)),
        (flashing.colourPosition.dy / containerScale * scale -
                (scaledBoundingBox.top)) +
            (((size.width - scaledBoundingBox.height) / 2)));
    Offset colourNormalVector = calculateNormalizedDirectionVector(
        flashing.colourMidpoint, flashing.colourPosition);
    colourNormalVector =
        Offset(colourNormalVector.dx * 10, colourNormalVector.dy * 10);

    TextSpan colourSpan = TextSpan(
        text: 'C',
        style: TextStyle(
            color: Colors.black,
            fontSize: size.width > 1024 ? 60 : 30,
            fontWeight: FontWeight.bold));

    final colourTextPainter = TextPainter(
      text: colourSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();

    colourTextPainter.paint(
        canvas,
        colorPoisionCorrected +
            (colourNormalVector *
                (size.width > 1024
                    ? ((boundingBox.longestSide / 300) * 5).clamp(2, 4)
                    : ((boundingBox.longestSide / 300) * 2).clamp(0.5, 2))) -
            Offset(colourTextPainter.width / 2, colourTextPainter.height / 2));
//endregion

    //region DrawLines
    for (int i = 0; i < flashing.points.length - 1; i++) {
      canvas.drawLine(
          Offset(
              (flashing.points[i].dx / containerScale * scale -
                      (scaledBoundingBox.left)) +
                  (((size.width - scaledBoundingBox.width) / 2)),
              (flashing.points[i].dy / containerScale * scale -
                      (scaledBoundingBox.top)) +
                  (((size.width - scaledBoundingBox.height) / 2))),
          Offset(
              (flashing.points[i + 1].dx / containerScale * scale -
                      (scaledBoundingBox.left)) +
                  (((size.width - scaledBoundingBox.width) / 2)),
              (flashing.points[i + 1].dy / containerScale * scale -
                      (scaledBoundingBox.top)) +
                  (((size.width - scaledBoundingBox.height) / 2))),
          linesPaint);
    }
    //endregion

    //region CF1
    if (flashing.points.length > 1 && flashing.cf1State > 0) {
      Offset cf_1NormalVector =
          calculatePerpendicularVector(flashing.points[0], flashing.points[1]);

      Offset cF_1Center = flashing.cf1State == 1
          ? ScalePointToCanvas(flashing.points[0]) +
              (Offset(cf_1NormalVector.dx * clampDouble(4, 2, double.infinity),
                  cf_1NormalVector.dy * clampDouble(4, 2, double.infinity)))
          : ScalePointToCanvas(flashing.points[0]) -
              (Offset(cf_1NormalVector.dx * clampDouble(4, 2, double.infinity),
                  cf_1NormalVector.dy * clampDouble(4, 2, double.infinity)));
      Offset cF_1End = flashing.cf1State == 1
          ? ScalePointToCanvas(flashing.points[0]) +
              (Offset(cf_1NormalVector.dx * clampDouble(8, 4, double.infinity),
                  cf_1NormalVector.dy * clampDouble(8, 4, double.infinity)))
          : ScalePointToCanvas(flashing.points[0]) -
              (Offset(cf_1NormalVector.dx * clampDouble(8, 4, double.infinity),
                  cf_1NormalVector.dy * clampDouble(8, 4, double.infinity)));

      Offset CenterDir = calculateNormalizedDirectionVector(
          cF_1Center, ScalePointToCanvas(flashing.points[0]));

      double startAngle = math.atan2(CenterDir.dy, CenterDir.dx);

      final double pixelScaleCF1 = size.width / boundingBox.longestSide;

      final double cf1PixelLength =
          flashing.cf1Length * pixelScaleCF1 * 2.666666666666667;

      final Offset dir = calculateNormalizedDirectionVector(
          flashing.points[0], flashing.points[1]);

      canvas.drawArc(
        Rect.fromCircle(
          center: cF_1Center,
          radius: clampDouble(4, 2, double.infinity),
        ),
        startAngle,
        flashing.cf1State == 1 ? -math.pi : math.pi,
        false,
        linesPaint,
      );

      canvas.drawLine(
        cF_1End,
        cF_1End + dir * cf1PixelLength,
        linesPaint,
      );
    }
    //endregion

    //region CF2
    if (flashing.points.length > 1 && flashing.cf2State > 0) {
      Offset cf_2NormalVector = calculatePerpendicularVector(
          flashing.points[flashing.points.length - 1],
          flashing.points[flashing.points.length - 2]);

      Offset cF_2Center = flashing.cf2State == 1
          ? ScalePointToCanvas(flashing.points[flashing.points.length - 1]) +
              (Offset(cf_2NormalVector.dx * clampDouble(4, 2, double.infinity),
                  cf_2NormalVector.dy * clampDouble(4, 2, double.infinity)))
          : ScalePointToCanvas(flashing.points[flashing.points.length - 1]) -
              (Offset(cf_2NormalVector.dx * clampDouble(4, 2, double.infinity),
                  cf_2NormalVector.dy * clampDouble(4, 2, double.infinity)));
      Offset cF_2End = flashing.cf2State == 1
          ? ScalePointToCanvas(flashing.points[flashing.points.length - 1]) +
              (Offset(cf_2NormalVector.dx * clampDouble(8, 4, double.infinity),
                  cf_2NormalVector.dy * clampDouble(8, 4, double.infinity)))
          : ScalePointToCanvas(flashing.points[flashing.points.length - 1]) -
              (Offset(cf_2NormalVector.dx * clampDouble(8, 4, double.infinity),
                  cf_2NormalVector.dy * clampDouble(8, 4, double.infinity)));

      Offset CenterDir = calculateNormalizedDirectionVector(cF_2Center,
          ScalePointToCanvas(flashing.points[flashing.points.length - 1]));

      double startAngle = math.atan2(CenterDir.dy, CenterDir.dx);

      final double pixelScaleCF2 = size.width / boundingBox.longestSide;
      final double cf2PixelLength =
          flashing.cf2Length * pixelScaleCF2 * 2.666666666666667;

      final Offset dir2 = calculateNormalizedDirectionVector(
        flashing.points.last,
        flashing.points[flashing.points.length - 2],
      );
      canvas.drawArc(
        Rect.fromCircle(
            center: cF_2Center, radius: clampDouble(4, 2, double.infinity)),
        startAngle,
        flashing.cf2State == 1 ? -math.pi : math.pi,
        false,
        linesPaint,
      );

      canvas.drawLine(
        cF_2End,
        cF_2End + dir2 * cf2PixelLength,
        linesPaint,
      );
    }
    //endregion
  }

  @override
  bool shouldRepaint(FlashingCustomPainter oldDelegate) => true;
}
