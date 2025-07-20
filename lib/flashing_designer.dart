import 'angle_widget.dart';
import 'cf1_widget.dart';
import 'circular_angle_widget.dart';
import 'colour_direction_widget.dart';
import 'edit_angle.dart';
import 'edit_cf.dart';
import 'edit_length.dart';

import 'global_keys.dart';
import 'length_widget.dart';
import 'preview_3d.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:convex_bottom_bar/convex_bottom_bar.dart';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';

import 'cf2_widget.dart';
import 'flashing_details.dart';
import 'draw.dart';
import 'flashing_thumbnail_list.dart';
import 'helper_functions.dart';
import 'models/designer_model.dart';

double rotation = 0;

class FlashingDesigner extends StatelessWidget {
  const FlashingDesigner({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        floatingActionButton:
            (Provider.of<DesignerModel>(context, listen: false)
                        .bottomBarIndex ==
                    1)
                ? Padding(
                    padding: EdgeInsets.only(
                        top: Provider.of<DesignerModel>(context, listen: false)
                                .tapered
                            ? 250
                            : 190,
                        left: 16),
                    child: FloatingActionButton(
                        backgroundColor: Colors.deepPurple,
                        tooltip: 'Reset view',
                        child: Icon(
                          Icons.filter_center_focus_rounded,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          Provider.of<DesignerModel>(context, listen: false)
                              .resetTransformController(
                                  MediaQuery.of(context).size);
                        }),
                  )
                : null,
        backgroundColor: Colors.grey.shade50,
        floatingActionButtonLocation: FloatingActionButtonLocation.miniStartTop,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FlashingGridPage()),
              );
            },
          ),
          backgroundColor: Colors.deepPurple.shade500,
          title: const Text(
            "DESIGNER",
            style: TextStyle(fontFamily: "Kanit", color: Colors.white),
          ),
          centerTitle: true,
          actions: [
            if (Provider.of<DesignerModel>(context, listen: false)
                    .bottomBarIndex ==
                1)
              TextButton(
                style: TextButton.styleFrom(
                    foregroundColor: Colors.deepPurple.shade50),
                onPressed: () async {
                  final designerModel =
                      Provider.of<DesignerModel>(context, listen: false);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FlashingDetails(
                        lengthPosOffsets: designerModel.lengthPositions_Offsets,
                        points: designerModel.points,
                        anglePos: designerModel.anglePositions,
                        anglePosOffsets: designerModel.anglePositions_Offsets,
                        lengthPos: designerModel.lengthPositions,
                        boundingBox: calculateBoundingBoxWithUi(
                          designerModel.points,
                          designerModel.lengthPositions,
                          designerModel.anglePositions,
                        ),
                        girth: designerModel.girth,
                        lengthWidgetText: designerModel.lengthWidgetText,
                        colourPosition: designerModel.colourPosition,
                        colourMidPoint: designerModel.colourMidpoint,
                        tapered: designerModel.tapered,
                        taperedState: designerModel.taperedState,
                        cf1State: designerModel.cf_1State,
                        cf2State: designerModel.cf_2State,
                        cf1Length: designerModel.cf_1Length,
                        cf2Length: designerModel.cf_2Length,
                        material: designerModel.material,
                        lengths: designerModel.lengths,
                        job: designerModel.job,
                        flashingID: designerModel.flashingID,
                      ),
                    ),
                  );
                },
                child: const Text(
                  "NEXT",
                  style: TextStyle(fontFamily: "Kanit", color: Colors.white),
                ),
              ),
            const Padding(padding: EdgeInsets.only(right: 15)),
          ],
        ),
        bottomNavigationBar: ConvexAppBar(
          key: appBarKey,
          backgroundColor: Colors.deepPurple.shade500,
          color: Colors.white,
          items: const [
            TabItem(
              icon: Icons.draw,
              title: 'DRAW',
              fontFamily: "Kanit",
            ),
            TabItem(
              icon: Icons.edit_note,
              title: 'EDIT',
              fontFamily: "Kanit",
            ),
            TabItem(
              icon: Icons.construction_rounded,
              title: 'CF',
              fontFamily: "Kanit",
            ),
            TabItem(
              icon: Icons.rotate_left,
              title: 'ROTATE',
              fontFamily: "Kanit",
            ),
            TabItem(
              icon: Icons.undo,
              title: 'UNDO',
              fontFamily: "Kanit",
            ),
          ],
          onTap: (int i) {
            if (i < 4) {
              Provider.of<DesignerModel>(context, listen: false)
                  .editBottomBarIndex(i);
              i == 2
                  ? Provider.of<DesignerModel>(context, listen: false)
                      .editShowCrushAndFoldUI(true)
                  : Provider.of<DesignerModel>(context, listen: false)
                      .editShowCrushAndFoldUI(false);
            }
          },
          onTabNotify: (int i) {
            if (i == 1 || i == 2 || i == 3) {
              if (Provider.of<DesignerModel>(context, listen: false)
                      .points
                      .length <
                  2) {
                return false;
              }
            }

            var intercept = i == 4;
            if (intercept) {
              Provider.of<DesignerModel>(context, listen: false).Undo();
              if (Provider.of<DesignerModel>(context, listen: false)
                      .points
                      .length <
                  2) {
                appBarKey.currentState?.tap(0);
              }
            }
            return !intercept;
          },
        ),
        body: Stack(children: [
          Consumer<DesignerModel>(
            builder: (context, designerModel, child) {
              return InteractiveViewer(
                onInteractionUpdate: (scaleUpdateDetails) {
                  designerModel.editInteractiveZoomFactor(designerModel
                      .transformationController.value
                      .getMaxScaleOnAxis());

                  if (designerModel.oldInteractiveZoomFactor !=
                      designerModel.interactiveZoomFactor) {
                    for (int i = 0;
                        i < designerModel.lengthPositions.length;
                        i++) {
                      designerModel.editLengthPositionOffset(
                          i,
                          lengthOffset(
                              designerModel.points,
                              designerModel.lengthPositions,
                              designerModel.interactiveZoomFactor,
                              i + 1,
                              i,
                              verticalScaler(designerModel.points,
                                  designerModel.lengthPositions, i + 1, i)));
                    }

                    for (int i = 0;
                        i < designerModel.nearLengthPositions.length;
                        i++) {
                      designerModel.editNearLengthPositionOffset(
                          i,
                          lengthOffset(
                              designerModel.nearPoints,
                              designerModel.nearLengthPositions,
                              designerModel.interactiveZoomFactor,
                              i + 1,
                              i,
                              verticalScaler(
                                  designerModel.nearPoints,
                                  designerModel.nearLengthPositions,
                                  i + 1,
                                  i)));
                    }
                    for (int i = 0;
                        i < designerModel.farLengthPositions.length;
                        i++) {
                      designerModel.editFarLengthPositionOffset(
                          i,
                          lengthOffset(
                              designerModel.farPoints,
                              designerModel.farLengthPositions,
                              designerModel.interactiveZoomFactor,
                              i + 1,
                              i,
                              verticalScaler(designerModel.farPoints,
                                  designerModel.farLengthPositions, i + 1, i)));
                    }

                    for (int i = 0;
                        i < designerModel.anglePositions.length;
                        i++) {
                      designerModel.editAnglePositionOffset(
                          i,
                          angleOffset(
                              designerModel.points,
                              designerModel.anglePositions,
                              designerModel.interactiveZoomFactor,
                              i + 1,
                              i));
                    }

                    for (int i = 0;
                        i < designerModel.nearAnglePositions.length;
                        i++) {
                      designerModel.editNearAnglePositionOffset(
                          i,
                          angleOffset(
                              designerModel.nearPoints,
                              designerModel.nearAnglePositions,
                              designerModel.interactiveZoomFactor,
                              i + 1,
                              i));
                    }

                    for (int i = 0;
                        i < designerModel.farAnglePositions.length;
                        i++) {
                      designerModel.editFarAnglePositionOffset(
                          i,
                          angleOffset(
                              designerModel.farPoints,
                              designerModel.farAnglePositions,
                              designerModel.interactiveZoomFactor,
                              i + 1,
                              i));
                    }
                  }

                  designerModel.editOldInteractiveZoomFactor(
                      designerModel.interactiveZoomFactor);
                },
                transformationController:
                    designerModel.transformationController,
                maxScale: 4,
                minScale: 0.15,
                constrained: false,
                child: LayoutBuilder(
                  builder: (ctx, constraints) => FittedBox(
                    fit: BoxFit.contain,
                    child: SizedBox(
                      width: 20000,
                      height: 20000,
                      child: Stack(
                        children: [
                          RepaintBoundary(
                            child: CustomPaint(
                              foregroundPainter: Draw(
                                points: designerModel.points,
                                lengthPositions: designerModel.lengthPositions,
                                lengthPositions_Offsets:
                                    designerModel.lengthPositions_Offsets,
                                anglePositions_Offsets:
                                    designerModel.anglePositions_Offsets,
                                anglePositions: designerModel.anglePositions,
                                bottomNavbarIndex: designerModel.bottomBarIndex,
                                scaleFactor:
                                    designerModel.interactiveZoomFactor,
                                boundingBox: calculateBoundingBox(
                                  designerModel.points,
                                ),
                                showCFUI: designerModel.showCrushAndFoldUI,
                                cF1_state: designerModel.cf_1State,
                                cF2_state: designerModel.cf_2State,
                                cF1_position: designerModel.cf_1Position,
                                cF1_length: designerModel.cf_1Length,
                                cF2_length: designerModel.cf_2Length,
                                cF2_position: designerModel.cf_2Position,
                                Hide_90_45Angles: designerModel.Hide90_45Angles,
                                TaperedState: designerModel.taperedState,
                                Tapered: designerModel.tapered,
                              ),
                              child: RepaintBoundary(
                                child: GridPaper(
                                  color: Colors.grey,
                                  divisions: 1,
                                  interval: 200,
                                  child: GestureDetector(
                                    onTapUp: (TapUpDetails details) {
                                      if (designerModel.bottomBarIndex == 1) {
                                        for (int i = 1;
                                            i < designerModel.points.length - 1;
                                            i++) {
                                          Rect rect = Rect.fromCenter(
                                              center: designerModel.points[i],
                                              width: 40,
                                              height: 40);
                                          if (rect.contains(
                                              details.localPosition)) {
                                            designerModel
                                                .editShowAngleEdit(true);
                                            designerModel
                                                .editSelectedPointIndex(i);
                                          }
                                        }
                                      }

                                      if (designerModel.bottomBarIndex == 3) {
                                        for (int i = 0;
                                            i < designerModel.points.length;
                                            i++) {
                                          Rect rect = Rect.fromCenter(
                                              center: designerModel.points[i],
                                              width: 40,
                                              height: 40);
                                          if (rect.contains(
                                              details.localPosition)) {
                                            designerModel
                                                .editSelectedRotationPointIndex(
                                                    i);
                                          }
                                        }
                                      }

                                      if (designerModel.bottomBarIndex == 2) {
                                        Offset cFdir_1 =
                                            calculateNormalizedDirectionVector(
                                                designerModel.points[1],
                                                designerModel.points[0]);
                                        cFdir_1 *= 25 +
                                            (30 /
                                                designerModel
                                                    .interactiveZoomFactor);
                                        Offset cFdir_2 =
                                            calculateNormalizedDirectionVector(
                                                designerModel.points[
                                                    designerModel
                                                            .points.length -
                                                        2],
                                                designerModel.points[
                                                    designerModel
                                                            .points.length -
                                                        1]);
                                        cFdir_2 *= 25 +
                                            (30 /
                                                designerModel
                                                    .interactiveZoomFactor);
                                        Rect CF1Rect = Rect.fromCenter(
                                            center: designerModel.points[0] +
                                                cFdir_1,
                                            width: 50 +
                                                (30 /
                                                    designerModel
                                                        .interactiveZoomFactor),
                                            height: 50 +
                                                (30 /
                                                    designerModel
                                                        .interactiveZoomFactor));
                                        Rect CF2Rect = Rect.fromCenter(
                                            center: designerModel.points[
                                                    designerModel
                                                            .points.length -
                                                        1] +
                                                cFdir_2,
                                            width: 50 +
                                                (30 /
                                                    designerModel
                                                        .interactiveZoomFactor),
                                            height: 50 +
                                                (30 /
                                                    designerModel
                                                        .interactiveZoomFactor));

                                        if (CF1Rect.contains(
                                            details.localPosition)) {
                                          if (designerModel.cf_1State == 0) {
                                            designerModel.editCf_1length(15);
                                          }
                                          designerModel.editCf_1State(
                                              designerModel.cf_1State + 1);

                                          if (designerModel.cf_1State > 2) {
                                            designerModel.editCf_1State(0);
                                            designerModel.editCf_1length(0);
                                          } else {
                                            designerModel.editCf_1Position(cf1Midpoint(
                                                    designerModel.points,
                                                    designerModel.cf_1State,
                                                    designerModel.cf_1Length,
                                                    designerModel
                                                        .interactiveZoomFactor) -
                                                (calculatePerpendicularVector(
                                                        designerModel.points[0],
                                                        designerModel
                                                            .points[1]) *
                                                    (designerModel.cf_1State ==
                                                            1
                                                        ? -1
                                                        : 1)));
                                          }
                                        }
                                        if (CF2Rect.contains(
                                            details.localPosition)) {
                                          if (designerModel.cf_2State == 0) {
                                            designerModel.editCf_2length(15);
                                          }
                                          designerModel.editCf_2State(
                                              designerModel.cf_2State + 1);

                                          if (designerModel.cf_2State > 2) {
                                            designerModel.editCf_2State(0);
                                            designerModel.editCf_2length(0);
                                          } else {
                                            designerModel.editCf_2Position(cf2Midpoint(
                                                    designerModel.points,
                                                    designerModel.cf_2State,
                                                    designerModel.cf_2Length,
                                                    designerModel
                                                        .interactiveZoomFactor) -
                                                (calculatePerpendicularVector(
                                                        designerModel.points[
                                                            designerModel.points
                                                                    .length -
                                                                2],
                                                        designerModel.points[
                                                            designerModel.points
                                                                    .length -
                                                                1]) *
                                                    (designerModel.cf_2State ==
                                                            1
                                                        ? -1
                                                        : 1)));
                                          }
                                        }
                                      }

                                      if (!designerModel.points.contains(Offset(
                                              (details.localPosition.dx / 40)
                                                      .roundToDouble() *
                                                  40,
                                              (details.localPosition.dy / 40)
                                                      .roundToDouble() *
                                                  40)) &&
                                          designerModel.bottomBarIndex == 0) {
                                        designerModel.addPoint(Offset(
                                            (details.localPosition.dx / 40)
                                                    .roundToDouble() *
                                                40,
                                            (details.localPosition.dy / 40)
                                                    .roundToDouble() *
                                                40));
                                        if (designerModel.points.length > 1) {
                                          designerModel.addLengthPosition(
                                              initialLengthPos(
                                                  designerModel.points,
                                                  designerModel.points.length -
                                                      1,
                                                  designerModel.points.length -
                                                      2));
                                          designerModel.addLengthScale(1);

                                          designerModel.addLengthPositionOffset(
                                              lengthOffset(
                                                  designerModel.points,
                                                  designerModel.lengthPositions,
                                                  designerModel
                                                      .interactiveZoomFactor,
                                                  designerModel.points.length -
                                                      1,
                                                  designerModel.points.length -
                                                      2,
                                                  verticalScaler(
                                                      designerModel.points,
                                                      designerModel
                                                          .lengthPositions,
                                                      designerModel
                                                              .points.length -
                                                          1,
                                                      designerModel
                                                              .points.length -
                                                          2)));

                                          designerModel.updateColourPosition();
                                          if (designerModel.cf_2State != 0) {
                                            designerModel.editCf_2Position(cf2Midpoint(
                                                    designerModel.points,
                                                    designerModel.cf_2State,
                                                    designerModel.cf_2Length,
                                                    designerModel
                                                        .interactiveZoomFactor) -
                                                (calculatePerpendicularVector(
                                                        designerModel.points[
                                                            designerModel.points
                                                                    .length -
                                                                2],
                                                        designerModel.points[
                                                            designerModel.points
                                                                    .length -
                                                                1]) *
                                                    (designerModel.cf_2State ==
                                                            1
                                                        ? -1
                                                        : 1)));
                                          }
                                        }
                                        if (designerModel.points.length > 2) {
                                          designerModel.addAnglePosition(
                                              initialAnglePos(
                                                  designerModel.points,
                                                  designerModel.points.length -
                                                      1,
                                                  designerModel.points.length -
                                                      2));
                                          designerModel.addAngleScale(1);

                                          designerModel.addAnglePositionOffset(
                                              angleOffset(
                                                  designerModel.points,
                                                  designerModel.anglePositions,
                                                  designerModel
                                                      .interactiveZoomFactor,
                                                  designerModel.points.length -
                                                      2,
                                                  designerModel.anglePositions
                                                          .length -
                                                      1));
                                        }
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                          if (designerModel.points.isNotEmpty &&
                              designerModel.bottomBarIndex == 1)
                            for (var i = 1;
                                i < designerModel.points.length;
                                i++)
                              LengthWidget(index: i),
                          if (designerModel.points.length > 2 &&
                              designerModel.bottomBarIndex == 1)
                            for (var i = 1;
                                i < designerModel.points.length - 1;
                                i++)
                              if (calculateAngle(
                                                  designerModel.points[i - 1],
                                                  designerModel.points[i],
                                                  designerModel.points[i + 1])
                                              .round() !=
                                          90 &&
                                      calculateAngle(
                                                  designerModel.points[i - 1],
                                                  designerModel.points[i],
                                                  designerModel.points[i + 1])
                                              .round() !=
                                          45 &&
                                      calculateAngle(
                                                  designerModel.points[i - 1],
                                                  designerModel.points[i],
                                                  designerModel.points[i + 1])
                                              .round() !=
                                          135 ||
                                  designerModel.Hide90_45Angles == false)
                                AngleWidget(index: i),
                          if (designerModel.cf_1State != 0 &&
                              designerModel.bottomBarIndex == 1)
                            const CF1Widget(),
                          if (designerModel.cf_2State != 0 &&
                              designerModel.bottomBarIndex == 1)
                            const CF2Widget(),
                          if (designerModel.points.isNotEmpty &&
                              designerModel.bottomBarIndex == 3 &&
                              designerModel.points.length >=
                                  designerModel.SelectedRotationPoint + 1)
                            Positioned(
                              left: designerModel
                                      .points[
                                          designerModel.SelectedRotationPoint]
                                      .dx -
                                  100,
                              top: designerModel
                                      .points[
                                          designerModel.SelectedRotationPoint]
                                      .dy -
                                  100,
                              child: Transform.scale(
                                scale: 1 / designerModel.interactiveZoomFactor,
                                child: InfiniteCircularAngleDrag(
                                  size: 200,
                                  strokeWidth: 25,
                                  handleRadius: 25,
                                  initialAngle: rotation,
                                  sensitivity: 3.0, // drag 3px = 1° turn
                                  onAngleChanged: (ang) {
                                    rotation = ang;
                                    designerModel.editFlashingRotationAngle(
                                        ang.roundToDouble() * 1);
                                  },
                                ),
                              ),
                            ),
                          if (designerModel.bottomBarIndex == 1 &&
                              designerModel.points.length >= 2)
                            const ColourDirection(),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          if (Provider.of<DesignerModel>(context, listen: true).showLengthEdit)
            Positioned(
              bottom: 0,
              child: SizedBox(
                width: constraints.maxWidth,
                child: const EditLength(),
              ),
            ),
          if (Provider.of<DesignerModel>(context, listen: true).showCFEdit)
            Positioned(
              bottom: 0,
              child: SizedBox(
                width: constraints.maxWidth,
                child: const EditCFLength(),
              ),
            ),
          if (Provider.of<DesignerModel>(context, listen: true).showAngleEdit)
            Positioned(
              bottom: 0,
              child: SizedBox(
                width: constraints.maxWidth,
                child: const EditAngle(),
              ),
            ),
          if (Provider.of<DesignerModel>(context, listen: true)
                  .bottomBarIndex ==
              1)
            Positioned(
                top: 0,
                left: 0,
                child: Container(
                  color: Colors.white,
                  width: MediaQuery.of(context).size.width,
                  height:
                      (Provider.of<DesignerModel>(context, listen: true).tapered
                          ? 75
                          : 50),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (Provider.of<DesignerModel>(context, listen: true)
                              .bottomBarIndex ==
                          1)
                        Flexible(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                            child: Center(
                              child: AutoSizeText(
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                "GIRTH ${Provider.of<DesignerModel>(context, listen: true).girth}mm",
                                style: TextStyle(
                                    fontFamily: "Kanit",
                                    color: Colors.deepPurple.shade500),
                              ),
                            ),
                          ),
                        ),
                      if (Provider.of<DesignerModel>(context, listen: true)
                              .bottomBarIndex ==
                          1)
                        Flexible(
                          child: TextButton(
                              onPressed: () {
                                if (Provider.of<DesignerModel>(context,
                                        listen: false)
                                    .tapered) {
                                  if (Provider.of<DesignerModel>(context,
                                              listen: false)
                                          .taperedState ==
                                      1) {
                                    Provider.of<DesignerModel>(context,
                                            listen: false)
                                        .saveFarTaper();
                                  } else {
                                    Provider.of<DesignerModel>(context,
                                            listen: false)
                                        .saveNearTaper();
                                  }
                                }

                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => CubeOrbitPage(
                                        points: Provider.of<DesignerModel>(
                                                context,
                                                listen: false)
                                            .points,
                                        pointsFar: Provider.of<DesignerModel>(
                                                context,
                                                listen: false)
                                            .farPoints,
                                        pointsNear: Provider.of<DesignerModel>(
                                                context,
                                                listen: false)
                                            .nearPoints,
                                        tapered: Provider.of<DesignerModel>(
                                                context,
                                                listen: false)
                                            .tapered,
                                        nearLengthWidgetText:
                                            Provider.of<DesignerModel>(context,
                                                    listen: false)
                                                .nearLengthWidgetText,
                                        nearLengthPositions:
                                            Provider.of<DesignerModel>(context,
                                                    listen: false)
                                                .nearLengthPositions,
                                        nearLengthPositionOffsets:
                                            Provider.of<DesignerModel>(context,
                                                    listen: false)
                                                .nearLengthPositions_Offsets,
                                        lengthPositions:
                                            Provider.of<DesignerModel>(context,
                                                    listen: false)
                                                .lengthPositions,
                                        lengthPositionOffsets:
                                            Provider.of<DesignerModel>(context,
                                                    listen: false)
                                                .lengthPositions_Offsets,
                                        lengthWidgetText:
                                            Provider.of<DesignerModel>(context,
                                                    listen: false)
                                                .lengthWidgetText,
                                        farLengthPositions:
                                            Provider.of<DesignerModel>(context,
                                                    listen: false)
                                                .farLengthPositions,
                                        farLengthPositionOffsets:
                                            Provider.of<DesignerModel>(context,
                                                    listen: false)
                                                .farLengthPositions_Offsets,
                                        farLengthWidgetText:
                                            Provider.of<DesignerModel>(context,
                                                    listen: false)
                                                .farLengthWidgetText,
                                        colorSide: Provider.of<DesignerModel>(
                                                context,
                                                listen: false)
                                            .colourSide,
                                        color: Provider.of<DesignerModel>(
                                                context,
                                                listen: false)
                                            .currentColour,
                                      ),
                                    ));
                              },
                              child: Text(
                                '3D',
                                style: TextStyle(
                                    fontFamily: "Kanit",
                                    color: Colors.deepPurple.shade500),
                              )),
                        ),
                      if (Provider.of<DesignerModel>(context, listen: true)
                              .bottomBarIndex ==
                          1)
                        Flexible(
                          child: IconButton(
                            color: Colors.deepPurple.shade500,
                            icon: Icon(Provider.of<DesignerModel>(context,
                                        listen: false)
                                    .Hide90_45Angles
                                ? Icons.visibility_off
                                : Icons.visibility),
                            onPressed: () {
                              Provider.of<DesignerModel>(context, listen: false)
                                  .editHide90_45Angles(
                                      !Provider.of<DesignerModel>(context,
                                              listen: false)
                                          .Hide90_45Angles);
                            },
                          ),
                        ),
                      if (Provider.of<DesignerModel>(context, listen: true)
                              .bottomBarIndex ==
                          1)
                        Flexible(
                          child: IconButton(
                            color: Colors.deepPurple.shade500,
                            icon: const Icon(Icons.swap_horiz_rounded),
                            onPressed: () {
                              Provider.of<DesignerModel>(context, listen: false)
                                  .swapColourSide();
                            },
                          ),
                        ),
                      if (Provider.of<DesignerModel>(context, listen: true)
                              .bottomBarIndex ==
                          1)
                        Flexible(
                          child: IconButton(
                            icon: SvgPicture.asset('images/taperIcon.svg',
                                width: 25,
                                height: 25,
                                semanticsLabel: 'Taper Icon'),
                            onPressed: () {
                              if (Provider.of<DesignerModel>(context,
                                          listen: false)
                                      .tapered ==
                                  false) {
                                Provider.of<DesignerModel>(context,
                                        listen: false)
                                    .enableTaper();
                              } else {
                                Provider.of<DesignerModel>(context,
                                        listen: false)
                                    .disableTaper();
                              }
                            },
                          ),
                        ),
                      if (Provider.of<DesignerModel>(context, listen: true)
                                  .bottomBarIndex ==
                              1 &&
                          Provider.of<DesignerModel>(context, listen: true)
                              .tapered)
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              style: ButtonStyle(
                                  shape: const WidgetStatePropertyAll(
                                      RoundedRectangleBorder(
                                          borderRadius: BorderRadius.zero)),
                                  backgroundColor: Provider.of<DesignerModel>(
                                                  context,
                                                  listen: false)
                                              .taperedState ==
                                          0
                                      ? WidgetStatePropertyAll(
                                          Colors.deepPurple.shade100)
                                      : const WidgetStatePropertyAll(
                                          Colors.transparent)),
                              child: Text(
                                'NEAR',
                                style: TextStyle(
                                    color: Colors.deepPurple.shade500,
                                    fontFamily: 'Kanit'),
                              ),
                              onPressed: () {
                                if (Provider.of<DesignerModel>(context,
                                            listen: false)
                                        .taperedState !=
                                    0) {
                                  Provider.of<DesignerModel>(context,
                                          listen: false)
                                      .swapTaper(0);
                                }
                              },
                            ),
                            TextButton(
                              style: ButtonStyle(
                                  shape: const WidgetStatePropertyAll(
                                      RoundedRectangleBorder(
                                          borderRadius: BorderRadius.zero)),
                                  backgroundColor: Provider.of<DesignerModel>(
                                                  context,
                                                  listen: false)
                                              .taperedState ==
                                          1
                                      ? WidgetStatePropertyAll(
                                          Colors.deepPurple.shade100)
                                      : const WidgetStatePropertyAll(
                                          Colors.transparent)),
                              child: Text(
                                'FAR',
                                style: TextStyle(
                                    color: Colors.deepPurple.shade500,
                                    fontFamily: 'Kanit'),
                              ),
                              onPressed: () {
                                if (Provider.of<DesignerModel>(context,
                                            listen: false)
                                        .taperedState !=
                                    1) {
                                  Provider.of<DesignerModel>(context,
                                          listen: false)
                                      .swapTaper(1);
                                }
                              },
                            ),
                          ],
                        ),
                    ],
                  ),
                )),
        ]),
      );
    });
  }
}
