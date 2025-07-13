import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'helper_functions.dart';
import 'models/designer_model.dart';

class ColourDirection extends StatelessWidget {
  const ColourDirection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DesignerModel>(builder: (context, designerModel, child) {
      return Positioned(
          left: designerModel.colourPosition.dx -
              (25 *
                  ((1 / -designerModel.interactiveZoomFactor) *
                      calculateNormalizedDirectionVector(
                              designerModel.colourMidpoint,
                              designerModel.colourPosition)
                          .dx)) -
              25,
          top: designerModel.colourPosition.dy -
              (25 *
                  ((1 / -designerModel.interactiveZoomFactor) *
                      calculateNormalizedDirectionVector(
                              designerModel.colourMidpoint,
                              designerModel.colourPosition)
                          .dy)) -
              25,
          child: Transform.scale(
            scale: 1 / designerModel.interactiveZoomFactor,
            child: Transform.rotate(
              angle: designerModel.colourRotation,
              child: SizedBox(
                width: 50,
                height: 50,
                child: Center(
                  child: Icon(
                    Icons.arrow_upward_rounded,
                    color: Colors.deepPurple.shade500,
                    size: 50,
                  ),
                ),
              ),
            ),
          ));
    });
  }
}
