import 'dart:math';

import 'package:flutter/material.dart';

import '../helper_functions.dart';

class DesignerModel extends ChangeNotifier {
  final TransformationController _transformationController;
  DesignerModel()
      : _transformationController = TransformationController(
            Matrix4.translationValues(-10000, -10000, 0.0)) {
    // The transformation controller is initialized with the given translation values
  }
  // private declaration
  List<Offset> _points = <Offset>[];
  List<Offset> _lengthPositions = <Offset>[];
  List<int> _lengthWidgetText = <int>[];
  List<int> _nearLengthWidgetText = <int>[];
  List<int> _farLengthWidgetText = <int>[];
  List<Offset> _lengthPositions_Offsets = <Offset>[];
  List<Offset> _anglePositions = <Offset>[];
  List<Offset> _anglePositions_Offsets = <Offset>[];

  List<Offset> _nearPoints = <Offset>[];
  List<Offset> _nearLengthPositions = <Offset>[];
  List<Offset> _nearLengthPositions_Offsets = <Offset>[];
  List<Offset> _nearAnglePositions = <Offset>[];
  List<Offset> _nearAnglePositions_Offsets = <Offset>[];

  List<Offset> _farPoints = <Offset>[];
  List<Offset> _farLengthPositions = <Offset>[];
  List<Offset> _farLengthPositions_Offsets = <Offset>[];
  List<Offset> _farAnglePositions = <Offset>[];
  List<Offset> _farAnglePositions_Offsets = <Offset>[];

  final List<double> _angleScales = <double>[];
  final List<double> _lengthScales = <double>[];

  int _cf_1State = 0;
  int _cf_2State = 0;
  double _cf_1Scale = 1;
  double _cf_2Scale = 1;
  double _cf_1Length = 0;
  double _cf_2Length = 0;
  Offset _cf_1Position = const Offset(0, 0);
  Offset _cf_2Position = const Offset(0, 0);
  Offset _cf_2PositionNear = const Offset(0, 0);
  Offset _cf_2PositionFar = const Offset(0, 0);
  Offset _colourPosition = const Offset(0, 0);
  Offset _colourMidpoint = const Offset(0, 0);
  double _colourRotation = 0;

  int _girth = 0;

  bool _tapered = false;

  bool _showCrushAndFoldUI = false;
  bool _showLengthEdit = false;
  bool _showAngleEdit = false;
  bool _showCFEdit = false;
  bool _ShowMenu = false;
  bool _Hide90_45Angles = false;

  final List<Color> _bottomBarColors = <Color>[
    Colors.white,
    Colors.grey,
    Colors.grey
  ];

  double? _oldInteractiveZoomFactor;
  double _interactiveZoomFactor = 1;

  int _taperedState = 0;
  int _SelectedPointindex = 1;
  int _dragLengthIndex = 0;
  int _dragAngleIndex = 0;
  int _bottomBarIndex = 0;
  int _selectedCF = 0;
  int _SelectedRotationPoint = 0;
  int _colourSide = 1;
  String _material = '';
  String _Lengths = '';
  String _Job = '';
  String _Id = '';

  //getters
  List<Offset> get points => _points;
  List<Offset> get lengthPositions => _lengthPositions;
  List<int> get lengthWidgetText => _lengthWidgetText;
  List<int> get nearLengthWidgetText => _nearLengthWidgetText;
  List<int> get farLengthWidgetText => _farLengthWidgetText;
  List<Offset> get anglePositions => _anglePositions;
  List<Offset> get lengthPositions_Offsets => _lengthPositions_Offsets;
  List<Offset> get anglePositions_Offsets => _anglePositions_Offsets;

  List<Offset> get nearPoints => _nearPoints;
  List<Offset> get nearLengthPositions => _nearLengthPositions;
  List<Offset> get nearAnglePositions => _nearAnglePositions;
  List<Offset> get nearLengthPositions_Offsets => _nearLengthPositions_Offsets;
  List<Offset> get nearAnglePositions_Offsets => _nearAnglePositions_Offsets;

  List<Offset> get farPoints => _farPoints;
  List<Offset> get farLengthPositions => _farLengthPositions;
  List<Offset> get farAnglePositions => _farAnglePositions;
  List<Offset> get farLengthPositions_Offsets => _farLengthPositions_Offsets;
  List<Offset> get farAnglePositions_Offsets => _farAnglePositions_Offsets;

  List<double> get angleScales => _angleScales;
  List<double> get lengthScales => _lengthScales;
  TransformationController get transformationController =>
      _transformationController;

  bool get tapered => _tapered;
  int get taperedState => _taperedState;

  int get cf_1State => _cf_1State;
  int get cf_2State => _cf_2State;
  int get colourSide => _colourSide;
  double get cf_1Scale => _cf_1Scale;
  double get cf_2Scale => _cf_2Scale;
  double get cf_1Length => _cf_1Length;
  double get cf_2Length => _cf_2Length;
  Offset get cf_1Position => _cf_1Position;
  Offset get cf_2Position => _cf_2Position;
  Offset get cf_2PositionNear => _cf_2PositionNear;
  Offset get cf_2PositionFar => _cf_2PositionFar;
  Offset get colourPosition => _colourPosition;
  Offset get colourMidpoint => _colourMidpoint;

  double _flashingRotationAngle = 0;
  double _oldFlashingRotationAngle = 0;

  int get girth => _girth;

  bool get showCrushAndFoldUI => _showCrushAndFoldUI;
  bool get showLengthEdit => _showLengthEdit;
  bool get showAngleEdit => _showAngleEdit;
  bool get showCFEdit => _showCFEdit;
  bool get ShowMenu => _ShowMenu;
  bool get Hide90_45Angles => _Hide90_45Angles;

  List<Color> get bottomBarColors => _bottomBarColors;

  double? get oldInteractiveZoomFactor => _oldInteractiveZoomFactor;
  double get interactiveZoomFactor => _interactiveZoomFactor;
  double get flashingRotationAngle => _flashingRotationAngle;
  double get colourRotation => _colourRotation;

  int get SelectedPointindex => _SelectedPointindex;
  int get dragLengthIndex => _dragLengthIndex;
  int get dragAngleIndex => _dragAngleIndex;
  int get bottomBarIndex => _bottomBarIndex;
  int get selectedCF => _selectedCF;
  int get SelectedRotationPoint => _SelectedRotationPoint;

  String get material => _material;
  set material(String v) {
    if (v != _material) {
      _material = v;
      notifyListeners();
    }
  }

  String get lengths => _Lengths;
  set lengths(String v) {
    if (v != _Lengths) {
      _Lengths = v;
      notifyListeners();
    }
  }

  String get job => _Job;
  set job(String v) {
    if (v != _Job) {
      _Job = v;
      notifyListeners();
    }
  }

  String get id => _Id;
  set id(String v) {
    if (v != _Id) {
      _Id = v;
      notifyListeners();
    }
  }
  //Setters

  void enableTaper() {
    _tapered = true;
    saveNearTaper();
    saveFarTaper();
    swapTaper(0);

    notifyListeners();
  }

  void swapTaper(int state) {
    if (state == 0) {
      _taperedState = 0;
      saveFarTaper();
      loadNearTaper();
    } else if (state == 1) {
      _taperedState = 1;
      saveNearTaper();
      loadFarTaper();
    }
    updateColourPosition();
    UpdateGirth();
    notifyListeners();
  }

  void disableTaper() {
    _tapered = false;

    notifyListeners();
  }

  void saveNearTaper() {
    _nearLengthWidgetText = [..._lengthWidgetText];
    _nearPoints = [..._points];
    _nearLengthPositions = [..._lengthPositions];
    _nearLengthPositions_Offsets = [..._lengthPositions_Offsets];
    _nearAnglePositions = [..._anglePositions];
    _nearAnglePositions_Offsets = [..._anglePositions_Offsets];
    _cf_2PositionNear = Offset(_cf_2Position.dx, _cf_2Position.dy);
  }

  void loadNearTaper() {
    _lengthWidgetText = [..._nearLengthWidgetText];
    _points = [..._nearPoints];
    _lengthPositions = [..._nearLengthPositions];
    _lengthPositions_Offsets = [..._nearLengthPositions_Offsets];
    _anglePositions = [..._nearAnglePositions];
    _anglePositions_Offsets = [..._nearAnglePositions_Offsets];
    _cf_2Position = Offset(_cf_2PositionNear.dx, _cf_2PositionNear.dy);
  }

  void saveFarTaper() {
    _farLengthWidgetText = [..._lengthWidgetText];
    _farPoints = [..._points];
    _farLengthPositions = [..._lengthPositions];
    _farLengthPositions_Offsets = [..._lengthPositions_Offsets];
    _farAnglePositions = [..._anglePositions];
    _farAnglePositions_Offsets = [..._anglePositions_Offsets];
    _cf_2PositionFar = Offset(_cf_2Position.dx, _cf_2Position.dy);
  }

  void loadFarTaper() {
    _lengthWidgetText = [..._farLengthWidgetText];
    _points = [..._farPoints];
    _lengthPositions = [..._farLengthPositions];
    _lengthPositions_Offsets = [..._farLengthPositions_Offsets];
    _anglePositions = [..._farAnglePositions];
    _anglePositions_Offsets = [..._farAnglePositions_Offsets];
    _cf_2Position = Offset(_cf_2PositionFar.dx, _cf_2PositionFar.dy);
  }

  //colourside
  void swapColourSide() {
    _colourSide == 1 ? _colourSide = 2 : _colourSide = 1;
    updateColourPosition();
  }

  //colourpos
  void updateColourPosition() {
    if (_points.length >= 2) {
      double distance = 0;
      int longestPointIndex = 0;
      for (int i = 0; i < _points.length - 1; i++) {
        if ((_points[i] - _points[i + 1]).distance > distance) {
          distance = (_points[i] - _points[i + 1]).distance;
          longestPointIndex = i;
        }
      }
      var normalVector = _colourSide == 1
          ? calculatePerpendicularVector(
              _points[longestPointIndex], _points[longestPointIndex + 1])
          : -calculatePerpendicularVector(
              _points[longestPointIndex], _points[longestPointIndex + 1]);
      var angle = atan2(normalVector.dy, normalVector.dx);
      var midpoint = Offset(
          (2 * _points[longestPointIndex].dx +
                  _points[longestPointIndex + 1].dx) /
              3,
          (2 * _points[longestPointIndex].dy +
                  _points[longestPointIndex + 1].dy) /
              3);

      _colourRotation = angle - (pi / 2);
      _colourPosition = midpoint + (normalVector * 3);
      _colourMidpoint = midpoint;
      notifyListeners();
    }
  }

  //point
  void addPoint(Offset offset) {
    _points.add(offset);
    UpdateGirth();
    notifyListeners();
  }

  void editPoint(int index, Offset newValue) {
    if (_points.length > index) _points[index] = newValue;
    UpdateGirth();
    notifyListeners();
  }

  void removePoint() {
    if (_points.isNotEmpty) {
      _points.removeLast();
      UpdateGirth();
    }
  }

  void removeNearPoint() {
    if (_nearPoints.isNotEmpty) {
      _nearPoints.removeLast();
      UpdateGirth();
    }
  }

  void removeFarPoint() {
    if (_farPoints.isNotEmpty) {
      _farPoints.removeLast();
      UpdateGirth();
    }
  }

// length position
  void addLengthPosition(Offset offset) {
    _lengthPositions.add(offset);

    _lengthWidgetText.add(
        ((points[points.length - 1] - _points[_points.length - 2]).distance /
                2.6666666666666666666666666666667)
            .round());
    UpdateGirth();
  }

  void editLengthPosition(int index, Offset newValue) {
    if (_lengthPositions.length > index) _lengthPositions[index] = newValue;
    notifyListeners();
  }

  void removeLengthPosition() {
    if (_lengthPositions.isNotEmpty) {
      _lengthPositions.removeLast();
      _lengthWidgetText.removeLast();
      UpdateGirth();
    }
  }

  void removeNearLengthPosition() {
    if (_nearLengthPositions.isNotEmpty) {
      _nearLengthPositions.removeLast();
    }
  }

  void removeFarLengthPosition() {
    if (_farLengthPositions.isNotEmpty) {
      _farLengthPositions.removeLast();
    }
  }

  //length Scales
  void addLengthScale(double val) {
    _lengthScales.add(val);
    notifyListeners(); // May not need
  }

  void editLengthScale(int index, double newValue) {
    if (_lengthScales.length > index) _lengthScales[index] = newValue;
    notifyListeners(); // May not need
  }

  void removeLengthScale() {
    if (_lengthScales.isNotEmpty) {
      _lengthScales.removeLast();
    }
  }

  //length position Offset
  void addLengthPositionOffset(Offset offset) {
    _lengthPositions_Offsets.add(offset);
    notifyListeners();
  }

  void editLengthPositionOffset(int index, Offset newValue) {
    if (_lengthPositions_Offsets.length > index) {
      _lengthPositions_Offsets[index] = newValue;
    }
    notifyListeners();
  }

  void editNearLengthPositionOffset(int index, Offset newValue) {
    if (_nearLengthPositions_Offsets.length > index) {
      _nearLengthPositions_Offsets[index] = newValue;
    }
    notifyListeners();
  }

  void editFarLengthPositionOffset(int index, Offset newValue) {
    if (_farLengthPositions_Offsets.length > index) {
      _farLengthPositions_Offsets[index] = newValue;
    }
    notifyListeners();
  }

  void removeLengthPositionOffset() {
    if (_lengthPositions_Offsets.isNotEmpty) {
      _lengthPositions_Offsets.removeLast();
    }
  }

  void removeNearLengthPositionOffset() {
    if (_nearLengthPositions_Offsets.isNotEmpty) {
      _nearLengthPositions_Offsets.removeLast();
    }
  }

  void removeFarLengthPositionOffset() {
    if (_farLengthPositions_Offsets.isNotEmpty) {
      _farLengthPositions_Offsets.removeLast();
    }
  }

  //angle position
  void addAnglePosition(Offset offset) {
    _anglePositions.add(offset);
    notifyListeners();
  }

  void editAnglePosition(int index, Offset newValue) {
    if (_anglePositions.length > index) _anglePositions[index] = newValue;
    notifyListeners();
  }

  void removeAnglePosition() {
    if (_anglePositions.isNotEmpty) {
      _anglePositions.removeLast();
    }
  }

  void removeNearAnglePosition() {
    if (_nearAnglePositions.isNotEmpty) {
      _nearAnglePositions.removeLast();
    }
  }

  void removeFarAnglePosition() {
    if (_farAnglePositions.isNotEmpty) {
      _farAnglePositions.removeLast();
    }
  }

  //angle Scales
  void addAngleScale(double val) {
    _angleScales.add(val);
    notifyListeners(); // May not need
  }

  void editAngleScale(int index, double newValue) {
    if (_angleScales.length > index) _angleScales[index] = newValue;
    notifyListeners(); // May not need
  }

  void removeAngleScale() {
    if (_angleScales.isNotEmpty) {
      _angleScales.removeLast();
    }
  }

  //angle position offsets
  void addAnglePositionOffset(Offset offset) {
    _anglePositions_Offsets.add(offset);
    notifyListeners();
  }

  void editAnglePositionOffset(int index, Offset newValue) {
    if (_anglePositions_Offsets.length > index) {
      _anglePositions_Offsets[index] = newValue;
    }
    notifyListeners();
  }

  void editNearAnglePositionOffset(int index, Offset newValue) {
    if (_nearAnglePositions_Offsets.length > index) {
      _nearAnglePositions_Offsets[index] = newValue;
    }
    notifyListeners();
  }

  void editFarAnglePositionOffset(int index, Offset newValue) {
    if (_farAnglePositions_Offsets.length > index) {
      _farAnglePositions_Offsets[index] = newValue;
    }
    notifyListeners();
  }

  void removeAnglePositionOffset() {
    if (_anglePositions_Offsets.isNotEmpty) {
      _anglePositions_Offsets.removeLast();
    }
  }

  void removeNearAnglePositionOffset() {
    if (_nearAnglePositions_Offsets.isNotEmpty) {
      _nearAnglePositions_Offsets.removeLast();
    }
  }

  void removeFarAnglePositionOffset() {
    if (_farAnglePositions_Offsets.isNotEmpty) {
      _farAnglePositions_Offsets.removeLast();
    }
  }

  //cf1state
  void editCf_1State(int val) {
    _cf_1State = val;

    notifyListeners();
  }

  //cf2state
  void editCf_2State(int val) {
    _cf_2State = val;
    notifyListeners();
  }

  //cf1scale
  void editCf_1Scale(double val) {
    _cf_1Scale = val;
    notifyListeners();
  }

  //cf2scale
  void editCf_2Scale(double val) {
    _cf_2Scale = val;
    notifyListeners();
  }

  //cf1length
  void editCf_1length(double val) {
    _cf_1Length = val;
    UpdateGirth();
    notifyListeners();
  }

  //cf2length
  void editCf_2length(double val) {
    _cf_2Length = val;
    UpdateGirth();
    notifyListeners();
  }

  //Cf1 Position
  void editCf_1Position(Offset val) {
    _cf_1Position = val;
    notifyListeners();
  }

//Cf2 position
  void editCf_2Position(Offset val) {
    _cf_2Position = val;
    notifyListeners();
  }

  //SelectedCF
  void editSelectedCF(int val) {
    _selectedCF = val;
  }

  //showCFUI
  void editShowCrushAndFoldUI(bool val) {
    _showCrushAndFoldUI = val;
    notifyListeners();
  }

  //showCFEditUI
  void editShowCFEdit(bool val) {
    _showCFEdit = val;
    notifyListeners();
  }

  //ShowEditLengthUI
  void editShowLengthEdit(bool val) {
    _showLengthEdit = val;
    notifyListeners();
  }

  //ShowAngleEditUI
  void editShowAngleEdit(bool val) {
    _showAngleEdit = val;
    notifyListeners();
  }

  void editHide90_45Angles(bool val) {
    _Hide90_45Angles = val;
    notifyListeners();
  }

  //ShowMenu
  void editShowMenu(bool val) {
    _ShowMenu = val;
    notifyListeners();
  }

//BottomBarColors
  void editBottomBarColors(int index, Color val) {
    _bottomBarColors[index] = val;
    notifyListeners();
  }

  //bottombar index

  void editBottomBarIndex(int val) {
    _bottomBarIndex = val;
    disableTaper();
    notifyListeners();
  }

  //old interactive zoom factor
  void editOldInteractiveZoomFactor(double? val) {
    _oldInteractiveZoomFactor = val;
  }

  //interactive zoom factor
  void editInteractiveZoomFactor(double val) {
    _interactiveZoomFactor = val;
    if (_interactiveZoomFactor != _oldInteractiveZoomFactor) {
      notifyListeners();
    }
  }

//Girth
  void UpdateGirth() {
    int girthUpdated = 0;
    for (int i = 0; i < lengthWidgetText.length; i++) {
      girthUpdated += lengthWidgetText[i];
    }

    _girth = girthUpdated + _cf_1Length.toInt() + _cf_2Length.toInt();
  }

  //selected point index
  void editSelectedPointIndex(int val) {
    _SelectedPointindex = val;
  }

  //selected Rotation point index
  void editSelectedRotationPointIndex(int val) {
    _SelectedRotationPoint = val;

    notifyListeners();
  }

  //Rotate Flashing
  void editFlashingRotationAngle(double val) {
    _flashingRotationAngle = val;
    RotateFlashing();
  }

  void RotateFlashing() {
    double DeltaAngle = _flashingRotationAngle - _oldFlashingRotationAngle;

    for (int i = 0; i < _points.length; i++) {
      _points[i] =
          rotatePoint(_points[i], _points[SelectedRotationPoint], DeltaAngle);
    }

    for (int i = 0; i < _lengthPositions.length; i++) {
      _lengthPositions[i] = rotatePoint(
          _lengthPositions[i], _points[SelectedRotationPoint], DeltaAngle);
      _lengthPositions_Offsets[i] = lengthOffset(
          _points,
          _lengthPositions,
          _interactiveZoomFactor,
          i + 1,
          i,
          verticalScaler(_points, _lengthPositions, i + 1, i));
    }
    for (int i = 0; i < _anglePositions.length; i++) {
      _anglePositions[i] = rotatePoint(
          _anglePositions[i], _points[SelectedRotationPoint], DeltaAngle);
      _anglePositions_Offsets[i] = angleOffset(
          _points, _anglePositions, _interactiveZoomFactor, i + 1, i);
    }
    _cf_1Position =
        rotatePoint(_cf_1Position, _points[SelectedRotationPoint], DeltaAngle);
    _cf_2Position =
        rotatePoint(_cf_2Position, _points[SelectedRotationPoint], DeltaAngle);
    _oldFlashingRotationAngle = _flashingRotationAngle;

    updateColourPosition();

    notifyListeners();
  }

  //drag Length Index
  void editDragLengthIndex(int val) {
    _dragLengthIndex = val;
  }

  //drag Angle Index
  void editDragAngleIndex(int val) {
    _dragAngleIndex = val;
  }

  //Undo
  void Undo() {
    if (_points.isNotEmpty) {
      if (_points.length == 2) {
        editCf_1State(0);
        editCf_1length(0);
      }
      editCf_2State(0);
      editCf_2length(0);

      removePoint();
      removeNearPoint();
      removeFarPoint();
      updateColourPosition();

      if (_lengthPositions.isNotEmpty) {
        removeLengthPosition();
      }
      if (_nearLengthPositions.isNotEmpty) {
        removeNearLengthPosition();
      }
      if (_farLengthPositions.isNotEmpty) {
        removeFarLengthPosition();
      }
      if (_anglePositions.isNotEmpty) {
        removeAnglePosition();
      }
      if (_nearAnglePositions.isNotEmpty) {
        removeNearAnglePosition();
      }
      if (_farAnglePositions.isNotEmpty) {
        removeFarAnglePosition();
      }
      if (_angleScales.isNotEmpty) {
        removeAngleScale();
      }
      if (_lengthScales.isNotEmpty) {
        removeLengthScale();
      }
      if (_lengthPositions_Offsets.isNotEmpty) {
        removeLengthPositionOffset();
      }
      if (_nearLengthPositions_Offsets.isNotEmpty) {
        removeNearLengthPositionOffset();
      }
      if (_farLengthPositions_Offsets.isNotEmpty) {
        removeFarLengthPositionOffset();
      }
      if (_anglePositions_Offsets.isNotEmpty) {
        removeAnglePositionOffset();
      }
      if (_nearAnglePositions_Offsets.isNotEmpty) {
        removeNearAnglePositionOffset();
      }
      if (_farAnglePositions_Offsets.isNotEmpty) {
        removeFarAnglePositionOffset();
      }
    }
    if (nearPoints.length <= 1 || farPoints.length <= 1) {
      disableTaper();
    }
  }
}
