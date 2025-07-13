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
      required this.tapered,
      super.key});
  final List<Offset> points;
  final List<Offset> pointsFar;
  final List<Offset> pointsNear;
  final bool tapered;
  @override
  State<CubeOrbitPage> createState() => _CubeOrbitPageState();
}

class _CubeOrbitPageState extends State<CubeOrbitPage> {
  late three.ThreeJS threeJs;
  late OrbitControls controls;

  List<Offset> normalizePoints(List<Offset> pts) {
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
      required TYPRFont font,
      required String text,
      required double size,
      required double depth,
      required three.Vector3 position,
    }) {
      // Build text geometry
      final textGeo = TextGeometry(
        text,
        TextGeometryOptions(
          font: font,
          size: size,
          depth: depth,
          curveSegments: 1,
          bevelEnabled: false,
        ),
      );

      textGeo.computeBoundingBox();

      // Center horizontally
      final bb = textGeo.boundingBox!;
      final xOffset = -0.5 * (bb.max.x - bb.min.x);
      textGeo.translate(xOffset, 0, 0);

      // Build materials (white, flat shading)
      final materials = three.MeshMatcapMaterial.fromMap({
        "color": 0x1c1c1c,
        "flatShading": false,
      });

      // Create mesh and position
      final mesh = three.Mesh(textGeo, materials);
      mesh.position = position;
      return mesh;
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
    threeJs.addAnimationEvent((dt) {
      controls.update();
    });
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

    const baseHex = 0xFF673AB7;
// …then in your scene setup:
    final merged =
        createSegmentsGeometry(normalizedPointsFar, normalizedPoints, 4);
    final mat = three.MeshMatcapMaterial()
      ..color = three.Color.fromHex32(baseHex)
      ..side = three.DoubleSide
      ..flatShading = true;
    threeJs.scene.add(three.Mesh(merged, mat));

// edges
    final edgesGeom = three.EdgesGeometry(merged, 10);
    final edgeMat = three.LineBasicMaterial.fromMap({
      'color': 0x000000,
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
      position: three.Vector3(0.5, -0.5, 4.1),
    );
    threeJs.scene.add(nearLabel);

    final farLabel = createLabelMesh(
      font: font,
      text: "FAR",
      size: labelSize,
      depth: labelDepth,
      position: three.Vector3(0.5, -0.5, -0.1),
    );
    threeJs.scene.add(farLabel);
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
          return threeJs.build();
        },
      ),
    );
  }

  @override
  void dispose() {
    // Clean up both renderer and controls

    try {
      controls.dispose();
      threeJs.dispose();
    } catch (e) {}
    super.dispose();
  }
}
