import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'package:three_js/three_js.dart' as three;
import 'package:three_js_text/three_js_text.dart';
import 'package:three_js_controls/three_js_controls.dart';

class CubeOrbitPage extends StatefulWidget {
  const CubeOrbitPage(
      {required this.points,
      required this.pointsFar,
      required this.pointsNear,
      required this.nearLengthWidgetText,
      required this.nearLengthPositions,
      required this.nearLengthPositionOffsets,
      required this.farLengthWidgetText,
      required this.farLengthPositions,
      required this.farLengthPositionOffsets,
      required this.lengthWidgetText,
      required this.lengthPositions,
      required this.lengthPositionOffsets,
      required this.tapered,
      required this.colorSide,
      required this.color,
      super.key});
  final List<Offset> points;
  final List<Offset> pointsFar;
  final List<Offset> pointsNear;
  final List<int> lengthWidgetText;
  final List<Offset> lengthPositions;
  final List<Offset> lengthPositionOffsets;
  final List<int> nearLengthWidgetText;
  final List<Offset> nearLengthPositions;
  final List<Offset> nearLengthPositionOffsets;
  final List<int> farLengthWidgetText;
  final List<Offset> farLengthPositions;
  final List<Offset> farLengthPositionOffsets;
  final bool tapered;
  final int colorSide;
  final Color color;
  @override
  State<CubeOrbitPage> createState() => _CubeOrbitPageState();
}

class _CubeOrbitPageState extends State<CubeOrbitPage> {
  late three.ThreeJS threeJs;
  late OrbitControls controls;

  List<Offset> normalizePoints(List<Offset> pts) {
    if (pts.isEmpty) return [];
    // 1. Find raw bounds
    final xs = pts.map((o) => o.dx);
    final ys = pts.map((o) => o.dy);
    final minX = xs.reduce(math.min), maxX = xs.reduce(math.max);
    final minY = ys.reduce(math.min), maxY = ys.reduce(math.max);

    // 2. Compute spans
    final width = maxX - minX;
    final height = maxY - minY;

    // 3. Use the larger span for both axes
    final maxSpan = math.max(width, height);
    if (maxSpan == 0) return pts.map((o) => const Offset(0.5, 0.5)).toList();

    // 4. Compute padding to center your shape in [0,1]×[0,1]
    final padX = (1 - width / maxSpan) / 2;
    final padY = (1 - height / maxSpan) / 2;

    // 5. Normalize
    return pts.map((p) {
      final nx = padX + (p.dx - minX) / maxSpan;
      final ny = padY + (p.dy - minY) / maxSpan;
      return Offset(nx, ny);
    }).toList();
  }

  List<Offset> _scale2D(List<Offset> pts, double factor) =>
      pts.map((o) => Offset(o.dx / factor, o.dy / factor)).toList();

  three.BufferGeometry createSegmentsGeometry(
    List<Offset> near,
    List<Offset> far,
    double depth,
  ) {
    final verts = <double>[];
    final idx = <int>[];

    for (var i = 0; i < near.length - 1; i++) {
      final p1 = near[i];
      final p2 = near[i + 1];
      final p2Far = far[i + 1];
      final p1Far = far[i];

      // each quad adds 4 verts, so baseIndex = verts.length/3 before push
      final base = verts.length ~/ 3;
      verts.addAll([
        p1.dx, p1.dy, 0.0, // v0
        p2.dx, p2.dy, 0.0, // v1
        p2Far.dx, p2Far.dy, depth, // v2
        p1Far.dx, p1Far.dy, depth, // v3
      ]);

      idx.addAll([
        base, base + 1, base + 2, // first tri
        base, base + 2, base + 3, // second tri
      ]);
    }

    final geom = three.BufferGeometry()
      ..setAttribute(
        three.Attribute.position,
        three.Float32BufferAttribute.fromList(verts, 3),
      )
      ..setIndex(
        three.Uint16BufferAttribute.fromList(idx, 1),
      )
      ..scale(1, -1, 1)
      ..computeVertexNormals();

    return geom;
  }

  @override
  void initState() {
    // Create the ThreeJS renderer + widget
    threeJs = three.ThreeJS(
      onSetupComplete: () {
        // Rebuild once the scene is ready
        setState(() {});
      },
      setup: _setupScene,
      settings: three.Settings(
        useOpenGL: true,
        enableShadowMap: false,
        // optional: tweak antialias, pixel ratio, etc.
        renderOptions: {
          'antialias': true,
        },
      ),
    );
    super.initState();
  }

  void _setupScene() async {
    Future<TYPRFont> loadFont() async {
      final loader = TYPRLoader();
      final font = await loader.fromAsset("fonts/RobotoMono-Regular.ttf");
      loader.dispose();
      return font!;
    }

    three.Mesh createLabelMesh({
      required three.Font font,
      required String text,
      required double size,
      required double depth,
    }) {
      final geo = three.TextGeometry(
        text,
        three.TextGeometryOptions(
          font: font,
          size: size,
          depth: depth,
          curveSegments: 3,
          bevelEnabled: false,
        ),
      );

      // center it: compute bounds, then translate so center is at (0,0,0)
      geo.computeBoundingBox();
      final b = geo.boundingBox!;
      final xMid = -0.5 * (b.max.x + b.min.x);
      final yMid = -0.5 * (b.max.y + b.min.y);
      geo.translate(xMid, yMid, 0);

      return three.Mesh(
        geo,
        three.MeshBasicMaterial.fromMap({'color': 0x00000000}),
      );
    }

    // 1) New scene + background
    threeJs.scene = three.Scene();
    threeJs.scene.background = three.Color.fromHex32(0xFFFFFFFF);

    // 2) Camera
    threeJs.camera = three.PerspectiveCamera(
      75,
      threeJs.width / threeJs.height,
      0.1,
      1000,
    );
    threeJs.camera.position.setValues(5, 1.5, 5);

    // 3) Orbit & pan controls
    controls = OrbitControls(threeJs.camera, threeJs.globalKey)
      ..enableDamping = false
      ..screenSpacePanning = false
      ..minDistance = 1
      ..maxDistance = 10
      ..target.setX(0)
      ..target.setY(0)
      ..target.setZ(2)
      ..maxPolarAngle = math.pi;
    // allow full vertical orbit
    // Call controls.update() each frame

    List<Offset> normalizedPoints = [];
    List<Offset> normalizedPointsFar = [];
    if (widget.tapered) {
      // 1) Scale everything
      final scaledNear = _scale2D(widget.pointsNear, 10000);
      final scaledFar = _scale2D(widget.pointsFar, 10000);

// 2) Concatenate & normalize together
      final allPts = <Offset>[...scaledNear, ...scaledFar];
      final normalizedAll = normalizePoints(allPts);

// 3) Slice back into “near” and “far”
      normalizedPoints = normalizedAll.sublist(0, scaledNear.length);
      normalizedPointsFar = normalizedAll.sublist(scaledNear.length);
    } else {
      final scaledpoints = _scale2D(widget.points, 10000);

      final normalizedAll = normalizePoints(scaledpoints);
      normalizedPoints = normalizedAll;
      normalizedPointsFar = normalizedAll;
    }

    const backColorHex = 0xcfcccc;
    int frontColorHex = widget.color.toARGB32();
// …then in your scene setup:
    final merged =
        createSegmentsGeometry(normalizedPointsFar, normalizedPoints, 4);
    final mat = three.MeshMatcapMaterial()
      ..color = three.Color.fromHex32(frontColorHex)
      ..flatShading = true
      ..side = widget.colorSide == 1 ? three.FrontSide : three.BackSide;

    final mat2 = three.MeshMatcapMaterial()
      ..color = three.Color.fromHex32(backColorHex)
      ..flatShading = true
      ..side = widget.colorSide == 1 ? three.BackSide : three.FrontSide;

    threeJs.scene.add(three.Mesh(merged, mat));
    threeJs.scene.add(three.Mesh(merged, mat2));

// edges
    final edgesGeom = three.EdgesGeometry(merged, 10);
    final edgeMat = three.LineBasicMaterial.fromMap({
      'color': 0xffffffff,
      'linewidth': 1,
    });
    threeJs.scene.add(three.LineSegments(edgesGeom, edgeMat));

    final font = await loadFont();

// Adjust size/depth to taste
    const double labelSize = 0.1;
    const double labelDepth = 0.01;

    final nearLabel = createLabelMesh(
      font: font,
      text: "NEAR",
      size: labelSize,
      depth: labelDepth,
    );
    threeJs.scene.add(nearLabel);
    nearLabel.position = three.Vector3(0.5, 0.1, 4.2);
    final farLabel = createLabelMesh(
      font: font,
      text: "FAR",
      size: labelSize,
      depth: labelDepth,
    );
    threeJs.scene.add(farLabel);
    farLabel.position = three.Vector3(0.5, 0.1, -0.2);
    const double factor = 10000;
    const double zPlane = 4.01;

// ——— 1) choose your “near” lists based on tapered or not ———
    final List<int> nearTexts =
        widget.tapered ? widget.nearLengthWidgetText : widget.lengthWidgetText;
    final List<Offset> nearBases =
        widget.tapered ? widget.nearLengthPositions : widget.lengthPositions;
    final List<Offset> nearOffsets = widget.tapered
        ? widget.nearLengthPositionOffsets
        : widget.lengthPositionOffsets;
    assert(nearTexts.length == nearBases.length &&
        nearBases.length == nearOffsets.length);

// ——— 2) create one mesh per near‐label (at origin) ———
    final nearLengthLabels = <three.Mesh>[];
    for (var i = 0; i < nearTexts.length; i++) {
      final lbl = createLabelMesh(
        font: font,
        text: nearTexts[i].toString(),
        size: 0.04,
        depth: labelDepth,
      );
      threeJs.scene.add(lbl);
      nearLengthLabels.add(lbl);
    }

// ——— 3) if tapered, also build far‐labels ———
    final farLengthLabels = <three.Mesh>[];
    if (widget.tapered) {
      final farTexts = widget.farLengthWidgetText;
      final farBases = widget.farLengthPositions;
      final farOffsets = widget.farLengthPositionOffsets;
      assert(farTexts.length == farBases.length &&
          farBases.length == farOffsets.length);

      for (var i = 0; i < farTexts.length; i++) {
        final lbl = createLabelMesh(
          font: font,
          text: farTexts[i].toString(),
          size: 0.04,
          depth: labelDepth,
        );
        threeJs.scene.add(lbl);
        farLengthLabels.add(lbl);
      }
    }

    final List<three.Mesh> angleLabels = [];

    for (var i = 1; i < normalizedPoints.length - 1; i++) {
      final p = normalizedPoints[i];
      final prev = normalizedPoints[i - 1];
      final next = normalizedPoints[i + 1];

      // build 2D vectors from current point to prev and next
      final v1 = three.Vector2(prev.dx - p.dx, prev.dy - p.dy);
      final v2 = three.Vector2(next.dx - p.dx, next.dy - p.dy);

      // compute angle via dot product formula
      final dot = v1.dot(v2);
      final mag1 = v1.length;
      final mag2 = v2.length;
      final cos = (dot / (mag1 * mag2)).clamp(-1.0, 1.0);
      final rad = math.acos(cos);
      final deg = rad * (180.0 / math.pi);
      if (deg.round() == 135 || deg.round() == 90 || deg.round() == 45) {
        continue;
      }
      // format label text (e.g. “37.5°”)
      final angleText = '${deg.round().toString()}°';

      // create & add the label
      final angleLabel = createLabelMesh(
        font: font,
        text: angleText,
        size: 0.025,
        depth: 0.005,
      );
      threeJs.scene.add(angleLabel);

      // position it at the point, with your desired z‑offset
      angleLabel.position = three.Vector3(p.dx, -p.dy + 0.01, 4.03);
      angleLabels.add(angleLabel);
    }

// 2) Scale all of your tube points exactly as you do when building the mesh
    final scaledNear = widget.tapered
        ? _scale2D(widget.pointsNear, factor)
        : _scale2D(widget.points, factor);

    final scaledFar = _scale2D(widget.pointsFar, factor);

    final allPts =
        widget.tapered ? [...scaledNear, ...scaledFar] : [...scaledNear];

    final xs = allPts.map((o) => o.dx);
    final ys = allPts.map((o) => o.dy);
    final minX = xs.reduce(math.min);
    final maxX = xs.reduce(math.max);
    final minY = ys.reduce(math.min);
    final maxY = ys.reduce(math.max);
    final spanX = maxX - minX;
    final spanY = maxY - minY;

    final maxSpan = math.max(spanX, spanY);
    final padX = (1.0 - spanX / maxSpan) / 2.0;
    final padY = (1.0 - spanY / maxSpan) / 2.0;

// ——— 4) animate: project each UI‐point by the SAME normalize & billboard ———
    threeJs.addAnimationEvent((_) {
      controls.update();
      nearLabel.lookAt(threeJs.camera.position);
      farLabel.lookAt(threeJs.camera.position);

      for (int i = 0; i < angleLabels.length; i++) {
        angleLabels[i].lookAt(threeJs.camera.position);
      }

      // — Position near‐labels —

      for (var i = 0; i < nearLengthLabels.length; i++) {
        final raw = nearBases[i];
        final scaled = Offset(raw.dx / factor, raw.dy / factor);
        final normX = padX + (scaled.dx - minX) / maxSpan;
        final normY = padY + (scaled.dy - minY) / maxSpan;

        final m = nearLengthLabels[i];
        m.position.x = normX;
        m.position.y = -normY;
        m.position.z = zPlane;
        m.lookAt(threeJs.camera.position);
        m.position.z = 4.1;
      }

      // — Position far‐labels (only when tapered) —
      if (widget.tapered) {
        final farBases = widget.farLengthPositions;
        //final farOffsets = widget.farLengthPositionOffsets;

        for (var i = 0; i < farLengthLabels.length; i++) {
          final raw = farBases[i];
          final scaled = Offset(raw.dx / factor, raw.dy / factor);
          final normX = padX + (scaled.dx - minX) / maxSpan;
          final normY = padY + (scaled.dy - minY) / maxSpan;

          final m = farLengthLabels[i];
          m.position.x = normX;
          m.position.y = -normY;
          // far labels at –0.2 depth
          m.position.z = -0.1;
          m.lookAt(threeJs.camera.position);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Build the WebGL canvas
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              )),
          backgroundColor: Colors.deepPurple.shade500,
          centerTitle: true,
          title: const Text(
            "3D PREVIEW",
            style: TextStyle(fontFamily: "Kanit", color: Colors.white),
          )),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SizedBox(
              width: constraints.maxWidth,
              height: constraints.maxHeight,
              child: threeJs.build());
        },
      ),
    );
  }

  @override
  void dispose() {
    controls.dispose();
    threeJs.dispose();

    super.dispose();
  }
}
