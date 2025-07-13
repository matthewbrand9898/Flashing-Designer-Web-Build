// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flashing.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Flashing _$FlashingFromJson(Map<String, dynamic> json) => Flashing()
  ..points = _listOffsetFromJson(json['points'] as List)
  ..lengthPositions = _listOffsetFromJson(json['lengthPositions'] as List)
  ..lengthWidgetText = (json['lengthWidgetText'] as List<dynamic>)
      .map((e) => (e as num).toInt())
      .toList()
  ..nearLengthWidgetText = (json['nearLengthWidgetText'] as List<dynamic>)
      .map((e) => (e as num).toInt())
      .toList()
  ..farLengthWidgetText = (json['farLengthWidgetText'] as List<dynamic>)
      .map((e) => (e as num).toInt())
      .toList()
  ..lengthPositionsOffsets =
      _listOffsetFromJson(json['lengthPositionsOffsets'] as List)
  ..anglePositions = _listOffsetFromJson(json['anglePositions'] as List)
  ..anglePositionsOffsets =
      _listOffsetFromJson(json['anglePositionsOffsets'] as List)
  ..nearPoints = _listOffsetFromJson(json['nearPoints'] as List)
  ..nearLengthPositions =
      _listOffsetFromJson(json['nearLengthPositions'] as List)
  ..nearLengthPositionsOffsets =
      _listOffsetFromJson(json['nearLengthPositionsOffsets'] as List)
  ..nearAnglePositions = _listOffsetFromJson(json['nearAnglePositions'] as List)
  ..nearAnglePositionsOffsets =
      _listOffsetFromJson(json['nearAnglePositionsOffsets'] as List)
  ..farPoints = _listOffsetFromJson(json['farPoints'] as List)
  ..farLengthPositions = _listOffsetFromJson(json['farLengthPositions'] as List)
  ..farLengthPositionsOffsets =
      _listOffsetFromJson(json['farLengthPositionsOffsets'] as List)
  ..farAnglePositions = _listOffsetFromJson(json['farAnglePositions'] as List)
  ..farAnglePositionsOffsets =
      _listOffsetFromJson(json['farAnglePositionsOffsets'] as List)
  ..angleScales = (json['angleScales'] as List<dynamic>)
      .map((e) => (e as num).toDouble())
      .toList()
  ..lengthScales = (json['lengthScales'] as List<dynamic>)
      .map((e) => (e as num).toDouble())
      .toList()
  ..images = _listUint8FromJson(json['images'] as List)
  ..cf1State = (json['cf1State'] as num).toInt()
  ..cf2State = (json['cf2State'] as num).toInt()
  ..cf1Scale = (json['cf1Scale'] as num).toDouble()
  ..cf2Scale = (json['cf2Scale'] as num).toDouble()
  ..cf1Length = (json['cf1Length'] as num).toDouble()
  ..cf2Length = (json['cf2Length'] as num).toDouble()
  ..cf1Position = _offsetFromJson(json['cf1Position'] as Map<String, dynamic>)
  ..cf2Position = _offsetFromJson(json['cf2Position'] as Map<String, dynamic>)
  ..cf2PositionNear =
      _offsetFromJson(json['cf2PositionNear'] as Map<String, dynamic>)
  ..cf2PositionFar =
      _offsetFromJson(json['cf2PositionFar'] as Map<String, dynamic>)
  ..colourPosition =
      _offsetFromJson(json['colourPosition'] as Map<String, dynamic>)
  ..colourMidpoint =
      _offsetFromJson(json['colourMidpoint'] as Map<String, dynamic>)
  ..colourRotation = (json['colourRotation'] as num).toDouble()
  ..girth = (json['girth'] as num).toInt()
  ..tapered = json['tapered'] as bool
  ..showCrushAndFoldUI = json['showCrushAndFoldUI'] as bool
  ..showLengthEdit = json['showLengthEdit'] as bool
  ..showAngleEdit = json['showAngleEdit'] as bool
  ..showCFEdit = json['showCFEdit'] as bool
  ..showMenu = json['showMenu'] as bool
  ..hide9045Angles = json['hide9045Angles'] as bool
  ..bottomBarColors = _colorListFromJson(json['bottomBarColors'] as List)
  ..bottomBarIndex = (json['bottomBarIndex'] as num).toInt()
  ..oldInteractiveZoomFactor =
      (json['oldInteractiveZoomFactor'] as num?)?.toDouble()
  ..interactiveZoomFactor = (json['interactiveZoomFactor'] as num).toDouble()
  ..taperedState = (json['taperedState'] as num).toInt()
  ..selectedPointIndex = (json['selectedPointIndex'] as num).toInt()
  ..dragLengthIndex = (json['dragLengthIndex'] as num).toInt()
  ..dragAngleIndex = (json['dragAngleIndex'] as num).toInt()
  ..selectedCF = (json['selectedCF'] as num).toInt()
  ..selectedRotationPoint = (json['selectedRotationPoint'] as num).toInt()
  ..colourSide = (json['colourSide'] as num).toInt()
  ..material = json['material'] as String
  ..Lengths = json['Lengths'] as String
  ..Job = json['Job'] as String
  ..flashingId = json['flashingId'] as String
  ..id = (json['id'] as num?)?.toInt();

Map<String, dynamic> _$FlashingToJson(Flashing instance) => <String, dynamic>{
      'points': _listOffsetToJson(instance.points),
      'lengthPositions': _listOffsetToJson(instance.lengthPositions),
      'lengthWidgetText': instance.lengthWidgetText,
      'nearLengthWidgetText': instance.nearLengthWidgetText,
      'farLengthWidgetText': instance.farLengthWidgetText,
      'lengthPositionsOffsets':
          _listOffsetToJson(instance.lengthPositionsOffsets),
      'anglePositions': _listOffsetToJson(instance.anglePositions),
      'anglePositionsOffsets':
          _listOffsetToJson(instance.anglePositionsOffsets),
      'nearPoints': _listOffsetToJson(instance.nearPoints),
      'nearLengthPositions': _listOffsetToJson(instance.nearLengthPositions),
      'nearLengthPositionsOffsets':
          _listOffsetToJson(instance.nearLengthPositionsOffsets),
      'nearAnglePositions': _listOffsetToJson(instance.nearAnglePositions),
      'nearAnglePositionsOffsets':
          _listOffsetToJson(instance.nearAnglePositionsOffsets),
      'farPoints': _listOffsetToJson(instance.farPoints),
      'farLengthPositions': _listOffsetToJson(instance.farLengthPositions),
      'farLengthPositionsOffsets':
          _listOffsetToJson(instance.farLengthPositionsOffsets),
      'farAnglePositions': _listOffsetToJson(instance.farAnglePositions),
      'farAnglePositionsOffsets':
          _listOffsetToJson(instance.farAnglePositionsOffsets),
      'angleScales': instance.angleScales,
      'lengthScales': instance.lengthScales,
      'images': _listUint8ToJson(instance.images),
      'cf1State': instance.cf1State,
      'cf2State': instance.cf2State,
      'cf1Scale': instance.cf1Scale,
      'cf2Scale': instance.cf2Scale,
      'cf1Length': instance.cf1Length,
      'cf2Length': instance.cf2Length,
      'cf1Position': _offsetToJson(instance.cf1Position),
      'cf2Position': _offsetToJson(instance.cf2Position),
      'cf2PositionNear': _offsetToJson(instance.cf2PositionNear),
      'cf2PositionFar': _offsetToJson(instance.cf2PositionFar),
      'colourPosition': _offsetToJson(instance.colourPosition),
      'colourMidpoint': _offsetToJson(instance.colourMidpoint),
      'colourRotation': instance.colourRotation,
      'girth': instance.girth,
      'tapered': instance.tapered,
      'showCrushAndFoldUI': instance.showCrushAndFoldUI,
      'showLengthEdit': instance.showLengthEdit,
      'showAngleEdit': instance.showAngleEdit,
      'showCFEdit': instance.showCFEdit,
      'showMenu': instance.showMenu,
      'hide9045Angles': instance.hide9045Angles,
      'bottomBarColors': _colorListToJson(instance.bottomBarColors),
      'bottomBarIndex': instance.bottomBarIndex,
      'oldInteractiveZoomFactor': instance.oldInteractiveZoomFactor,
      'interactiveZoomFactor': instance.interactiveZoomFactor,
      'taperedState': instance.taperedState,
      'selectedPointIndex': instance.selectedPointIndex,
      'dragLengthIndex': instance.dragLengthIndex,
      'dragAngleIndex': instance.dragAngleIndex,
      'selectedCF': instance.selectedCF,
      'selectedRotationPoint': instance.selectedRotationPoint,
      'colourSide': instance.colourSide,
      'material': instance.material,
      'Lengths': instance.Lengths,
      'Job': instance.Job,
      'flashingId': instance.flashingId,
      'id': instance.id,
    };
