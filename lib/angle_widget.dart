import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'helper_functions.dart';
import 'models/designer_model.dart';

class AngleWidget extends StatelessWidget {
  const AngleWidget({required this.index, super.key});
  final int index;

  @override
  Widget build(BuildContext context) {
    return Consumer<DesignerModel>(builder: (context, designerModel, child) {
      return Positioned(
          left: designerModel.anglePositions[index - 1].dx -
              designerModel.anglePositions_Offsets[index - 1].dx -
              20,
          top: designerModel.anglePositions[index - 1].dy -
              designerModel.anglePositions_Offsets[index - 1].dy -
              12.5,
          child: Transform.scale(
            alignment: Alignment.center,
            scale: (1 / designerModel.interactiveZoomFactor) *
                designerModel.angleScales[index - 1],
            child: SizedBox(
              width: 40,
              height: 25,
              child: GestureDetector(
                onPanStart: (dragStartDetails) {
                  designerModel.editDragAngleIndex(index);
                  designerModel.editAnglePosition(
                      index - 1,
                      designerModel.anglePositions[index - 1] +
                          Offset(0,
                              -25 * (1 / designerModel.interactiveZoomFactor)));
                  designerModel.editAngleScale(index - 1, 1.25);
                },
                onPanEnd: (dragEndDetails) {
                  designerModel.editAngleScale(index - 1, 1);
                },
                onPanUpdate: (dragUpdateDetails) {
                  designerModel.editAnglePosition(
                      designerModel.dragAngleIndex - 1,
                      designerModel.anglePositions[
                              designerModel.dragAngleIndex - 1] +
                          Offset(
                              dragUpdateDetails.delta.dx /
                                  designerModel.interactiveZoomFactor,
                              dragUpdateDetails.delta.dy /
                                  designerModel.interactiveZoomFactor));

                  designerModel.editAnglePositionOffset(
                      designerModel.dragAngleIndex - 1,
                      angleOffset(
                          designerModel.points,
                          designerModel.anglePositions,
                          designerModel.interactiveZoomFactor,
                          designerModel.dragAngleIndex,
                          designerModel.dragAngleIndex - 1));
                },
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.deepPurple[500],
                    foregroundColor: Colors.deepPurple[200],
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.all(6),
                  ),
                  onPressed: () {
                    designerModel.editShowAngleEdit(true);
                    designerModel.editSelectedPointIndex(index);
                  },
                  child: Text(
                    "${calculateAngle(designerModel.points[index - 1], designerModel.points[index], designerModel.points[index + 1]).round()}°",
                    style: const TextStyle(
                        fontFamily: "OpenSans",
                        color: Colors.white,
                        fontSize: 10),
                  ),
                ),
              ),
            ),
          ));
    });
  }
}
