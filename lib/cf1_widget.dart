import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'helper_functions.dart';
import 'models/designer_model.dart';

class CF1Widget extends StatelessWidget {
  const CF1Widget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DesignerModel>(builder: (context, designerModel, child) {
      return Positioned(
          left: designerModel.cf_1Position.dx -
              cf1Offset(
                      designerModel.points,
                      designerModel.cf_1Position,
                      designerModel.interactiveZoomFactor,
                      designerModel.cf_1State,
                      designerModel.cf_1Length)
                  .dx -
              20,
          top: designerModel.cf_1Position.dy -
              cf1Offset(
                      designerModel.points,
                      designerModel.cf_1Position,
                      designerModel.interactiveZoomFactor,
                      designerModel.cf_1State,
                      designerModel.cf_1Length)
                  .dy -
              15,
          child: Transform.scale(
            scale: (1 / designerModel.interactiveZoomFactor) *
                designerModel.cf_1Scale,
            child: SizedBox(
              width: 40,
              height: 30,
              child: GestureDetector(
                onPanStart: (dragStartDetails) {
                  designerModel.editCf_1Position(designerModel.cf_1Position +
                      Offset(
                          0, -25 * (1 / designerModel.interactiveZoomFactor)));
                  designerModel.editCf_1Scale(1.25);
                },
                onPanUpdate: (dragUpdateDetails) {
                  designerModel.editCf_1Position(designerModel.cf_1Position +
                      Offset(
                          dragUpdateDetails.delta.dx /
                              designerModel.interactiveZoomFactor,
                          dragUpdateDetails.delta.dy /
                              designerModel.interactiveZoomFactor));
                },
                onPanEnd: (dragEndDetails) {
                  designerModel.editCf_1Scale(1);
                },
                child: TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.deepPurple[500],
                    foregroundColor: Colors.deepPurple[200],
                    minimumSize: Size.zero,
                    padding: const EdgeInsets.all(6),
                  ),
                  onPressed: () {
                    designerModel.editShowCFEdit(true);
                    designerModel.editSelectedCF(1);
                  },
                  child: AutoSizeText(
                    "CF ${designerModel.cf_1Length.round()}",
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
