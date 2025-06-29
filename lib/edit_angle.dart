import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'helper_functions.dart';
import 'models/designer_model.dart';

class EditAngle extends StatelessWidget {
  const EditAngle({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DesignerModel>(
      builder: (context, designerModel, child) {
        return FocusScope(
          child: Focus(
            onFocusChange: (value) {
              designerModel.editShowAngleEdit(value);
            },
            child: TextFormField(
              autofocus: true,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                      borderSide: BorderSide(
                          color: Colors.deepPurple.shade400, width: 2)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                      borderSide: BorderSide(
                          color: Colors.deepPurple.shade400, width: 2)),
                  labelText: 'Enter Angle',
                  labelStyle: const TextStyle(
                      color: Colors.grey, fontFamily: "OpenSans"),
                  filled: true,
                  fillColor: Colors.white),
              keyboardType: TextInputType.number,
              onChanged: (text) {
                if (double.tryParse(text) != null &&
                    double.tryParse(text) != 0) {
                  designerModel.disableTaper();
                  var sign = 0;
                  var initialPoint =
                      designerModel.points[designerModel.SelectedPointindex];
                  var initialAngle = calculateSignedAngle(
                      designerModel
                          .points[designerModel.SelectedPointindex - 1],
                      designerModel.points[designerModel.SelectedPointindex],
                      designerModel
                          .points[designerModel.SelectedPointindex + 1]);

                  if (double.parse(text) < 180 && double.parse(text) > -180) {
                    sign = calculateAngleSign(
                        designerModel
                            .points[designerModel.SelectedPointindex - 1],
                        designerModel.points[designerModel.SelectedPointindex],
                        designerModel
                            .points[designerModel.SelectedPointindex + 1]);
                  }
                  if (designerModel.cf_2State != 0) {
                    sign < 0
                        ? designerModel.editCf_2Position(rotatePoint(
                            designerModel.cf_2Position,
                            initialPoint,
                            double.parse(text).roundToDouble() - initialAngle))
                        : designerModel.editCf_2Position(rotatePoint(
                            designerModel.cf_2Position,
                            initialPoint,
                            (double.parse(text).roundToDouble() - 360).abs() -
                                initialAngle));
                  }

                  for (var i = designerModel.SelectedPointindex + 1;
                      i < designerModel.points.length;
                      i++) {
                    if (sign < 0) {
                      designerModel.editPoint(
                          i,
                          rotatePoint(
                              designerModel.points[i],
                              initialPoint,
                              double.parse(text).roundToDouble() -
                                  initialAngle));
                      designerModel.editLengthPosition(
                          i - 1,
                          rotatePoint(
                              designerModel.lengthPositions[i - 1],
                              initialPoint,
                              double.parse(text).roundToDouble() -
                                  initialAngle));
                      designerModel.editAnglePosition(
                          i - 2,
                          rotatePoint(
                              designerModel.anglePositions[i - 2],
                              initialPoint,
                              double.parse(text).roundToDouble() -
                                  initialAngle));
                    } else {
                      designerModel.editPoint(
                          i,
                          rotatePoint(
                              designerModel.points[i],
                              initialPoint,
                              (double.parse(text).roundToDouble() - 360).abs() -
                                  initialAngle));

                      designerModel.editLengthPosition(
                          i - 1,
                          rotatePoint(
                              designerModel.lengthPositions[i - 1],
                              initialPoint,
                              (double.parse(text).roundToDouble() - 360).abs() -
                                  initialAngle));

                      designerModel.editAnglePosition(
                          i - 2,
                          rotatePoint(
                              designerModel.anglePositions[i - 2],
                              initialPoint,
                              (double.parse(text).roundToDouble() - 360).abs() -
                                  initialAngle));
                    }
                  }

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
                  designerModel.updateColourPosition();
                }
              },
              onTapOutside: (pointerDownEvent) {
                designerModel.editShowAngleEdit(false);
              },
            ),
          ),
        );
      },
    );
  }
}
