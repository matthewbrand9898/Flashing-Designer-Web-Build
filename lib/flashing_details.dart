import 'dart:convert';
import 'dart:math' as math;

import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:web/web.dart' as web;

import 'helper_functions.dart';
import 'models/designer_model.dart';

class FlashingDetails extends StatefulWidget {
  const FlashingDetails(
      {required this.points,
      required this.anglePos,
      required this.anglePosOffsets,
      required this.lengthPos,
      required this.lengthPosOffsets,
      required this.boundingBox,
      required this.girth,
      required this.lengthWidgetText,
      required this.colourPosition,
      required this.colourMidPoint,
      required this.tapered,
      required this.taperedState,
      required this.cf1State,
      required this.cf2State,
      required this.cf1Length,
      required this.cf2Length,
      required this.material,
      required this.lengths,
      super.key});
  final List<Offset> points;
  final List<Offset> anglePos;
  final List<Offset> lengthPos;
  final List<Offset> lengthPosOffsets;
  final List<Offset> anglePosOffsets;
  final Rect boundingBox;
  final int girth;
  final List<int> lengthWidgetText;
  final Offset colourPosition;
  final Offset colourMidPoint;
  final bool tapered;
  final int taperedState;
  final int cf1State;
  final int cf2State;
  final double cf1Length;
  final double cf2Length;
  final String material;
  final String lengths;

  @override
  State<FlashingDetails> createState() => _RenderFlashingState();
}

/// Convert the painter to image bytes
Future<Uint8List> generateImageBytes(CustomPainter? painter, Size size) async {
  ui.PictureRecorder? recorder = ui.PictureRecorder();
  Canvas? canvas = Canvas(recorder);
  painter?.paint(canvas, size);
  ui.Picture? picture = recorder.endRecording();
  ui.Image? image =
      (await picture.toImage(size.width.toInt(), size.height.toInt()));
  ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  Uint8List? pngBytes = byteData!.buffer.asUint8List();
  image.dispose();
  picture.dispose();
  recorder = null;
  canvas = null;
  painter = null;
  picture = null;
  image = null;
  byteData = null;
  return pngBytes;
}

Future<void> downloadBytes(Uint8List bytes, String filename) async {
  // 1) Base64-encode your PNG bytes
  String? base64Data = base64Encode(bytes);

  // 2) Build a data URI
  String? uri = 'data:image/png;base64,$base64Data';

  // 3) Anchor-click to download
  web.HTMLAnchorElement? anchor = web.HTMLAnchorElement()
    ..href = uri
    ..download = filename;

  web.document.body?.append(anchor);
  anchor.click();
  anchor.remove();
  anchor = null;
  uri = null;
  base64Data = null;
  web.URL.revokeObjectURL(uri!);
}

class _RenderFlashingState extends State<FlashingDetails> {
  int initialTaperedState = 0;
  List<Offset> nearPoints = [];
  Rect nearBoundingBox = Rect.zero;
  List<Offset> nearLengthPositions = [];
  List<Offset> nearLengthPositionOffsets = [];
  List<Offset> nearAnglePositions = [];
  List<Offset> nearAnglePositionOffsets = [];
  int nearGirth = 0;
  List<int> nearLengthWidgetText = [];
  Offset nearColourPosition = Offset.zero;
  Offset nearColourMidPoint = Offset.zero;
  bool nearTapered = false;
  int nearTaperedState = 0;

  List<Offset> farPoints = [];
  Rect farBoundingBox = Rect.zero;
  List<Offset> farLengthPositions = [];
  List<Offset> farLengthPositionOffsets = [];
  List<Offset> farAnglePositions = [];
  List<Offset> farAnglePositionOffsets = [];
  int farGirth = 0;
  List<int> farLengthWidgetText = [];
  Offset farColourPosition = Offset.zero;
  Offset farColourMidPoint = Offset.zero;
  bool farTapered = false;
  int farTaperedState = 1;

  @override
  void initState() {
    super.initState();
    if (widget.tapered) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final designerModel = context.read<DesignerModel>();
        initialTaperedState = designerModel.taperedState;
        // Near taper
        if (designerModel.taperedState != 0) {
          designerModel.swapTaper(0);
        }
        nearPoints = designerModel.points;
        nearBoundingBox = calculateBoundingBoxWithUi(
          designerModel.points,
          designerModel.lengthPositions,
          designerModel.anglePositions,
        );
        nearLengthPositions = designerModel.lengthPositions;
        nearLengthPositionOffsets = designerModel.lengthPositions_Offsets;
        nearAnglePositions = designerModel.anglePositions;
        nearAnglePositionOffsets = designerModel.anglePositions_Offsets;
        nearGirth = designerModel.girth;
        nearLengthWidgetText = designerModel.lengthWidgetText;
        nearColourPosition = designerModel.colourPosition;
        nearColourMidPoint = designerModel.colourMidpoint;
        nearTapered = true;
        nearTaperedState = 0;

        // Far taper
        designerModel.swapTaper(1);
        farPoints = designerModel.points;
        farBoundingBox = calculateBoundingBoxWithUi(
          designerModel.points,
          designerModel.lengthPositions,
          designerModel.anglePositions,
        );
        farLengthPositions = designerModel.lengthPositions;
        farLengthPositionOffsets = designerModel.lengthPositions_Offsets;
        farAnglePositions = designerModel.anglePositions;
        farAnglePositionOffsets = designerModel.anglePositions_Offsets;
        farGirth = designerModel.girth;
        farLengthWidgetText = designerModel.lengthWidgetText;
        farColourPosition = designerModel.colourPosition;
        farColourMidPoint = designerModel.colourMidpoint;
        farTapered = true;
        farTaperedState = 1;

        if (initialTaperedState == 0) {
          designerModel.swapTaper(0);
        }

        setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            // Pop this route off the stack:
            Navigator.of(context).pop();
          },
        ),
        iconTheme: const IconThemeData(
          color: Colors.white, //change your color here
        ),
        backgroundColor: Colors.deepPurple.shade500,
        title: const Text(
          "Generate Image",
          style: TextStyle(fontFamily: "Kanit", color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          TextButton(
              style: TextButton.styleFrom(
                  foregroundColor: Colors.deepPurple.shade50),
              onPressed: () async {
                if (!kIsWeb) return;

                if (!widget.tapered) {
                  Uint8List? bytes = await generateImageBytes(
                      FlashingDetailsCustomPainter(
                        points: widget.points,
                        boundingBox: widget.boundingBox,
                        lengthWidgetPositions: widget.lengthPos,
                        lengthWidgetPositionOffsets: widget.lengthPosOffsets,
                        angleWidgetPositions: widget.anglePos,
                        anlgeWidgetPositionOffsets: widget.anglePosOffsets,
                        girth: widget.girth,
                        lengthWidgetText: widget.lengthWidgetText,
                        colourPosition: widget.colourPosition,
                        colourMidPoint: widget.colourMidPoint,
                        tapered: widget.tapered,
                        taperedState: widget.taperedState,
                        cf1State: widget.cf1State,
                        cf2State: widget.cf2State,
                        cf1Length: widget.cf1Length,
                        cf2Length: widget.cf2Length,
                        material: widget.material,
                        lengths: widget.lengths,
                      ),
                      const Size(2048, 2048));
                  await downloadBytes(
                      bytes, 'Flashing${DateTime.timestamp().toLocal()}.png');
                  bytes = null;
                } else {
                  FlashingDetailsCustomPainter? nearPainter =
                      FlashingDetailsCustomPainter(
                    girth: nearGirth,
                    points: nearPoints,
                    boundingBox: nearBoundingBox,
                    lengthWidgetPositions: nearLengthPositions,
                    lengthWidgetPositionOffsets: nearLengthPositionOffsets,
                    angleWidgetPositions: nearAnglePositions,
                    anlgeWidgetPositionOffsets: nearAnglePositionOffsets,
                    lengthWidgetText: nearLengthWidgetText,
                    colourPosition: nearColourPosition,
                    colourMidPoint: nearColourMidPoint,
                    tapered: nearTapered,
                    taperedState: nearTaperedState,
                    cf1State: widget.cf1State,
                    cf2State: widget.cf2State,
                    cf1Length: widget.cf1Length,
                    cf2Length: widget.cf2Length,
                    material: widget.material,
                    lengths: widget.lengths,
                  );

                  FlashingDetailsCustomPainter? farPainter =
                      FlashingDetailsCustomPainter(
                    girth: farGirth,
                    points: farPoints,
                    boundingBox: farBoundingBox,
                    lengthWidgetPositions: farLengthPositions,
                    lengthWidgetPositionOffsets: farLengthPositionOffsets,
                    angleWidgetPositions: farAnglePositions,
                    anlgeWidgetPositionOffsets: farAnglePositionOffsets,
                    lengthWidgetText: farLengthWidgetText,
                    colourPosition: farColourPosition,
                    colourMidPoint: farColourMidPoint,
                    tapered: farTapered,
                    taperedState: farTaperedState,
                    cf1State: widget.cf1State,
                    cf2State: widget.cf2State,
                    cf1Length: widget.cf1Length,
                    cf2Length: widget.cf2Length,
                    material: widget.material,
                    lengths: widget.lengths,
                  );
                  _CombinedPainter? combined =
                      _CombinedPainter(near: nearPainter, far: farPainter);
                  Uint8List? taperedBytes = await generateImageBytes(
                      combined, const Size(4096, 2048));
                  await downloadBytes(taperedBytes,
                      'TaperedFlashing${DateTime.timestamp().toLocal()}.png');
                  combined = null;
                  taperedBytes = null;
                  nearPainter = null;
                  farPainter = null;
                }
              },
              child: const Text(
                "DOWNLOAD",
                style: TextStyle(fontFamily: "Kanit", color: Colors.white),
              )),
          const Padding(padding: EdgeInsets.only(right: 15)),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(
                    bottom: 16.0, left: 16.0, right: 16.0),
                child: SingleChildScrollView(
                  child: Wrap(
                    runSpacing: 20,
                    spacing: 20,
                    alignment: WrapAlignment.center,
                    children: [
                      if (!widget.tapered)
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Card(
                            color: Colors.white,
                            elevation: 8,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CustomPaint(
                                size: const Size(1024, 1024),
                                painter: FlashingDetailsCustomPainter(
                                  girth: widget.girth,
                                  points: widget.points,
                                  boundingBox: widget.boundingBox,
                                  lengthWidgetPositions: widget.lengthPos,
                                  lengthWidgetPositionOffsets:
                                      widget.lengthPosOffsets,
                                  angleWidgetPositions: widget.anglePos,
                                  anlgeWidgetPositionOffsets:
                                      widget.anglePosOffsets,
                                  lengthWidgetText: widget.lengthWidgetText,
                                  colourPosition: widget.colourPosition,
                                  colourMidPoint: widget.colourMidPoint,
                                  tapered: widget.tapered,
                                  taperedState: widget.taperedState,
                                  cf1State: widget.cf1State,
                                  cf2State: widget.cf2State,
                                  cf1Length: widget.cf1Length,
                                  cf2Length: widget.cf2Length,
                                  material: widget.material,
                                  lengths: widget.lengths,
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (widget.tapered)
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Card(
                            color: Colors.white,
                            elevation: 8,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CustomPaint(
                                size: const Size(1024, 1024),
                                painter: FlashingDetailsCustomPainter(
                                  girth: nearGirth,
                                  points: nearPoints,
                                  boundingBox: nearBoundingBox,
                                  lengthWidgetPositions: nearLengthPositions,
                                  lengthWidgetPositionOffsets:
                                      nearLengthPositionOffsets,
                                  angleWidgetPositions: nearAnglePositions,
                                  anlgeWidgetPositionOffsets:
                                      nearAnglePositionOffsets,
                                  lengthWidgetText: nearLengthWidgetText,
                                  colourPosition: nearColourPosition,
                                  colourMidPoint: nearColourMidPoint,
                                  tapered: nearTapered,
                                  taperedState: nearTaperedState,
                                  cf1State: widget.cf1State,
                                  cf2State: widget.cf2State,
                                  cf1Length: widget.cf1Length,
                                  cf2Length: widget.cf2Length,
                                  material: widget.material,
                                  lengths: widget.lengths,
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (widget.tapered)
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Card(
                            color: Colors.white,
                            elevation: 8,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: CustomPaint(
                                size: const Size(1024, 1024),
                                painter: FlashingDetailsCustomPainter(
                                  girth: farGirth,
                                  points: farPoints,
                                  boundingBox: farBoundingBox,
                                  lengthWidgetPositions: farLengthPositions,
                                  lengthWidgetPositionOffsets:
                                      farLengthPositionOffsets,
                                  angleWidgetPositions: farAnglePositions,
                                  anlgeWidgetPositionOffsets:
                                      farAnglePositionOffsets,
                                  lengthWidgetText: farLengthWidgetText,
                                  colourPosition: farColourPosition,
                                  colourMidPoint: farColourMidPoint,
                                  tapered: farTapered,
                                  taperedState: farTaperedState,
                                  cf1State: widget.cf1State,
                                  cf2State: widget.cf2State,
                                  cf1Length: widget.cf1Length,
                                  cf2Length: widget.cf2Length,
                                  material: widget.material,
                                  lengths: widget.lengths,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FlashingDetailsCustomPainter extends CustomPainter {
  FlashingDetailsCustomPainter({
    required this.lengthWidgetPositions,
    required this.lengthWidgetPositionOffsets,
    required this.angleWidgetPositions,
    required this.anlgeWidgetPositionOffsets,
    required this.points,
    required this.boundingBox,
    required this.girth,
    required this.lengthWidgetText,
    required this.colourPosition,
    required this.colourMidPoint,
    required this.tapered,
    required this.taperedState,
    required this.cf1State,
    required this.cf2State,
    required this.cf1Length,
    required this.cf2Length,
    required this.material,
    required this.lengths,
  });
  final int girth;
  final Rect boundingBox;
  final List<Offset> points;
  final List<Offset> lengthWidgetPositions;
  final List<Offset> lengthWidgetPositionOffsets;
  final List<Offset> angleWidgetPositions;
  final List<Offset> anlgeWidgetPositionOffsets;
  final List<int> lengthWidgetText;
  final Offset colourPosition;
  final Offset colourMidPoint;
  final bool tapered;
  final int taperedState;
  final int cf1State;
  final int cf2State;
  final double cf1Length;
  final double cf2Length;
  final String material;
  final String lengths;

  @override
  void paint(Canvas canvas, Size size) {
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
    linesPaint.strokeWidth = size.width > 1024 ? 3 : 1.5;
    linesPaint.strokeCap = StrokeCap.round;

    Paint boxPaint = Paint();
    boxPaint.color = Colors.black;
    boxPaint.strokeWidth = 4;
    Paint pointsPaint = Paint();
    pointsPaint.color = Colors.deepPurple;
    pointsPaint.strokeWidth = 3.0;
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

//region Girth
    TextSpan girthTextSpan = TextSpan(
      text: 'Girth: ${girth}mm',
      style: TextStyle(
        color: Colors.black,
        fontSize: size.width > 1024 ? 36 : 18,
        fontWeight: FontWeight.bold,
      ),
    );
    final girthTextPainter = TextPainter(
      text: girthTextSpan,
      textAlign: TextAlign.right,
      textDirection: TextDirection.ltr,
    )..layout();

    final double girthPadding = (size.width > 1024 ? 16 : 8);
    final girthDx = 0 + girthPadding;
    final double girthDy = girthPadding;
    final girthOffset = Offset(girthDx, girthDy);

    girthTextPainter.paint(canvas, girthOffset);
//endregion

    //region Taper
    TextSpan taperSpan = TextSpan(
      text: 'Taper: ${taperedState == 0 ? 'Near' : 'Far'}',
      style: TextStyle(
        color: Colors.black,
        fontSize: size.width > 1024 ? 36 : 18,
        fontWeight: FontWeight.bold,
      ),
    );
    final taperTextPainter = TextPainter(
      text: taperSpan,
      textAlign: TextAlign.right,
      textDirection: TextDirection.ltr,
    )..layout();

    final double taperPadding = (size.width > 1024 ? 16 : 8);
    final taperDx = 0 + girthTextPainter.width + taperPadding + 15;
    final double taperDy = taperPadding;
    final taperOffset = Offset(taperDx, taperDy);

    if (tapered) taperTextPainter.paint(canvas, taperOffset);
//endregion

    //region Bends
    TextSpan bendsTextSpan = TextSpan(
      text:
          'Bends: ${(points.length - 2) + (cf1State.clamp(0, 1) + cf2State.clamp(0, 1))}',
      style: TextStyle(
        color: Colors.black,
        fontSize: size.width > 1024 ? 36 : 18,
        fontWeight: FontWeight.bold,
      ),
    );
    final bendsTextPainter = TextPainter(
      text: bendsTextSpan,
      textAlign: TextAlign.right,
      textDirection: TextDirection.ltr,
    )..layout();

    final double bendsPadding = (size.width > 1024 ? 16 : 8);
    final bendshDx = 0 +
        girthTextPainter.width +
        (tapered ? taperTextPainter.width : 0) +
        bendsPadding +
        (tapered ? 30 : 15);
    final double bendsDy = bendsPadding;
    final bendsOffset = Offset(bendshDx, bendsDy);

    bendsTextPainter.paint(canvas, bendsOffset);
//endregion

    //region Material
    TextSpan materialTextSpan = TextSpan(
      text: 'Material: $material',
      style: TextStyle(
        color: Colors.black,
        fontSize: size.width > 1024 ? 36 : 18,
        fontWeight: FontWeight.bold,
      ),
    );
    final materialTextPainter = TextPainter(
      text: materialTextSpan,
      textAlign: TextAlign.right,
      textDirection: TextDirection.ltr,
    )..layout();

    final double materialPadding = (size.width > 1024 ? 16 : 8);
    final materialDx = 0 +
        girthTextPainter.width +
        (tapered ? taperTextPainter.width : 0) +
        bendsTextPainter.width +
        materialPadding +
        (tapered ? 45 : 30);
    final double materialDy = materialPadding;
    final materialOffset = Offset(materialDx, materialDy);

    materialTextPainter.paint(canvas, materialOffset);
//endregion

    //region Lengths (auto-sizing)
    if (taperedState != 1) {
      final double padding = size.width > 1024 ? 16.0 : 8.0;
      final double maxWidth = size.width - padding * 2;

// start with your “ideal” size
      double fontSize = size.width > 1024 ? 36 : 18;

// helper to build & layout a TextPainter at a given fontSize
      TextPainter _layoutPainter(double fs) {
        final span = TextSpan(
          text: 'Lengths: $lengths',
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
        tp.layout(); // no width constraint yet
        return tp;
      }

// layout at nominal
      TextPainter tp = _layoutPainter(fontSize);

// if it overflows, scale it down
      if (tp.width > maxWidth) {
        final scale = maxWidth / tp.width;
        fontSize *= scale;
        tp = _layoutPainter(fontSize);
      }

// now figure out your offset (right-aligned within padding)
      final dx = padding;
      final dy =
          padding + size.width - tp.height - (size.width > 1024 ? 50 : 25);

// paint
      tp.paint(canvas, Offset(dx, dy));
    }
//endregion

    //region Hide Angles
    TextSpan anglesHiddenTextSpan = TextSpan(
      text: '(45° and 90° Hidden)',
      style: TextStyle(
        color: Colors.black,
        fontSize: size.width > 1024 ? 36 : 18,
        fontWeight: FontWeight.bold,
      ),
    );
    final anglesHiddenTextPainter = TextPainter(
      text: anglesHiddenTextSpan,
      textAlign: TextAlign.right,
      textDirection: TextDirection.ltr,
    )..layout();

    final double anglesHiddenPadding = (size.width > 1024 ? 16 : 8);
    final anglesHiddenDx = 0 +
        girthTextPainter.width +
        (tapered ? taperTextPainter.width : 0) +
        bendsTextPainter.width +
        materialTextPainter.width +
        anglesHiddenPadding +
        (tapered ? 60 : 45);
    final double anglesHiddenDy = anglesHiddenPadding;
    final anglesHiddenOffset = Offset(anglesHiddenDx, anglesHiddenDy);

    anglesHiddenTextPainter.paint(canvas, anglesHiddenOffset);
//endregion

    //region Draw Lengths
    for (int i = 0; i < lengthWidgetPositions.length; i++) {
      // int longestLength = findLongestLengthForFlashingImage(points);
      final Offset lengthDirection = -calculateNormalizedDirectionVector(
              calculateMidpoint(points[i], points[i + 1]),
              lengthWidgetPositions[i] - lengthWidgetPositionOffsets[i]) *
          10 *
          (size.width > 1024
              ? ((boundingBox.longestSide / 300) * 5).clamp(2, 4)
              : ((boundingBox.longestSide / 300) * 2).clamp(0.5, 2));

      final textSpan = TextSpan(
        text: '${lengthWidgetText[i]}',
        style: TextStyle(
          color: Colors.black,
          fontSize: size.width > 1024 ? 36 : 18,
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
          (lengthWidgetPositions[i].dx / containerScale * scale -
                  (scaledBoundingBox.left)) +
              (((size.width - scaledBoundingBox.width) / 2)) -
              lengthDirection.dx,
          (lengthWidgetPositions[i].dy / containerScale * scale -
                  (scaledBoundingBox.top)) +
              (((size.width - scaledBoundingBox.height) / 2)) -
              lengthDirection.dy);

      final textWidth = textPainter.width;
      final textHeight = textPainter.height;

      textPainter.paint(canvas,
          Offset(center.dx - (textWidth / 2), center.dy - (textHeight / 2)));
    }
    //endregion

    //region DrawAngles
    for (int i = 0; i < angleWidgetPositions.length; i++) {
      if (calculateAngle(points[i], points[i + 1], points[i + 2]).round() ==
              90 ||
          calculateAngle(points[i], points[i + 1], points[i + 2]).round() ==
              135) {
        continue;
      }
      // int longestLength = findLongestLengthForFlashingImage(points);
      final Offset angleDirection = -calculateNormalizedDirectionVector(
              points[i + 1],
              angleWidgetPositions[i] - anlgeWidgetPositionOffsets[i]) *
          10 *
          (size.width > 1024
              ? ((boundingBox.longestSide / 300) * 5).clamp(2, 4)
              : ((boundingBox.longestSide / 300) * 2).clamp(0.5, 2));

      final textSpan = TextSpan(
        text:
            '${calculateAngle(points[i], points[i + 1], points[i + 2]).round()}°',
        style: TextStyle(
          color: Colors.black,
          fontSize: size.width > 1024 ? 27 : 13.5,
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
          (angleWidgetPositions[i].dx / containerScale * scale -
                  (scaledBoundingBox.left)) +
              (((size.width - scaledBoundingBox.width) / 2)) -
              angleDirection.dx,
          (angleWidgetPositions[i].dy / containerScale * scale -
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
        (colourPosition.dx / containerScale * scale -
                (scaledBoundingBox.left)) +
            (((size.width - scaledBoundingBox.width) / 2)),
        (colourPosition.dy / containerScale * scale - (scaledBoundingBox.top)) +
            (((size.width - scaledBoundingBox.height) / 2)));
    Offset colourNormalVector =
        calculateNormalizedDirectionVector(colourMidPoint, colourPosition);
    colourNormalVector =
        Offset(colourNormalVector.dx * 10, colourNormalVector.dy * 10);

    TextSpan colourSpan = TextSpan(
        text: 'C',
        style: TextStyle(
            color: Colors.black,
            fontSize: size.width > 1024 ? 36 : 18,
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

    //region DashedLines
    if (tapered) {
      double taperDashAngle =
          taperedState == 1 ? -5 * math.pi / 4.2 : -5 * math.pi / 4.2 + math.pi;
      for (int i = 0; i < points.length; i++) {
        drawDashedLine(
          canvas,
          Offset(
              (points[i].dx / containerScale * scale -
                      (scaledBoundingBox.left)) +
                  (((size.width - scaledBoundingBox.width) / 2)),
              (points[i].dy / containerScale * scale -
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

    //region DrawLines
    for (int i = 0; i < points.length - 1; i++) {
      canvas.drawLine(
          Offset(
              (points[i].dx / containerScale * scale -
                      (scaledBoundingBox.left)) +
                  (((size.width - scaledBoundingBox.width) / 2)),
              (points[i].dy / containerScale * scale -
                      (scaledBoundingBox.top)) +
                  (((size.width - scaledBoundingBox.height) / 2))),
          Offset(
              (points[i + 1].dx / containerScale * scale -
                      (scaledBoundingBox.left)) +
                  (((size.width - scaledBoundingBox.width) / 2)),
              (points[i + 1].dy / containerScale * scale -
                      (scaledBoundingBox.top)) +
                  (((size.width - scaledBoundingBox.height) / 2))),
          linesPaint);
    }
    //endregion

    //region CF1
    if (points.length > 1 && cf1State > 0) {
      Offset cf_1NormalVector =
          calculatePerpendicularVector(points[0], points[1]);

      Offset cF_1Center = cf1State == 1
          ? ScalePointToCanvas(points[0]) +
              (Offset(cf_1NormalVector.dx * clampDouble(4, 2, double.infinity),
                  cf_1NormalVector.dy * clampDouble(4, 2, double.infinity)))
          : ScalePointToCanvas(points[0]) -
              (Offset(cf_1NormalVector.dx * clampDouble(4, 2, double.infinity),
                  cf_1NormalVector.dy * clampDouble(4, 2, double.infinity)));
      Offset cF_1End = cf1State == 1
          ? ScalePointToCanvas(points[0]) +
              (Offset(cf_1NormalVector.dx * clampDouble(8, 4, double.infinity),
                  cf_1NormalVector.dy * clampDouble(8, 4, double.infinity)))
          : ScalePointToCanvas(points[0]) -
              (Offset(cf_1NormalVector.dx * clampDouble(8, 4, double.infinity),
                  cf_1NormalVector.dy * clampDouble(8, 4, double.infinity)));

      Offset CenterDir = calculateNormalizedDirectionVector(
          cF_1Center, ScalePointToCanvas(points[0]));

      double startAngle = math.atan2(CenterDir.dy, CenterDir.dx);

      final double pixelScaleCF1 = size.width / boundingBox.longestSide;

      final double cf1PixelLength =
          cf1Length * pixelScaleCF1 * 2.666666666666667;

      final Offset dir =
          calculateNormalizedDirectionVector(points[0], points[1]);

      canvas.drawArc(
        Rect.fromCircle(
          center: cF_1Center,
          radius: clampDouble(4, 2, double.infinity),
        ),
        startAngle,
        cf1State == 1 ? -math.pi : math.pi,
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
    if (points.length > 1 && cf2State > 0) {
      Offset cf_2NormalVector = calculatePerpendicularVector(
          points[points.length - 1], points[points.length - 2]);

      Offset cF_2Center = cf2State == 1
          ? ScalePointToCanvas(points[points.length - 1]) +
              (Offset(cf_2NormalVector.dx * clampDouble(4, 2, double.infinity),
                  cf_2NormalVector.dy * clampDouble(4, 2, double.infinity)))
          : ScalePointToCanvas(points[points.length - 1]) -
              (Offset(cf_2NormalVector.dx * clampDouble(4, 2, double.infinity),
                  cf_2NormalVector.dy * clampDouble(4, 2, double.infinity)));
      Offset cF_2End = cf2State == 1
          ? ScalePointToCanvas(points[points.length - 1]) +
              (Offset(cf_2NormalVector.dx * clampDouble(8, 4, double.infinity),
                  cf_2NormalVector.dy * clampDouble(8, 4, double.infinity)))
          : ScalePointToCanvas(points[points.length - 1]) -
              (Offset(cf_2NormalVector.dx * clampDouble(8, 4, double.infinity),
                  cf_2NormalVector.dy * clampDouble(8, 4, double.infinity)));

      Offset CenterDir = calculateNormalizedDirectionVector(
          cF_2Center, ScalePointToCanvas(points[points.length - 1]));

      double startAngle = math.atan2(CenterDir.dy, CenterDir.dx);

      final double pixelScaleCF2 = size.width / boundingBox.longestSide;
      final double cf2PixelLength =
          cf2Length * pixelScaleCF2 * 2.666666666666667;

      final Offset dir2 = calculateNormalizedDirectionVector(
        points.last,
        points[points.length - 2],
      );
      canvas.drawArc(
        Rect.fromCircle(
            center: cF_2Center, radius: clampDouble(4, 2, double.infinity)),
        startAngle,
        cf2State == 1 ? -math.pi : math.pi,
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
  bool shouldRepaint(FlashingDetailsCustomPainter oldDelegate) => true;
}

class _CombinedPainter extends CustomPainter {
  final CustomPainter near, far;
  _CombinedPainter({required this.near, required this.far});

  @override
  void paint(Canvas canvas, Size size) {
    // assume size.width == w1 + w2, size.height == h
    final w = size.width / 2;
    final h = size.height;

    // paint the “near” taper into the left half
    near.paint(canvas, Size(w, h));

    // shift right by w and paint the “far” taper
    canvas.translate(w, 0);
    far.paint(canvas, Size(w, h));
  }

  @override
  bool shouldRepaint(covariant _CombinedPainter old) {
    // you can be more granular, but this is safe:
    return true;
  }
}
