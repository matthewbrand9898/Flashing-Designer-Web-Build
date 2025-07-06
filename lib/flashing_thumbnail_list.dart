import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'flashing_designer.dart';
import 'pdf_manager.dart'; // adjust to your path

class FlashingGridPage extends StatefulWidget {
  const FlashingGridPage({super.key});

  @override
  FlashingGridPageState createState() => FlashingGridPageState();
}

class FlashingGridPageState extends State<FlashingGridPage> {
  final _manager = PdfManager();

  @override
  Widget build(BuildContext context) {
    final images = _manager.images;
    final taperedImages = _manager.taperedImages;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'YOUR FLASHINGS',
          style: TextStyle(
            fontFamily: 'Kanit',
            color: Colors.white,
          ),
        ),
      ),
      body: Center(
        child: Builder(
          builder: (context) {
            final width = MediaQuery.of(context).size.width;
            final columns = images.isNotEmpty || taperedImages.isNotEmpty
                ? math.max(1, math.min(3, (width / 600).floor()))
                : 1;
            final maxGridWidth = columns * 600 + (columns - 1) * 8;

            // total “cells” = all non-tapered + all tapered images
            final totalItems = images.length + taperedImages.length;

            return ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxGridWidth.toDouble()),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1,
                ),
                // +1 for the ADD button in slot 0
                itemCount: totalItems + 1,
                itemBuilder: (context, idx) {
                  if (idx == 0) {
                    // ——— Add button ———
                    return GestureDetector(
                      onTap: () {
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                        } else {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => FlashingDesigner()),
                          );
                        }
                      },
                      child: SizedBox(
                        width: 600,
                        height: 600,
                        child: Card(
                          margin: const EdgeInsets.all(8),
                          elevation: 8,
                          color: Colors.white,
                          clipBehavior: Clip.antiAlias,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add_box_rounded,
                                    size: 48, color: Colors.deepPurple),
                                SizedBox(height: 8),
                                Text(
                                  'ADD FLASHING',
                                  style: TextStyle(
                                    fontFamily: 'Kanit',
                                    color: Colors.deepPurple,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  // 1) Map grid index → data index (skip the button)
                  final dataIdx = idx - 1;

                  // 2) Decide which list and pull the bytes
                  final isSingle = dataIdx < images.length;
                  final imgBytes = isSingle
                      ? images[dataIdx]
                      : taperedImages[dataIdx - images.length];

                  // 3) Define removal, wrapped in setState so it only runs on tap
                  void removeCallback() {
                    setState(() {
                      if (isSingle) {
                        _manager.removeImageAt(dataIdx);
                      } else {
                        // if you want to remove only that half:
                        // _manager.removeTaperedImageAt(dataIdx - images.length);

                        // or to remove the entire pair:
                        final flatIdx = dataIdx - images.length;
                        final pairIdx = flatIdx ~/ 2;
                        _manager.removeTaperedPairAt(pairIdx);
                      }
                    });
                  }

                  // ——— Thumbnail cell ———
                  return GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        barrierColor: Colors.black12.withAlpha(200),
                        builder: (_) => Dialog(
                          backgroundColor: Colors.transparent,
                          insetPadding: EdgeInsets.zero,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              PhotoView(
                                filterQuality: FilterQuality.high,
                                imageProvider: MemoryImage(imgBytes),
                                minScale:
                                    PhotoViewComputedScale.contained * 0.8,
                                maxScale: PhotoViewComputedScale.covered * 5.0,
                                backgroundDecoration: const BoxDecoration(
                                    color: Colors.transparent),
                              ),
                              Positioned(
                                top: 16,
                                right: 16,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.deepPurple,
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.close,
                                        color: Colors.white, size: 24),
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    child: Stack(
                      children: [
                        SizedBox(
                          width: 600,
                          height: 600,
                          child: Card(
                            margin: const EdgeInsets.all(8),
                            elevation: 8,
                            color: Colors.white,
                            clipBehavior: Clip.antiAlias,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.memory(
                                  imgBytes,
                                  width: 600,
                                  height: 600,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 32,
                          right: 32,
                          child: GestureDetector(
                            onTap: removeCallback,
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.redAccent,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(4),
                              child: const Icon(Icons.close,
                                  size: 18, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
        onPressed: () {
          PdfManager pdfManager = PdfManager();
          if (pdfManager.images.isNotEmpty ||
              pdfManager.taperedImages.isNotEmpty) {
            pdfManager.saveAndDownload(context);
          }
        },
        child: const Text(
          'DOWNLOAD PDF',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Kanit',
          ),
        ),
      ),
    );
  }
}
