import 'package:ars_flashings/models/designer_model.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'helper_functions.dart';

class LengthWidget extends StatelessWidget {
  const LengthWidget({required this.index, super.key});
  final int index;
  final int textvalue = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<DesignerModel>(builder: (context, designerModel, child) {
      return Positioned(
          left: designerModel.lengthPositions[index - 1].dx -
              designerModel.lengthPositions_Offsets[index - 1].dx -
              17.5,
          top: designerModel.lengthPositions[index - 1].dy -
              designerModel.lengthPositions_Offsets[index - 1].dy -
              12.5,
          child: Transform.scale(
            scale: (1 / designerModel.interactiveZoomFactor) *
                designerModel.lengthScales[index - 1],
            child: SizedBox(
              width: 35,
              height: 25,
              child: GestureDetector(
                onPanStart: (dragStartDetails) {
                  designerModel.editDragLengthIndex(index);
                  designerModel.editLengthPosition(
                      index - 1,
                      designerModel.lengthPositions[index - 1] +
                          Offset(0,
                              -25 * (1 / designerModel.interactiveZoomFactor)));
                  designerModel.editLengthScale(index - 1, 1.25);
                },
                onPanUpdate: (dragUpdateDetails) {
                  designerModel.editLengthPosition(
                      designerModel.dragLengthIndex - 1,
                      designerModel.lengthPositions[
                              designerModel.dragLengthIndex - 1] +
                          Offset(
                              dragUpdateDetails.delta.dx /
                                  designerModel.interactiveZoomFactor,
                              dragUpdateDetails.delta.dy /
                                  designerModel.interactiveZoomFactor));

                  designerModel.editLengthPositionOffset(
                      designerModel.dragLengthIndex - 1,
                      lengthOffset(
                          designerModel.points,
                          designerModel.lengthPositions,
                          designerModel.interactiveZoomFactor,
                          designerModel.dragLengthIndex,
                          designerModel.dragLengthIndex - 1,
                          verticalScaler(
                              designerModel.points,
                              designerModel.lengthPositions,
                              designerModel.dragLengthIndex,
                              designerModel.dragLengthIndex - 1)));
                },
                onPanEnd: (dragEndDetails) {
                  designerModel.editLengthScale(index - 1, 1);
                },
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.deepPurple[500],
                    foregroundColor: Colors.deepPurple[200],
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.all(6),
                  ),
                  onPressed: () {
                    designerModel.editShowLengthEdit(true);
                    designerModel.editSelectedPointIndex(index);
                  },
                  child: ((designerModel.points[index - 1] -
                                          designerModel.points[index])
                                      .distance /
                                  2.6666666666666666666666666666667)
                              .round() <
                          300
                      ? AutoSizeText(
                          "${((designerModel.points[index - 1] - designerModel.points[index]).distance / 2.6666666666666666666666666666667).round()}",
                          style: const TextStyle(
                              fontFamily: "OpenSans",
                              color: Colors.white,
                              fontSize: 10),
                          minFontSize: 5,
                        )
                      : AutoSizeText(
                          '${designerModel.lengthWidgetText[index - 1]}',
                          style: const TextStyle(
                              fontFamily: "OpenSans",
                              color: Colors.white,
                              fontSize: 10),
                          minFontSize: 5,
                        ),
                ),
              ),
            ),
          ));
    });
  }
}
