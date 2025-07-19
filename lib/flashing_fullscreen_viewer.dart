import 'package:flashing_designer/models/flashing.dart';
import 'package:flutter/material.dart';
import 'flashing_viewer.dart';

class FlashingFullscreenViewer extends StatefulWidget {
  final Flashing flashing;

  const FlashingFullscreenViewer({
    Key? key,
    required this.flashing,
  }) : super(key: key);

  @override
  _FlashingFullscreenViewerState createState() =>
      _FlashingFullscreenViewerState();
}

class _FlashingFullscreenViewerState extends State<FlashingFullscreenViewer> {
  late int taperedState;
  late bool tapered;

  @override
  void initState() {
    super.initState();
    // initialize from the model
    taperedState = 0;
    tapered = widget.flashing.tapered;
  }

  @override
  Widget build(BuildContext context) {
    // rebuild the painter with the current taperedState
    final painter = FlashingCustomPainter(
      taperedState: taperedState,
      flashing: widget.flashing,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: BackButton(color: Colors.white),
        title: const Text(
          "FLASHING PREVIEW",
          style: TextStyle(fontFamily: "Kanit", color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        actions: [
          if (tapered)
            TextButton(
              child: Text(
                '${taperedState == 0 ? 'NEAR' : 'FAR'}',
                style: TextStyle(fontFamily: "Kanit", color: Colors.white),
              ),
              onPressed: () {
                setState(() {
                  // toggle between 0 and 1 (or however many states you need)
                  taperedState = taperedState == 0 ? 1 : 0;
                });
              },
            ),
          const SizedBox(width: 16),
        ],
      ),
      body: InteractiveViewer(
        constrained: false,
        boundaryMargin: const EdgeInsets.all(32),
        minScale: 0.1,
        maxScale: 4.0,
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Center(
            child: FittedBox(
              fit: BoxFit.contain,
              child: SizedBox(
                width: 1024,
                height: 1024,
                child: CustomPaint(painter: painter),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
