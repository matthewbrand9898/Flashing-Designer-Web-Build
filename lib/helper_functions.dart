import 'dart:math';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/cupertino.dart';

Offset calculateMidpoint(Offset pointA, Offset pointB) {
  return Offset(
    (pointA.dx + pointB.dx) / 2.0,
    (pointA.dy + pointB.dy) / 2.0,
  );
}

int findLongestLengthForFlashingImage(List<Offset> points) {
  if (points.length < 2) return 0;

  double maxScaled = 0.0;

  for (var i = 0; i < points.length - 1; i++) {
    // raw distance between this point and the next
    final double raw = (points[i + 1] - points[i]).distance;
    // scale and compare
    final double scaled = raw / 2.666666667;
    if (scaled > maxScaled) {
      maxScaled = scaled;
    }
  }

  return maxScaled.round();
}

Offset initialAnglePos(List<Offset> points, int point1Index, int point2Index) {
  return Offset(
      calculateNormalizedDirectionVector(
                      points[point1Index], points[point2Index])
                  .dx *
              5 +
          points[point2Index].dx,
      calculateNormalizedDirectionVector(
                      points[point1Index], points[point2Index])
                  .dy *
              5 +
          points[point2Index].dy);
}

Offset angleOffset(List<Offset> points, List<Offset> anglePositions,
    double interactiveZoomFactor, int pointsIndex, int anglePositionIndex) {
  return Offset(
      (30 *
          ((1 / -interactiveZoomFactor) *
              calculateNormalizedDirectionVector(
                      points[pointsIndex], anglePositions[anglePositionIndex])
                  .dx)),
      (30 *
          ((1 / -interactiveZoomFactor) *
              calculateNormalizedDirectionVector(
                      points[pointsIndex], anglePositions[anglePositionIndex])
                  .dy)));
}

double verticalScaler(List<Offset> points, List<Offset> lengthPositions,
    int pointIndex1, int pointIndex2) {
  Offset dir = calculateNormalizedDirectionVector(
      Offset(((points[pointIndex2].dx + points[pointIndex1].dx) / 2),
          ((points[pointIndex2].dy + points[pointIndex1].dy) / 2)),
      lengthPositions[pointIndex2]);
  double angle = atan2(dir.dy, dir.dx);
  return cos(angle - 1.57).abs();
}

Offset lengthOffset(
    List<Offset> points,
    List<Offset> lengthPositions,
    double interactiveZoomFactor,
    int point1Index,
    int point2Index,
    double Scaler) {
  return Offset(
      ((25 - (Scaler * 5)) *
          ((1 / -interactiveZoomFactor) *
              calculateNormalizedDirectionVector(
                      Offset(
                          ((points[point2Index].dx + points[point1Index].dx) /
                              2),
                          ((points[point2Index].dy + points[point1Index].dy) /
                              2)),
                      lengthPositions[point2Index])
                  .dx)),
      ((25 - (Scaler * 5)) *
          ((1 / -interactiveZoomFactor) *
              calculateNormalizedDirectionVector(
                      Offset(
                          ((points[point2Index].dx + points[point1Index].dx) /
                              2),
                          ((points[point2Index].dy + points[point1Index].dy) /
                              2)),
                      lengthPositions[point2Index])
                  .dy)));
}

Offset initialLengthPos(List<Offset> points, int pointIndex1, pointIndex2) {
  return Offset(((points[pointIndex2].dx + points[pointIndex1].dx) / 2),
          ((points[pointIndex2].dy + points[pointIndex1].dy) / 2)) +
      calculatePerpendicularVector(points[pointIndex1], points[pointIndex2]) *
          3;
}

Offset cf1StartPoint(List<Offset> points, int cf1State, double cf1Length,
    double interactiveZoomFactor) {
  Offset cf_1NormalVector = calculatePerpendicularVector(points[0], points[1]);
  Offset cf1Start = cf1State == 1
      ? points[0] +
          (Offset(
              cf_1NormalVector.dx *
                  clampDouble(
                      8 * (1 / interactiveZoomFactor), 4, double.infinity),
              cf_1NormalVector.dy *
                  clampDouble(
                      8 * (1 / interactiveZoomFactor), 4, double.infinity)))
      : points[0] -
          (Offset(
              cf_1NormalVector.dx *
                  clampDouble(
                      8 * (1 / interactiveZoomFactor), 4, double.infinity),
              cf_1NormalVector.dy *
                  clampDouble(
                      8 * (1 / interactiveZoomFactor), 4, double.infinity)));

  return cf1Start;
}

Offset cf1EndPoint(List<Offset> points, int cf1State, double cf1Length,
    double interactiveZoomFactor) {
  Offset cf_1NormalVector = calculatePerpendicularVector(points[0], points[1]);
  Offset cf1Start = cf1State == 1
      ? points[0] +
          (Offset(
              cf_1NormalVector.dx *
                  clampDouble(
                      8 * (1 / interactiveZoomFactor), 4, double.infinity),
              cf_1NormalVector.dy *
                  clampDouble(
                      8 * (1 / interactiveZoomFactor), 4, double.infinity)))
      : points[0] -
          (Offset(
              cf_1NormalVector.dx *
                  clampDouble(
                      8 * (1 / interactiveZoomFactor), 4, double.infinity),
              cf_1NormalVector.dy *
                  clampDouble(
                      8 * (1 / interactiveZoomFactor), 4, double.infinity)));

  return cf1Start +
      Offset(
          calculateNormalizedDirectionVector(points[0], points[1]).dx *
              (cf1Length * 2.6666666666666666666666666666667),
          calculateNormalizedDirectionVector(points[0], points[1]).dy *
              (cf1Length * 2.6666666666666666666666666666667));
}

Offset cf1Midpoint(List<Offset> points, int cf1State, double cf1Length,
    double interactiveZoomFactor) {
  Offset cf_1NormalVector = calculatePerpendicularVector(points[0], points[1]);
  Offset cf1Start = cf1State == 1
      ? points[0] +
          (Offset(
              cf_1NormalVector.dx *
                  clampDouble(
                      8 * (1 / interactiveZoomFactor), 4, double.infinity),
              cf_1NormalVector.dy *
                  clampDouble(
                      8 * (1 / interactiveZoomFactor), 4, double.infinity)))
      : points[0] -
          (Offset(
              cf_1NormalVector.dx *
                  clampDouble(
                      8 * (1 / interactiveZoomFactor), 4, double.infinity),
              cf_1NormalVector.dy *
                  clampDouble(
                      8 * (1 / interactiveZoomFactor), 4, double.infinity)));

  return calculateMidpoint(
      cf1Start,
      cf1Start +
          Offset(
              calculateNormalizedDirectionVector(points[0], points[1]).dx *
                  (cf1Length * 2.6666666666666666666666666666667),
              calculateNormalizedDirectionVector(points[0], points[1]).dy *
                  (cf1Length * 2.6666666666666666666666666666667)));
}

Offset cf1Offset(List<Offset> points, Offset cf_1Position,
    double interactiveZoomFactor, int cf1State, double cf1Length) {
  Offset cf_1NormalVector = calculatePerpendicularVector(points[0], points[1]);
  Offset cf_1Scaler = cf1State == 1
      ? Offset(
          cf_1NormalVector.dx *
              clampDouble(8 * (1 / interactiveZoomFactor), 4, double.infinity),
          cf_1NormalVector.dy *
              clampDouble(8 * (1 / interactiveZoomFactor), 4, double.infinity))
      : -Offset(
          cf_1NormalVector.dx *
              clampDouble(8 * (1 / interactiveZoomFactor), 4, double.infinity),
          cf_1NormalVector.dy *
              clampDouble(8 * (1 / interactiveZoomFactor), 4, double.infinity));

  Offset cf1midpoint =
      cf1Midpoint(points, cf1State, cf1Length, interactiveZoomFactor);

  return Offset(
      (25 *
              ((1 / -interactiveZoomFactor) *
                  calculateNormalizedDirectionVector(
                          cf1midpoint, cf_1Position + cf_1Scaler)
                      .dx)) -
          cf_1Scaler.dx,
      (25 *
              ((1 / -interactiveZoomFactor) *
                  calculateNormalizedDirectionVector(
                          cf1midpoint, cf_1Position + cf_1Scaler)
                      .dy)) -
          cf_1Scaler.dy);
}

Offset cf2StartPoint(List<Offset> points, int cf2State, double cf2Length,
    double interactiveZoomFactor) {
  Offset cf_2NormalVector = calculatePerpendicularVector(
      points[points.length - 1], points[points.length - 2]);
  Offset cf2Start = cf2State == 1
      ? points[points.length - 1] +
          (Offset(
              cf_2NormalVector.dx *
                  clampDouble(
                      8 * (1 / interactiveZoomFactor), 4, double.infinity),
              cf_2NormalVector.dy *
                  clampDouble(
                      8 * (1 / interactiveZoomFactor), 4, double.infinity)))
      : points[points.length - 1] -
          (Offset(
              cf_2NormalVector.dx *
                  clampDouble(
                      8 * (1 / interactiveZoomFactor), 4, double.infinity),
              cf_2NormalVector.dy *
                  clampDouble(
                      8 * (1 / interactiveZoomFactor), 4, double.infinity)));

  return cf2Start;
}

Offset cf2EndPoint(List<Offset> points, int cf2State, double cf2Length,
    double interactiveZoomFactor) {
  Offset cf_2NormalVector = calculatePerpendicularVector(
      points[points.length - 1], points[points.length - 2]);
  Offset cf2Start = cf2State == 1
      ? points[points.length - 1] +
          (Offset(
              cf_2NormalVector.dx *
                  clampDouble(
                      8 * (1 / interactiveZoomFactor), 4, double.infinity),
              cf_2NormalVector.dy *
                  clampDouble(
                      8 * (1 / interactiveZoomFactor), 4, double.infinity)))
      : points[points.length - 1] -
          (Offset(
              cf_2NormalVector.dx *
                  clampDouble(
                      8 * (1 / interactiveZoomFactor), 4, double.infinity),
              cf_2NormalVector.dy *
                  clampDouble(
                      8 * (1 / interactiveZoomFactor), 4, double.infinity)));

  return cf2Start +
      Offset(
          calculateNormalizedDirectionVector(
                      points[points.length - 1], points[points.length - 2])
                  .dx *
              (cf2Length * 2.6666666666666666666666666666667),
          calculateNormalizedDirectionVector(
                      points[points.length - 1], points[points.length - 2])
                  .dy *
              (cf2Length * 2.6666666666666666666666666666667));
}

Offset cf2Midpoint(List<Offset> points, int cf2State, double cf2Length,
    double interactiveZoomFactor) {
  Offset cf_2NormalVector = calculatePerpendicularVector(
      points[points.length - 1], points[points.length - 2]);
  Offset cf2Start = cf2State == 1
      ? points[points.length - 1] +
          (Offset(
              cf_2NormalVector.dx *
                  clampDouble(
                      8 * (1 / interactiveZoomFactor), 4, double.infinity),
              cf_2NormalVector.dy *
                  clampDouble(
                      8 * (1 / interactiveZoomFactor), 4, double.infinity)))
      : points[points.length - 1] -
          (Offset(
              cf_2NormalVector.dx *
                  clampDouble(
                      8 * (1 / interactiveZoomFactor), 4, double.infinity),
              cf_2NormalVector.dy *
                  clampDouble(
                      8 * (1 / interactiveZoomFactor), 4, double.infinity)));

  return calculateMidpoint(
      cf2Start,
      cf2Start +
          Offset(
              calculateNormalizedDirectionVector(
                          points[points.length - 1], points[points.length - 2])
                      .dx *
                  (cf2Length * 2.6666666666666666666666666666667),
              calculateNormalizedDirectionVector(
                          points[points.length - 1], points[points.length - 2])
                      .dy *
                  (cf2Length * 2.6666666666666666666666666666667)));
}

Offset cf2Scaler(
  List<Offset> points,
  double interactiveZoomFactor,
  int cf2State,
) {
  Offset cf_2NormalVector = calculatePerpendicularVector(
      points[points.length - 1], points[points.length - 2]);
  Offset cf_2Scaler = cf2State == 1
      ? Offset(
          cf_2NormalVector.dx *
              clampDouble(8 * (1 / interactiveZoomFactor), 4, double.infinity),
          cf_2NormalVector.dy *
              clampDouble(8 * (1 / interactiveZoomFactor), 4, double.infinity))
      : -Offset(
          cf_2NormalVector.dx *
              clampDouble(8 * (1 / interactiveZoomFactor), 4, double.infinity),
          cf_2NormalVector.dy *
              clampDouble(8 * (1 / interactiveZoomFactor), 4, double.infinity));

  return cf_2Scaler;
}

Offset cf2Offset(List<Offset> points, Offset cf_2Position,
    double interactiveZoomFactor, int cf2State, double cf2Length) {
  Offset cf_2NormalVector = calculatePerpendicularVector(
      points[points.length - 1], points[points.length - 2]);
  Offset cf_2Scaler = cf2State == 1
      ? Offset(
          cf_2NormalVector.dx *
              clampDouble(8 * (1 / interactiveZoomFactor), 4, double.infinity),
          cf_2NormalVector.dy *
              clampDouble(8 * (1 / interactiveZoomFactor), 4, double.infinity))
      : -Offset(
          cf_2NormalVector.dx *
              clampDouble(8 * (1 / interactiveZoomFactor), 4, double.infinity),
          cf_2NormalVector.dy *
              clampDouble(8 * (1 / interactiveZoomFactor), 4, double.infinity));

  Offset cf2midpoint =
      cf2Midpoint(points, cf2State, cf2Length, interactiveZoomFactor);

  return Offset(
      (25 *
              ((1 / -interactiveZoomFactor) *
                  calculateNormalizedDirectionVector(
                          cf2midpoint, cf_2Position + cf_2Scaler)
                      .dx)) -
          cf_2Scaler.dx,
      (25 *
              ((1 / -interactiveZoomFactor) *
                  calculateNormalizedDirectionVector(
                          cf2midpoint, cf_2Position + cf_2Scaler)
                      .dy)) -
          cf_2Scaler.dy);
}

void centerOnBoundingBox({
  required TransformationController controller,
  required List<Offset> points,
  required Size viewportSize,
  double? minScale, // optional clamp
  double? maxScale, // optional clamp
  double marginFactor = 0.9, // leave 10% padding around
}) {
  if (points.isEmpty) return;

  // 1️⃣ bounding box
  final minX = points.map((p) => p.dx).reduce(math.min);
  final maxX = points.map((p) => p.dx).reduce(math.max);
  final minY = points.map((p) => p.dy).reduce(math.min);
  final maxY = points.map((p) => p.dy).reduce(math.max);

  final boxW = maxX - minX;
  final boxH = maxY - minY;
  final boxCenterX = (minX + maxX) / 2;
  final boxCenterY = (minY + maxY) / 2;

  // 2️⃣ compute fit scale
  var fitScale = math.min(
    viewportSize.width / (boxW == 0 ? viewportSize.width : boxW),
    viewportSize.height / (boxH == 0 ? viewportSize.height : boxH),
  );

  // apply margin so it’s not edge-to-edge
  fitScale *= marginFactor;

  // 3️⃣ clamp if needed
  if (minScale != null) fitScale = math.max(fitScale, minScale);
  if (maxScale != null) fitScale = math.min(fitScale, maxScale);

  // 4️⃣ build the centered matrix
  final m = Matrix4.identity()
    // move box center → screen center
    ..translate(viewportSize.width / 2, viewportSize.height / 2)
    // scale
    ..scale(fitScale)
    // move the box center to origin before scaling
    ..translate(-boxCenterX, -boxCenterY);

  controller.value = m;
}

Rect calculateBoundingBoxWithUi(
  List<Offset> points,
  List<Offset> lengthPositions,
  List<Offset> anglePositions,
) {
  // 1) Start with infinities so first real point resets them
  double minX = double.infinity;
  double minY = double.infinity;
  double maxX = double.negativeInfinity;
  double maxY = double.negativeInfinity;

  void update(Offset p) {
    minX = min(minX, p.dx);
    minY = min(minY, p.dy);
    maxX = max(maxX, p.dx);
    maxY = max(maxY, p.dy);
  }

  // 2) Feed in all three lists
  for (final p in points) {
    update(p);
  }
  for (final p in lengthPositions) {
    update(p);
  }
  for (final p in anglePositions) {
    update(p);
  }

  // 3) If nobody passed in any points, return an empty rect
  if (minX == double.infinity) return Rect.zero;

  // 4) Build the raw box
  final raw = Rect.fromLTRB(minX, minY, maxX, maxY);

  // 5) First pad by 20px
  final padded20 = raw.inflate(20);

  // 6) Then pad by 5% of the longest side
  final extraPad = 0.10 * padded20.longestSide;
  return padded20.inflate(extraPad);
}

Rect calculateBoundingBox(List<Offset> points) {
  double minX = double.infinity;
  double minY = double.infinity;
  double maxX = double.negativeInfinity;
  double maxY = double.negativeInfinity;

  void updateMinMax(Offset point) {
    minX = min(minX, point.dx);
    minY = min(minY, point.dy);
    maxX = max(maxX, point.dx);
    maxY = max(maxY, point.dy);
  }

  for (Offset point in points) {
    updateMinMax(point);
  }

  Rect rect = Rect.fromPoints(
      Offset(minX - (20), minY - (20)), Offset(maxX + (20), maxY + (20)));
  return Rect.fromPoints(
      Offset(
          minX - (0.05 * rect.longestSide), minY - (0.05 * rect.longestSide)),
      Offset(
          maxX + (0.05 * rect.longestSide), maxY + (0.05 * rect.longestSide)));
}

Offset calculatePerpendicularVector(Offset point1, Offset point2) {
  double deltaX = point2.dx - point1.dx;
  double deltaY = point2.dy - point1.dy;

  double magnitude = sqrt(deltaX * deltaX + deltaY * deltaY);

  if (magnitude == 0.0) {
    return Offset.zero; // Avoid division by zero
  }

  double normalizedX = -deltaY / magnitude; // Swap X and Y and negate Y
  double normalizedY = deltaX / magnitude;

  return Offset(normalizedX, normalizedY);
}

double calculateSignedAngle(Offset point1, Offset point2, Offset point3) {
  double vector1x = point1.dx - point2.dx;
  double vector1y = point1.dy - point2.dy;

  double vector2x = point3.dx - point2.dx;
  double vector2y = point3.dy - point2.dy;

  // Calculate the cross product and dot product
  double crossProduct = (vector1x * vector2y) - (vector1y * vector2x);
  double dotProduct = (vector1x * vector2x) + (vector1y * vector2y);

  // Calculate the signed angle using atan2
  double signedAngle = atan2(crossProduct, dotProduct);

  // Convert angle from radians to degrees
  signedAngle = signedAngle * (180.0 / pi);

  return signedAngle;
}

int calculateAngleSign(Offset pointA, Offset pointB, Offset pointC) {
  // Calculate vectors AB and BC
  double vectorABx = pointB.dx - pointA.dx;
  double vectorABy = pointB.dy - pointA.dy;
  double vectorBCx = pointC.dx - pointB.dx;
  double vectorBCy = pointC.dy - pointB.dy;

  // Calculate the cross product
  double crossProduct = (vectorABx * vectorBCy) - (vectorABy * vectorBCx);

  // Determine the sign of the angle based on the cross product
  int angleSign = crossProduct.sign
      .toInt(); // Returns -1 for clockwise, 0 for collinear, and 1 for counterclockwise

  return angleSign;
}

double calculateAngle(Offset point1, Offset point2, Offset point3) {
  double vector1x = point1.dx - point2.dx;
  double vector1y = point1.dy - point2.dy;

  double vector2x = point3.dx - point2.dx;
  double vector2y = point3.dy - point2.dy;

  double dotProduct = (vector1x * vector2x) + (vector1y * vector2y);

  double magnitude1 = sqrt(vector1x * vector1x + vector1y * vector1y);
  double magnitude2 = sqrt(vector2x * vector2x + vector2y * vector2y);

  double cosTheta = dotProduct / (magnitude1 * magnitude2);

  double angleInRadians = acos(cosTheta);

  // Convert angle from radians to degrees
  double angleInDegrees = angleInRadians * (180.0 / pi);

  return angleInDegrees;
}

Offset rotatePoint(Offset point, Offset center, double degrees) {
  double radians = degrees * (pi / 180.0);

  double x = center.dx +
      (point.dx - center.dx) * cos(radians) -
      (point.dy - center.dy) * sin(radians);
  double y = center.dy +
      (point.dx - center.dx) * sin(radians) +
      (point.dy - center.dy) * cos(radians);

  return Offset(x, y);
}

Offset calculateNormalizedDirectionVector(Offset from, Offset to) {
  double deltaX = to.dx - from.dx;
  double deltaY = to.dy - from.dy;

  double magnitude = sqrt(deltaX * deltaX + deltaY * deltaY);

  if (magnitude == 0.0) {
    return Offset.zero; // Avoid division by zero
  }

  double normalizedX = deltaX / magnitude;
  double normalizedY = deltaY / magnitude;

  return Offset(normalizedX, normalizedY);
}
