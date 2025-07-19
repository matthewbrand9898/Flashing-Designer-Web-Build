import 'dart:js_interop';

import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:web/web.dart' as web;

import 'flashing_details_viewer.dart';
import 'flashing_thumbnail_list.dart';

import 'helper_functions.dart';
import 'models/designer_model.dart';
import 'order_storage.dart';

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
      required this.job,
      required this.flashingID,
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
  final String job;
  final String flashingID;

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

/// Downloads [pngBytes] as a PNG file named [filename].
void downloadPngAsFile(Uint8List pngBytes, String filename) {
  // 1) Convert Dart ByteBuffer → JS ArrayBuffer
  final arrayBuffer = pngBytes.buffer.toJS;

  // 2) Put it into a JSArray<JSAny>
  final parts = <JSAny>[arrayBuffer].toJS;

  // 3) Build a Blob with the PNG MIME type
  final blob = web.Blob(
    parts,
    web.BlobPropertyBag(type: 'image/png'),
  );

  // 4) Create a temporary object URL
  final url = web.URL.createObjectURL(blob);

  // 5) Create and configure an <a> for download
  final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
  anchor.href = url;
  anchor.download =
      filename; // sets the default file name :contentReference[oaicite:0]{index=0}

  // 6) Add to DOM, click, then clean up
  web.document.body?.append(anchor);
  anchor.click();
  anchor.remove();

  // 7) Release memory
  web.URL.revokeObjectURL(
      url); // free the blob URL :contentReference[oaicite:1]{index=1}
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
  bool _isRunning = false;

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
      floatingActionButton: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
        onPressed: () async {
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
                  job: widget.job,
                  flashingID: widget.flashingID,
                ),
                const Size(2048, 2048));
            downloadPngAsFile(bytes, 'flashing.png');
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
              job: widget.job,
              flashingID: widget.flashingID,
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
              job: widget.job,
              flashingID: widget.flashingID,
            );
            _CombinedPainter? combined =
                _CombinedPainter(near: nearPainter, far: farPainter);
            Uint8List? taperedBytes =
                await generateImageBytes(combined, const Size(4096, 2048));
            downloadPngAsFile(taperedBytes, 'tapered flashing.png');
            combined = null;
            taperedBytes = null;
            nearPainter = null;
            farPainter = null;
          }
        },
        child: const Text(
          'DOWNLOAD IMAGE',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Kanit',
          ),
        ),
      ),
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
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
          "FLASHING DETAILS",
          style: TextStyle(fontFamily: "Kanit", color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          TextButton(
              style: TextButton.styleFrom(
                  foregroundColor: Colors.deepPurple.shade50),
              onPressed: () async {
                if (_isRunning) return;

                _isRunning = true;

                try {
                  if (!widget.tapered) {
                    if (context.mounted) {
                      DesignerModel designerModel =
                          Provider.of<DesignerModel>(context, listen: false);

                      if (designerModel.isEditingFlashing) {
                        designerModel.editFlashing(designerModel.saveFlashing(),
                            designerModel.editFlashingID);

                        designerModel.isEditingFlashing = false;
                      } else {
                        designerModel.addFlashing(designerModel.saveFlashing());
                      }
                    }
                  } else {
                    if (context.mounted) {
                      DesignerModel designerModel =
                          Provider.of<DesignerModel>(context, listen: false);

                      if (designerModel.isEditingFlashing) {
                        designerModel.editFlashing(designerModel.saveFlashing(),
                            designerModel.editFlashingID);
                        designerModel
                            .flashings[designerModel.editFlashingID].images
                            .clear();

                        designerModel.isEditingFlashing = false;
                      } else {
                        designerModel.addFlashing(designerModel.saveFlashing());
                      }
                    }
                  }
                  if (!context.mounted) return;
                  DesignerModel designerModel =
                      Provider.of<DesignerModel>(context, listen: false);

                  final orders = await OrderStorage.readOrders();
                  final idx = designerModel.currentOrderIndex!;
                  orders[idx].flashings
                    ..clear()
                    ..addAll(designerModel.flashings);

                  await OrderStorage.saveOrder(orders[idx]);
                  if (!context.mounted) return;
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FlashingGridPage(),
                      ));
                } finally {
                  _isRunning = false;
                }
              },
              child: const Text(
                "NEXT",
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
              child: SingleChildScrollView(
                child: Wrap(
                  runSpacing: 20,
                  spacing: 20,
                  alignment: WrapAlignment.center,
                  children: [
                    if (!widget.tapered)
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 32.0, right: 32.0, top: 8.0, bottom: 8.0),
                        child: FittedBox(
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
                                  job: widget.job,
                                  flashingID: widget.flashingID,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (widget.tapered)
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 32.0, right: 32.0, top: 8.0, bottom: 8.0),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Card(
                            color: Colors.white,
                            elevation: 8,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
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
                                  job: widget.job,
                                  flashingID: widget.flashingID,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (widget.tapered)
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 32.0, right: 32.0, top: 8.0, bottom: 8.0),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Card(
                            color: Colors.white,
                            elevation: 8,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
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
                                  job: widget.job,
                                  flashingID: widget.flashingID,
                                ),
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
        ],
      ),
    );
  }
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
