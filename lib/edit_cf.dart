import 'package:ars_flashings/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'models/designer_model.dart';

class EditCFLength extends StatelessWidget {
  const EditCFLength({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DesignerModel>(
      builder: (context, designerModel, child) {
        return FocusScope(
          child: Focus(
            onFocusChange: (value) {
              designerModel.editShowCFEdit(value);
            },
            child: TextFormField(
              autofocus: true,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              maxLength: 2,
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
                  labelText: 'Enter CF Length',
                  labelStyle: const TextStyle(
                      color: Colors.grey, fontFamily: "OpenSans"),
                  filled: true,
                  fillColor: Colors.white),
              keyboardType: TextInputType.number,
              onChanged: (text) {
                if (double.tryParse(text) != null &&
                    double.tryParse(text) != 0 &&
                    double.tryParse(text)! >= 10) {
                  if (designerModel.selectedCF == 1) {
                    Offset dir = calculateNormalizedDirectionVector(
                        designerModel.points[0], designerModel.points[1]);
                    double initialDistance = (cf1EndPoint(
                                designerModel.points,
                                designerModel.cf_1State,
                                designerModel.cf_1Length,
                                designerModel.interactiveZoomFactor) -
                            cf1StartPoint(
                                designerModel.points,
                                designerModel.cf_1State,
                                designerModel.cf_1Length,
                                designerModel.interactiveZoomFactor))
                        .distance;

                    designerModel.editCf_1Position(designerModel.cf_1Position +
                        (dir *
                            ((double.parse(text) *
                                    2.6666666666666666666666666666667 -
                                initialDistance)) /
                            2));
                    designerModel.editCf_1length(double.parse(text));
                  } else if (designerModel.selectedCF == 2) {
                    Offset dir = calculateNormalizedDirectionVector(
                        designerModel.points[designerModel.points.length - 1],
                        designerModel.points[designerModel.points.length - 2]);
                    double initialDistance = (cf2EndPoint(
                                designerModel.points,
                                designerModel.cf_2State,
                                designerModel.cf_2Length,
                                designerModel.interactiveZoomFactor) -
                            cf2StartPoint(
                                designerModel.points,
                                designerModel.cf_2State,
                                designerModel.cf_2Length,
                                designerModel.interactiveZoomFactor))
                        .distance;

                    designerModel.editCf_2Position(designerModel.cf_2Position +
                        (dir *
                            ((double.parse(text) *
                                    2.6666666666666666666666666666667 -
                                initialDistance)) /
                            2));
                    designerModel.editCf_2length(double.parse(text));
                  }
                }
              },
              onTapOutside: (pointerDownEvent) {
                designerModel.editShowCFEdit(false);
              },
            ),
          ),
        );
      },
    );
  }
}
