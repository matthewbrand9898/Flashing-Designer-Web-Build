import 'dart:math';

import 'package:flutter/material.dart';

import '../helper_functions.dart';
import 'flashing.dart';

class DesignerModel extends ChangeNotifier {
  final TransformationController _transformationController;
  DesignerModel()
      : _transformationController = TransformationController(
            Matrix4.translationValues(-10000, -10000, 0.0)) {
    // The transformation controller is initialized with the given translation values
  }
  // private declaration
  final List<Flashing> _flashings = [];
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

  int? currentOrderIndex;
  String? currentOrderName;
  DateTime? currentOrderDate;
  String? currentCustomerName;
  String? currentCustomerAddress;
  String? currentCustomerPhone;
  String? currentCustomerEmail;

  Color _currentColour = Color(0xfffffff);

  int _editFlashingID = 0;
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
  bool _isEditingFlashing = false;
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
  String _flashingID = '';

  //getters
  List<Offset> get points => _points;
  List<Flashing> get flashings => _flashings;
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

  bool get isEditingFlashing => _isEditingFlashing;
  set isEditingFlashing(bool v) {
    _isEditingFlashing = v;
    notifyListeners();
  }

  int get editFlashingID => _editFlashingID;
  set editFlashingID(int v) {
    _editFlashingID = v;
    notifyListeners();
  }

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

  Color get currentColour => _currentColour;
  set currentColour(Color c) {
    _currentColour = c;
    notifyListeners();
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

  String get flashingID => _flashingID;
  set flashingID(String v) {
    if (v != _flashingID) {
      _flashingID = v;
      notifyListeners();
    }
  }

  //Setters
  /// Reset every field back to its default, empty or zero state.
  void clearAll() {
    // geometry
    _points.clear();
    _lengthPositions.clear();
    _lengthWidgetText.clear();
    _nearLengthWidgetText.clear();
    _farLengthWidgetText.clear();
    _lengthPositions_Offsets.clear();
    _anglePositions.clear();
    _anglePositions_Offsets.clear();

    // near side
    _nearPoints.clear();
    _nearLengthPositions.clear();
    _nearLengthPositions_Offsets.clear();
    _nearAnglePositions.clear();
    _nearAnglePositions_Offsets.clear();

    // far side
    _farPoints.clear();
    _farLengthPositions.clear();
    _farLengthPositions_Offsets.clear();
    _farAnglePositions.clear();
    _farAnglePositions_Offsets.clear();

    // scales
    _angleScales.clear();
    _lengthScales.clear();

    // crush & fold
    _cf_1State = 0;
    _cf_2State = 0;
    _cf_1Scale = 1;
    _cf_2Scale = 1;
    _cf_1Length = 0;
    _cf_2Length = 0;
    _cf_1Position = Offset.zero;
    _cf_2Position = Offset.zero;
    _cf_2PositionNear = Offset.zero;
    _cf_2PositionFar = Offset.zero;

    // colour
    _colourPosition = Offset.zero;
    _colourMidpoint = Offset.zero;
    _colourRotation = 0;

    // other flags
    _girth = 0;
    _tapered = false;
    _showCrushAndFoldUI = false;
    _showLengthEdit = false;
    _showAngleEdit = false;
    _showCFEdit = false;
    _ShowMenu = false;
    _Hide90_45Angles = false;
    _isEditingFlashing = false;

    // bottom bar
    _bottomBarIndex = 0;
    _bottomBarColors
      ..clear()
      ..addAll([Colors.white, Colors.grey, Colors.grey]);

    // interaction
    _oldInteractiveZoomFactor = null;
    _interactiveZoomFactor = 1;

    // selection
    _taperedState = 0;
    _SelectedPointindex = 1;
    _dragLengthIndex = 0;
    _dragAngleIndex = 0;
    _selectedCF = 0;
    _SelectedRotationPoint = 0;
    _colourSide = 1;

    // metadata
    _material = '';
    _Lengths = '';
    _Job = '';
    _flashingID = '';
    _transformationController.value =
        Matrix4.translationValues(-10000, -10000, 0.0);

    notifyListeners();
  }

  void _recalculateAllOffsets() {
    // 1) update the model's zoom factor
    final newScale = _transformationController.value.getMaxScaleOnAxis();
    editInteractiveZoomFactor(newScale);
    editOldInteractiveZoomFactor(newScale);

    // 2) length offsets
    for (var i = 0; i < _lengthPositions.length; i++) {
      editLengthPositionOffset(
        i,
        lengthOffset(
          _points,
          _lengthPositions,
          _interactiveZoomFactor,
          i + 1,
          i,
          _lengthScales[i],
        ),
      );
    }

    // 3) near‐length offsets
    for (var i = 0; i < _nearLengthPositions.length; i++) {
      editNearLengthPositionOffset(
        i,
        lengthOffset(
          _nearPoints,
          _nearLengthPositions,
          _interactiveZoomFactor,
          i + 1,
          i,
          _lengthScales[i],
        ),
      );
    }

    // 4) far‐length offsets
    for (var i = 0; i < _farLengthPositions.length; i++) {
      editFarLengthPositionOffset(
        i,
        lengthOffset(
          _farPoints,
          _farLengthPositions,
          _interactiveZoomFactor,
          i + 1,
          i,
          _lengthScales[i],
        ),
      );
    }

    // 5) angle offsets
    for (var i = 0; i < _anglePositions.length; i++) {
      editAnglePositionOffset(
        i,
        angleOffset(
          _points,
          _anglePositions,
          _interactiveZoomFactor,
          i + 1,
          i,
        ),
      );
    }

    // 6) near‐angle offsets
    for (var i = 0; i < _nearAnglePositions.length; i++) {
      editNearAnglePositionOffset(
        i,
        angleOffset(
          _nearPoints,
          _nearAnglePositions,
          _interactiveZoomFactor,
          i + 1,
          i,
        ),
      );
    }

    // 7) far‐angle offsets
    for (var i = 0; i < _farAnglePositions.length; i++) {
      editFarAnglePositionOffset(
        i,
        angleOffset(
          _farPoints,
          _farAnglePositions,
          _interactiveZoomFactor,
          i + 1,
          i,
        ),
      );
    }

    // 8) finally notify once so your UI rebuilds
    notifyListeners();
  }

  void resetTransformController(Size viewSize) {
    centerOnBoundingBox(
        controller: _transformationController,
        points: points,
        viewportSize: viewSize,
        marginFactor: 0.5);

    _recalculateAllOffsets();
    notifyListeners();
  }

  void setFlashings(
    List<Flashing> flashings, {
    int? orderIndex,
    String? orderName,
    DateTime? orderDate,
    String? customerName,
    String? customerAddress,
    String? customerPhone,
    String? customerEmail,
  }) {
    _flashings
      ..clear()
      ..addAll(flashings);
    currentOrderIndex = orderIndex;
    currentOrderName = orderName;
    currentOrderDate = orderDate;
    currentCustomerName = customerName;
    currentCustomerAddress = customerAddress;
    currentCustomerPhone = customerPhone;
    currentCustomerEmail = customerEmail;
    notifyListeners();
  }

  /// Copy *all* fields from this model back into [f]:
  Flashing saveFlashing() {
    Flashing f = Flashing();
    f.id = _flashings.length;
    f.points = List.from(_points);
    f.lengthPositions = List.from(_lengthPositions);
    f.lengthWidgetText = List.from(_lengthWidgetText);
    f.nearLengthWidgetText = List.from(_nearLengthWidgetText);
    f.farLengthWidgetText = List.from(_farLengthWidgetText);
    f.lengthPositionsOffsets = List.from(_lengthPositions_Offsets);
    f.anglePositions = List.from(_anglePositions);
    f.anglePositionsOffsets = List.from(_anglePositions_Offsets);

    f.nearPoints = List.from(_nearPoints);
    f.nearLengthPositions = List.from(_nearLengthPositions);
    f.nearLengthPositionsOffsets = List.from(_nearLengthPositions_Offsets);
    f.nearAnglePositions = List.from(_nearAnglePositions);
    f.nearAnglePositionsOffsets = List.from(_nearAnglePositions_Offsets);

    f.farPoints = List.from(_farPoints);
    f.farLengthPositions = List.from(_farLengthPositions);
    f.farLengthPositionsOffsets = List.from(_farLengthPositions_Offsets);
    f.farAnglePositions = List.from(_farAnglePositions);
    f.farAnglePositionsOffsets = List.from(_farAnglePositions_Offsets);

    f.angleScales = List.from(_angleScales);
    f.lengthScales = List.from(_lengthScales);

    f.cf1State = _cf_1State;
    f.cf2State = _cf_2State;
    f.cf1Scale = _cf_1Scale;
    f.cf2Scale = _cf_2Scale;
    f.cf1Length = _cf_1Length;
    f.cf2Length = _cf_2Length;
    f.cf1Position = _cf_1Position;
    f.cf2Position = _cf_2Position;
    f.cf2PositionNear = _cf_2PositionNear;
    f.cf2PositionFar = _cf_2PositionFar;

    f.colourPosition = _colourPosition;
    f.colourMidpoint = _colourMidpoint;
    f.colourRotation = _colourRotation;

    f.girth = _girth;
    f.tapered = _tapered;

    f.showCrushAndFoldUI = _showCrushAndFoldUI;
    f.showLengthEdit = _showLengthEdit;
    f.showAngleEdit = _showAngleEdit;
    f.showCFEdit = _showCFEdit;
    f.showMenu = _ShowMenu;
    f.hide9045Angles = _Hide90_45Angles;

    f.bottomBarColors = List.from(bottomBarColors);
    f.bottomBarIndex = _bottomBarIndex;

    f.oldInteractiveZoomFactor = _oldInteractiveZoomFactor;
    f.interactiveZoomFactor = _interactiveZoomFactor;

    f.taperedState = _taperedState;
    f.selectedPointIndex = _SelectedPointindex;
    f.dragLengthIndex = _dragLengthIndex;
    f.dragAngleIndex = _dragAngleIndex;
    f.selectedCF = _selectedCF;
    f.selectedRotationPoint = _SelectedRotationPoint;
    f.colourSide = _colourSide;

    f.material = _material;
    f.Lengths = _Lengths;
    f.Job = _Job;
    f.flashingId = _flashingID;

    return f;
  }

  /// Copy *all* fields from [f] into this model:
  void loadFlashing(Flashing f) {
    _points = List.from(f.points);
    _lengthPositions = List.from(f.lengthPositions);
    _lengthWidgetText = List.from(f.lengthWidgetText);
    _nearLengthWidgetText = List.from(f.nearLengthWidgetText);
    _farLengthWidgetText = List.from(f.farLengthWidgetText);
    _lengthPositions_Offsets = List.from(f.lengthPositionsOffsets);
    _anglePositions = List.from(f.anglePositions);
    _anglePositions_Offsets = List.from(f.anglePositionsOffsets);

    _nearPoints = List.from(f.nearPoints);
    _nearLengthPositions = List.from(f.nearLengthPositions);
    _nearLengthPositions_Offsets = List.from(f.nearLengthPositionsOffsets);
    _nearAnglePositions = List.from(f.nearAnglePositions);
    _nearAnglePositions_Offsets = List.from(f.nearAnglePositionsOffsets);

    _farPoints = List.from(f.farPoints);
    _farLengthPositions = List.from(f.farLengthPositions);
    _farLengthPositions_Offsets = List.from(f.farLengthPositionsOffsets);
    _farAnglePositions = List.from(f.farAnglePositions);
    _farAnglePositions_Offsets = List.from(f.farAnglePositionsOffsets);

    _angleScales
      ..clear()
      ..addAll(f.angleScales);
    _lengthScales
      ..clear()
      ..addAll(f.lengthScales);

    _cf_1State = f.cf1State;
    _cf_2State = f.cf2State;
    _cf_1Scale = f.cf1Scale;
    _cf_2Scale = f.cf2Scale;
    _cf_1Length = f.cf1Length;
    _cf_2Length = f.cf2Length;
    _cf_1Position = f.cf1Position;
    _cf_2Position = f.cf2Position;
    _cf_2PositionNear = f.cf2PositionNear;
    _cf_2PositionFar = f.cf2PositionFar;

    _colourPosition = f.colourPosition;
    _colourMidpoint = f.colourMidpoint;
    _colourRotation = f.colourRotation;

    _girth = f.girth;
    _tapered = f.tapered;

    _showCrushAndFoldUI = f.showCrushAndFoldUI;
    _showLengthEdit = f.showLengthEdit;
    _showAngleEdit = f.showAngleEdit;
    _showCFEdit = f.showCFEdit;

    _Hide90_45Angles = f.hide9045Angles;

    bottomBarColors
      ..clear()
      ..addAll(f.bottomBarColors);
    _bottomBarIndex = f.bottomBarIndex;

    _oldInteractiveZoomFactor = f.oldInteractiveZoomFactor;
    _interactiveZoomFactor = f.interactiveZoomFactor;
    _ShowMenu = f.showMenu;
    _taperedState = f.taperedState;
    _SelectedPointindex = f.selectedPointIndex;
    _dragLengthIndex = f.dragLengthIndex;
    _dragAngleIndex = f.dragAngleIndex;
    _selectedCF = f.selectedCF;
    _SelectedRotationPoint = f.selectedRotationPoint;
    _colourSide = f.colourSide;

    _material = f.material;
    _Lengths = f.Lengths;
    _Job = f.Job;
    _flashingID = f.flashingId;

    notifyListeners();
  }

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

  void addFlashing(Flashing flashing) {
    _flashings.add(flashing);
  }

  void editFlashing(Flashing flashing, int index) {
    _flashings[index] = flashing;
  }

  void removeFlashing(int index) {
    _flashings.removeAt(index);
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
      if (_nearLengthWidgetText.isNotEmpty) {
        _nearLengthWidgetText.removeLast();
      }
      UpdateGirth();
    }
  }

  void removeFarPoint() {
    if (_farPoints.isNotEmpty) {
      _farPoints.removeLast();
      if (_farLengthWidgetText.isNotEmpty) {
        _farLengthWidgetText.removeLast();
      }
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
    if (val != 1) {
      disableTaper();
    }

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
    double DeltaAngle = (_flashingRotationAngle - _oldFlashingRotationAngle);

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
