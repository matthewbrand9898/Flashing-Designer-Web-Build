// lib/flashing_thumbnail_list.dart

import 'dart:math' as math;

import 'package:flashing_designer/models/designer_model.dart';
import 'package:flashing_designer/order_page.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'package:provider/provider.dart';
import 'add_edit_flashing_page.dart';
import 'flashing_designer.dart';
import 'flashing_fullscreen_viewer.dart';
import 'flashing_viewer.dart';
import 'global_keys.dart';

import 'models/flashing.dart';
import 'order_storage.dart';
import 'pdf_manager.dart'; // <-- now points at your native PdfManager

class FlashingGridPage extends StatefulWidget {
  const FlashingGridPage({super.key});

  @override
  FlashingGridPageState createState() => FlashingGridPageState();
}

class FlashingGridPageState extends State<FlashingGridPage> {
  final _manager = PdfManager();

  @override
  Widget build(BuildContext context) {
    final List<Flashing> flashings =
        Provider.of<DesignerModel>(context, listen: false).flashings;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const OrdersPage()),
            );
          },
        ),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          Provider.of<DesignerModel>(context, listen: false)
              .currentOrderName!
              .toUpperCase(),
          style: const TextStyle(fontFamily: 'Kanit', color: Colors.white),
        ),
      ),
      body: Center(
        child: Builder(
          builder: (_) {
            final width = MediaQuery.of(context).size.width;
            final columns = (flashings.isNotEmpty)
                ? math.max(1, math.min(3, (width / 600).floor()))
                : 1;
            final maxGridWidth = columns * 600 + (columns - 1) * 8;
            final totalItems = flashings.length;

            return ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxGridWidth.toDouble()),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: columns,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  childAspectRatio: 1,
                ),
                itemCount: totalItems + 1, // +1 for the ADD tile
                itemBuilder: (ctx, idx) {
                  if (idx == 0) {
                    return GestureDetector(
                      onTap: () async {
                        final designerModel =
                            Provider.of<DesignerModel>(context, listen: false);
                        designerModel.clearAll();
                        designerModel.isEditingFlashing = false;

                        final params = await Navigator.of(context)
                            .push<AddFlashingParams?>(
                          MaterialPageRoute(
                            builder: (_) => AddFlashingPage(
                              isEditing: designerModel.isEditingFlashing,
                            ),
                          ),
                        );
                        if (params == null) return;
                        final colourPart = params.colorName != null &&
                                params.colorName!.isNotEmpty
                            ? '${params.colorName!} '
                            : '';
                        final ultra = (params.isUltra ? 'Ultra ' : '');
                        designerModel.material =
                            '$colourPart$ultra${params.thickness.toString() + 'mm'} ${params.material} ';
                        designerModel.currentColour =
                            params.color ?? Color(0xBAC4C8);
                        //set id
                        if (params.id != null) {
                          designerModel.flashingID = params.id!;
                        }
                        // 2) build the comma-separated lengths@counts
                        final lengthsStr = params.items
                            .map((it) => '${it.count}@${it.length}')
                            .join(', ');
                        designerModel.lengths = lengthsStr;

                        // 3) navigate back into the designer
                        if (Navigator.canPop(context)) {
                          Navigator.pop(context);
                          appBarKey.currentState?.tap(0);
                        } else {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const FlashingDesigner()),
                          );
                        }
                      },
                      child: SizedBox(
                        width: 600,
                        height: 600,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 4),
                          child: Card(
                            margin: const EdgeInsets.all(16),
                            elevation: 8,
                            color: Colors.white,
                            clipBehavior: Clip.antiAlias,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
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
                      ),
                    );
                  }

                  // Map grid index → data index (skip the button at 0)
                  final flashingID = idx - 1;
                  //final imgBytes = flashings[flashingID].images[0];

                  Future<void> removeCallback() async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        backgroundColor: Colors.white,
                        title: const Center(
                          child: Text(
                            'DELETE FLASHING',
                            style: TextStyle(
                                fontFamily: 'Kanit', color: Colors.deepPurple),
                          ),
                        ),
                        content: const Text(
                          'Are you sure you want to delete this flashing?',
                          style: TextStyle(fontFamily: 'Kanit'),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(fontFamily: 'Kanit'),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: const Text(
                              'Delete',
                              style: TextStyle(
                                fontFamily: 'Kanit',
                                color: Colors.redAccent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );

                    if (confirm != true) return;

                    // user confirmed — now delete
                    final designerModel =
                        Provider.of<DesignerModel>(context, listen: false);

                    setState(() {
                      designerModel.flashings.removeAt(flashingID);
                    });

                    final orders = await OrderStorage.readOrders();
                    final idx = designerModel.currentOrderIndex!;
                    orders[idx].flashings
                      ..clear()
                      ..addAll(designerModel.flashings);
                    await OrderStorage.saveOrder(orders[idx]);
                  }

                  return GestureDetector(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => FlashingFullscreenViewer(
                              flashing: flashings[flashingID]),
                        ),
                      );
                    },
                    child: Stack(
                      children: [
                        SizedBox(
                          width: 600,
                          height: 600,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 4),
                            child: Card(
                              margin: const EdgeInsets.all(16),
                              elevation: 8,
                              color: Colors.white,
                              clipBehavior: Clip.antiAlias,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: FittedBox(
                                    fit: BoxFit.contain,
                                    child: SizedBox(
                                      width: 1024,
                                      height: 1024,
                                      child: CustomPaint(
                                        painter: FlashingCustomPainter(
                                          taperedState: 0,
                                          flashing: flashings[flashingID],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 35,
                          right: 41,
                          child: IconButton(
                            onPressed: removeCallback,
                            icon: const Icon(
                              Icons.delete,
                              size: 25,
                              color: Colors.redAccent,
                            ),
                          ),
                        ),
                        Positioned(
                            bottom: 35,
                            right: 83,
                            child: IconButton(
                              onPressed: () async {
                                final designerModel =
                                    Provider.of<DesignerModel>(context,
                                        listen: false);
                                designerModel
                                    .loadFlashing(flashings[flashingID]);
                                designerModel.isEditingFlashing = true;
                                designerModel.editFlashingID = flashingID;

                                designerModel.resetTransformController(
                                    MediaQuery.of(context).size);
                                appBarKey.currentState?.tap(1);

                                final params = await Navigator.of(context)
                                    .push<AddFlashingParams?>(
                                  MaterialPageRoute(
                                    builder: (_) => AddFlashingPage(
                                      isEditing:
                                          designerModel.isEditingFlashing,
                                      // pass if editing
                                    ),
                                  ),
                                );
                                if (params == null) return;

                                // 1) set material
                                final colourPart = params.colorName != null &&
                                        params.colorName!.isNotEmpty
                                    ? '${params.colorName!} '
                                    : '';
                                final ultra = (params.isUltra ? 'Ultra' : '');
                                designerModel.material =
                                    '$colourPart$ultra ${params.thickness.toString() + 'mm'} ${params.material} ';

                                //set id
                                if (params.id != null) {
                                  designerModel.flashingID = params.id!;
                                }
                                // 2) build the comma-separated lengths@counts
                                final lengthsStr = params.items
                                    .map((it) => '${it.count}@${it.length}')
                                    .join(', ');
                                designerModel.lengths = lengthsStr;
                                designerModel.currentColour =
                                    params.color ?? Color(0xBAC4C8);

                                if (Navigator.canPop(context)) {
                                  Navigator.pop(context);
                                } else {
                                  Navigator.pushReplacement(
                                    ctx,
                                    MaterialPageRoute(
                                      builder: (_) => const FlashingDesigner(),
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(
                                FontAwesomeIcons.solidPenToSquare,
                                size: 22,
                                color: Colors.deepPurple,
                              ),
                            )),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),

      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterFloat,
      // ——— Generate & open/share PDF ———
      floatingActionButton: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
        onPressed: () async {
          if (flashings.isEmpty) {
            // Tell the user to add a flashing first
            await showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                backgroundColor: Colors.white,
                title: const Center(
                  child: Text(
                    'NO FLASHINGS',
                    style: TextStyle(
                        fontFamily: 'Kanit', color: Colors.deepPurple),
                  ),
                ),
                content: const Text(
                  'Please add at least one flashing before exporting a PDF.',
                  style: TextStyle(fontFamily: 'Kanit'),
                  textAlign: TextAlign.center,
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text(
                      'OK',
                      style: TextStyle(
                          fontFamily: 'Kanit', color: Colors.deepPurple),
                    ),
                  ),
                ],
              ),
            );
            return;
          }

          // 1️⃣ Show spinner
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (ctx) => const AlertDialog(
              title: Center(
                child: Text(
                  'GENERATING PDF',
                  style:
                      TextStyle(fontFamily: 'Kanit', color: Colors.deepPurple),
                ),
              ),
              content: Text(
                textAlign: TextAlign.center,
                'Please Wait',
                style: TextStyle(fontFamily: 'Kanit', color: Colors.black26),
              ),
              backgroundColor: Colors.white,
            ),
          );
          // Give Flutter a moment to actually show that dialog:
          await Future.delayed(Duration(milliseconds: 200));
          try {
            // 2️⃣ Generate, save and open the PDF (runs off the UI thread)
            await _manager.saveAndOpenPdf(
                context,
                Provider.of<DesignerModel>(context, listen: false)
                        .currentOrderName
                        .toString() +
                    ' Flashings ' +
                    DateTime.now().toLocal().toString() +
                    '.pdf');
          } catch (e) {
            // optional: error feedback
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to export PDF: $e')),
              );
            }
          } finally {
            // 3️⃣ Dismiss spinner
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          }
        },
        child: const Text(
          'DOWNLOAD PDF',
          style: TextStyle(fontFamily: 'Kanit', color: Colors.white),
        ),
      ),
    );
  }
}
