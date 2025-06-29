import 'dart:math' as math;
import 'package:flutter/material.dart';

import 'package:three_js/three_js.dart' as three;

import 'package:three_js_controls/three_js_controls.dart';
import 'package:web/web.dart' as web;

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

  three.BufferGeometry createSegmentQuad(
      Offset p1, Offset p2, Offset p1Far, Offset p2Far, double depth) {
    // 1) Pack 4 vertices: front(p1,p2) then back(p2,p1)
    final verts = <double>[
      p1.dx, p1.dy, 0.0, // v0
      p2.dx, p2.dy, 0.0, // v1
      p2Far.dx, p2Far.dy, depth, // v2
      p1Far.dx, p1Far.dy, depth, // v3
    ];

    // 2) Two triangles: (v0,v1,v2) and (v0,v2,v3)
    final idx = <int>[
      0,
      1,
      2,
      0,
      2,
      3,
    ];

    // 3) Build and return the BufferGeometry
    return three.BufferGeometry()
      ..setAttribute(
        three.Attribute.position,
        three.Float32BufferAttribute.fromList(verts, 3),
      )
      ..setIndex(
        three.Uint16BufferAttribute.fromList(idx, 1),
      )
      ..computeVertexNormals();
  }

  @override
  void initState() {
    super.initState();

    // Create the ThreeJS renderer + widget
    threeJs = three.ThreeJS(
      onSetupComplete: () {
        // Rebuild once the scene is ready
        setState(() {});
      },
      setup: _setupScene,
      settings: three.Settings(
        // optional: tweak antialias, pixel ratio, etc.
        renderOptions: {
          'antialias': true,
        },
      ),
    );
  }

  void _setupScene() {
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
      ..enableDamping = true
      ..dampingFactor = 0.1
      ..screenSpacePanning = false
      ..minDistance = 2
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
    final rnd = math.Random();
    for (var i = 0; i < normalizedPoints.length - 1; i++) {
      final p1 = normalizedPoints[i];
      final p2 = normalizedPoints[i + 1];
      final p1Far = normalizedPointsFar[i];
      final p2Far = normalizedPointsFar[i + 1];
      final geom = createSegmentQuad(p1Far, p2Far, p1, p2, 4);

      final brightness = 0.7 + rnd.nextDouble() * 0.3;

      final faceColor = three.Color.fromHex32(baseHex);
      faceColor.setRGB(
        faceColor.red * brightness,
        faceColor.green * brightness,
        faceColor.blue * brightness,
      );

      final mat = three.MeshStandardMaterial();
      mat.color = three.Color.fromHex32(faceColor.getHex());
      mat.side = three.DoubleSide;
      mat.flatShading = false;
      final mesh = three.Mesh(geom, mat);
      mesh.scale
          .setX(1.0) // left‐right unchanged
          .setY(-1.0) // flip up/down
          .setZ(1.0);
      threeJs.scene.add(mesh);
      // 1) build an edge‐only geometry from your quad’s geometry
      final edgesGeom = three.EdgesGeometry(mesh.geometry!, 10);

// 2) make a black (or any color) line material
      final edgeMat = three.LineBasicMaterial.fromMap({
        'color': 0x000000,
        'linewidth': 3 / web.window.devicePixelRatio,
      });

// 3) create a LineSegments object and add it
      final edgeLines = three.LineSegments(edgesGeom, edgeMat);
      edgeLines.scale
          .setX(1.0) // left‐right unchanged
          .setY(-1.0) // flip up/down
          .setZ(1.0);
      threeJs.scene.add(edgeLines);
    }
    // 5) Lights
    final light1 = three.DirectionalLight(0xFF673AB7, 3);

    light1.position.setValues(0, 1, -2);

    threeJs.scene.add(light1);

    final ambient = three.AmbientLight(0xFF673AB7, 4);

    threeJs.scene.add(ambient);
  }

  @override
  Widget build(BuildContext context) {
    // Build the WebGL canvas
    return Scaffold(
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
    // Clean up both renderer and controls
    controls.dispose();
    threeJs.dispose();
    super.dispose();
  }
}
