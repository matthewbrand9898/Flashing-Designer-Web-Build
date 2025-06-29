import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'helper_functions.dart';
import 'models/designer_model.dart';

class EditLength extends StatelessWidget {
  const EditLength({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DesignerModel>(
      builder: (context, designerModel, child) {
        return FocusScope(
          child: Focus(
            onFocusChange: (value) {
              designerModel.editShowLengthEdit(value);
            },
            child: TextFormField(
              autofocus: true,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              maxLength: 4,
              decoration: InputDecoration(
                  counterText: '',
                  enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                      borderSide: BorderSide(
                          color: Colors.deepPurple.shade400, width: 2)),
                  focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                      borderSide: BorderSide(
                          color: Colors.deepPurple.shade400, width: 2)),
                  labelText: 'Enter Length',
                  labelStyle: const TextStyle(
                      color: Colors.grey, fontFamily: "OpenSans"),
                  filled: true,
                  fillColor: Colors.white),
              keyboardType: TextInputType.number,
              onChanged: (text) {
                var initialDirection = Offset(
                    calculateNormalizedDirectionVector(
                            designerModel
                                .points[designerModel.SelectedPointindex - 1],
                            designerModel
                                .points[designerModel.SelectedPointindex])
                        .dx,
                    calculateNormalizedDirectionVector(
                            designerModel
                                .points[designerModel.SelectedPointindex - 1],
                            designerModel
                                .points[designerModel.SelectedPointindex])
                        .dy);
                var initialDistance = (designerModel
                            .points[designerModel.SelectedPointindex - 1] -
                        designerModel.points[designerModel.SelectedPointindex])
                    .distance;

                for (var i = designerModel.SelectedPointindex;
                    i < designerModel.points.length;
                    i++) {
                  if (double.tryParse(text) != null &&
                      double.tryParse(text) != 0) {
                    designerModel.lengthWidgetText[
                            designerModel.SelectedPointindex - 1] =
                        int.tryParse(text)!;
                    designerModel.editPoint(
                        i,
                        designerModel.points[i] +
                            (initialDirection *
                                (double.parse(text).clamp(-300, 300) *
                                        2.6666666666666666666666666666667 -
                                    initialDistance)));

                    if (i == designerModel.SelectedPointindex) {
                      designerModel.editLengthPosition(
                          i - 1,
                          designerModel.lengthPositions[i - 1] +
                              (initialDirection *
                                  ((double.parse(text).clamp(-300, 300) *
                                          2.6666666666666666666666666666667 -
                                      initialDistance)) /
                                  2));
                      if (designerModel.cf_2State != 0) {
                        designerModel.editCf_2Position(
                            designerModel.cf_2Position +
                                (initialDirection *
                                    ((double.parse(text).clamp(-300, 300) *
                                            2.6666666666666666666666666666667 -
                                        initialDistance))));
                      }
                    } else {
                      designerModel.editLengthPosition(
                          i - 1,
                          designerModel.lengthPositions[i - 1] +
                              (initialDirection *
                                  ((double.parse(text).clamp(-300, 300) *
                                          2.6666666666666666666666666666667 -
                                      initialDistance))));
                    }

                    if (i < (designerModel.points.length - 1)) {
                      designerModel.editAnglePosition(
                          i - 1,
                          designerModel.anglePositions[i - 1] +
                              (initialDirection *
                                  ((double.parse(text).clamp(-300, 300) *
                                          2.6666666666666666666666666666667 -
                                      initialDistance))));
                    }
                  }
                }
                designerModel.updateColourPosition();
              },
              onTapOutside: (pointerDownEvent) {
                designerModel.editShowLengthEdit(false);
              },
            ),
          ),
        );
      },
    );
  }
}
