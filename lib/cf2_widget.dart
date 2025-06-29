import 'package:ars_flashings/models/designer_model.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'helper_functions.dart';

class CF2Widget extends StatelessWidget {
  const CF2Widget({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DesignerModel>(builder: (context, designerModel, child) {
      return Positioned(
          left: designerModel.cf_2Position.dx -
              cf2Offset(
                      designerModel.points,
                      designerModel.cf_2Position,
                      designerModel.interactiveZoomFactor,
                      designerModel.cf_2State,
                      designerModel.cf_2Length)
                  .dx -
              20,
          top: designerModel.cf_2Position.dy -
              cf2Offset(
                      designerModel.points,
                      designerModel.cf_2Position,
                      designerModel.interactiveZoomFactor,
                      designerModel.cf_2State,
                      designerModel.cf_2Length)
                  .dy -
              15,
          child: Transform.scale(
            scale: (1 / designerModel.interactiveZoomFactor) *
                designerModel.cf_2Scale,
            child: SizedBox(
              width: 40,
              height: 30,
              child: GestureDetector(
                onPanStart: (dragStartDetails) {
                  designerModel.editCf_2Position(designerModel.cf_2Position +
                      Offset(
                          0, -25 * (1 / designerModel.interactiveZoomFactor)));
                  designerModel.editCf_2Scale(1.25);
                },
                onPanUpdate: (dragUpdateDetails) {
                  designerModel.editCf_2Position(designerModel.cf_2Position +
                      Offset(
                          dragUpdateDetails.delta.dx /
                              designerModel.interactiveZoomFactor,
                          dragUpdateDetails.delta.dy /
                              designerModel.interactiveZoomFactor));
                },
                onPanEnd: (dragEndDetails) {
                  designerModel.editCf_2Scale(1);
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
                    designerModel.editSelectedCF(2);
                  },
                  child: AutoSizeText(
                    "CF ${designerModel.cf_2Length.round()}",
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
