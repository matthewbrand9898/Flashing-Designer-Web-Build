import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

part 'flashing.g.dart';

/// Helper to convert an [Offset] to/from JSON.
Map<String, double> _offsetToJson(Offset o) => {'dx': o.dx, 'dy': o.dy};
Offset _offsetFromJson(Map<String, dynamic> m) =>
    Offset((m['dx'] as num).toDouble(), (m['dy'] as num).toDouble());

List<Map<String, double>> _listOffsetToJson(List<Offset> list) =>
    list.map(_offsetToJson).toList();
List<Offset> _listOffsetFromJson(List<dynamic> list) =>
    list.map((e) => _offsetFromJson(e as Map<String, dynamic>)).toList();

/// list of list<int> ⇄ List<Uint8List>
List<Uint8List> _listUint8FromJson(List<dynamic> data) =>
    data.map((e) => Uint8List.fromList((e as List).cast<int>())).toList();
List<List<int>> _listUint8ToJson(List<Uint8List> uList) =>
    uList.map((u) => u.toList()).toList();

/// Helper to convert a [Color] to/from JSON (as an int value).
List<Color> _colorListFromJson(List<dynamic> data) =>
    data.map((c) => Color(c as int)).toList();
List<int> _colorListToJson(List<Color> colors) =>
    colors.map((c) => c.toARGB32()).toList();

@JsonSerializable(explicitToJson: true)
class Flashing {
  @JsonKey(toJson: _listOffsetToJson, fromJson: _listOffsetFromJson)
  List<Offset> points = <Offset>[];

  @JsonKey(toJson: _listOffsetToJson, fromJson: _listOffsetFromJson)
  List<Offset> lengthPositions = <Offset>[];

  List<int> lengthWidgetText = <int>[];
  List<int> nearLengthWidgetText = <int>[];
  List<int> farLengthWidgetText = <int>[];

  @JsonKey(toJson: _listOffsetToJson, fromJson: _listOffsetFromJson)
  List<Offset> lengthPositionsOffsets = <Offset>[];

  @JsonKey(toJson: _listOffsetToJson, fromJson: _listOffsetFromJson)
  List<Offset> anglePositions = <Offset>[];

  @JsonKey(toJson: _listOffsetToJson, fromJson: _listOffsetFromJson)
  List<Offset> anglePositionsOffsets = <Offset>[];

  @JsonKey(toJson: _listOffsetToJson, fromJson: _listOffsetFromJson)
  List<Offset> nearPoints = <Offset>[];

  @JsonKey(toJson: _listOffsetToJson, fromJson: _listOffsetFromJson)
  List<Offset> nearLengthPositions = <Offset>[];

  @JsonKey(toJson: _listOffsetToJson, fromJson: _listOffsetFromJson)
  List<Offset> nearLengthPositionsOffsets = <Offset>[];

  @JsonKey(toJson: _listOffsetToJson, fromJson: _listOffsetFromJson)
  List<Offset> nearAnglePositions = <Offset>[];

  @JsonKey(toJson: _listOffsetToJson, fromJson: _listOffsetFromJson)
  List<Offset> nearAnglePositionsOffsets = <Offset>[];

  @JsonKey(toJson: _listOffsetToJson, fromJson: _listOffsetFromJson)
  List<Offset> farPoints = <Offset>[];

  @JsonKey(toJson: _listOffsetToJson, fromJson: _listOffsetFromJson)
  List<Offset> farLengthPositions = <Offset>[];

  @JsonKey(toJson: _listOffsetToJson, fromJson: _listOffsetFromJson)
  List<Offset> farLengthPositionsOffsets = <Offset>[];

  @JsonKey(toJson: _listOffsetToJson, fromJson: _listOffsetFromJson)
  List<Offset> farAnglePositions = <Offset>[];

  @JsonKey(toJson: _listOffsetToJson, fromJson: _listOffsetFromJson)
  List<Offset> farAnglePositionsOffsets = <Offset>[];

  List<double> angleScales = <double>[];
  List<double> lengthScales = <double>[];

  @JsonKey(
    toJson: _listUint8ToJson,
    fromJson: _listUint8FromJson,
  )
  List<Uint8List> images = [];

  int cf1State = 0;
  int cf2State = 0;

  double cf1Scale = 1;
  double cf2Scale = 1;

  double cf1Length = 0;
  double cf2Length = 0;

  @JsonKey(toJson: _offsetToJson, fromJson: _offsetFromJson)
  Offset cf1Position = const Offset(0, 0);

  @JsonKey(toJson: _offsetToJson, fromJson: _offsetFromJson)
  Offset cf2Position = const Offset(0, 0);

  @JsonKey(toJson: _offsetToJson, fromJson: _offsetFromJson)
  Offset cf2PositionNear = const Offset(0, 0);

  @JsonKey(toJson: _offsetToJson, fromJson: _offsetFromJson)
  Offset cf2PositionFar = const Offset(0, 0);

  @JsonKey(toJson: _offsetToJson, fromJson: _offsetFromJson)
  Offset colourPosition = const Offset(0, 0);

  @JsonKey(toJson: _offsetToJson, fromJson: _offsetFromJson)
  Offset colourMidpoint = const Offset(0, 0);

  double colourRotation = 0;

  int girth = 0;
  bool tapered = false;

  bool showCrushAndFoldUI = false;
  bool showLengthEdit = false;
  bool showAngleEdit = false;
  bool showCFEdit = false;
  bool showMenu = false;
  bool hide9045Angles = false;

  @JsonKey(toJson: _colorListToJson, fromJson: _colorListFromJson)
  List<Color> bottomBarColors = <Color>[Colors.white, Colors.grey, Colors.grey];
  int bottomBarIndex = 0;

  double? oldInteractiveZoomFactor;
  double interactiveZoomFactor = 1;

  int taperedState = 0;
  int selectedPointIndex = 1;
  int dragLengthIndex = 0;
  int dragAngleIndex = 0;
  int selectedCF = 0;
  int selectedRotationPoint = 0;
  int colourSide = 1;

  String material = '';
  String Lengths = '';
  String Job = '';
  String flashingId = '';
  int? id;

  Flashing();

  factory Flashing.fromJson(Map<String, dynamic> json) =>
      _$FlashingFromJson(json);
  Map<String, dynamic> toJson() => _$FlashingToJson(this);
}
