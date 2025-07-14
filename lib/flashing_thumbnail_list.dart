// lib/flashing_thumbnail_list.dart

import 'dart:math' as math;

import 'package:flashing_designer/models/designer_model.dart';
import 'package:flashing_designer/order_page.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:provider/provider.dart';
import 'flashing_designer.dart';
import 'global_keys.dart';
import 'models/flashing.dart';
import 'order_storage.dart';
import 'pdf_manager.dart'; // <-- now points at your native PdfManager

/// A single length/count entry
class FlashingItem {
  final int length;
  final int count;
  FlashingItem(this.length, this.count);
}

/// The dialog’s result, with material, thickness, optional colour, etc.
class AddFlashingParams {
  final String? id;
  final String material;
  final double thickness;
  final bool isUltra; // ← new
  final String? colorName;
  final Color? color;
  final List<FlashingItem> items;

  AddFlashingParams({
    this.id,
    required this.material,
    required this.thickness,
    this.isUltra = false, // default
    this.colorName,
    this.color,
    required this.items,
  });
}

class FlashingGridPage extends StatefulWidget {
  const FlashingGridPage({super.key});

  @override
  FlashingGridPageState createState() => FlashingGridPageState();
}

class FlashingGridPageState extends State<FlashingGridPage> {
  final _manager = PdfManager();

  Future<AddFlashingParams?> showAddFlashingDialog(BuildContext context) {
    const colorOptions = <String, Color>{
      'Dover White': Color(0xFFF9FBF1),
      'Surfmist': Color(0xFFE4E2D5),
      'Evening Haze': Color(0xFFC5C2AA),
      'Southerly': Color(0xFFD2D1CB),
      'Dune': Color(0xFFB1ADA3),
      'Paperbark': Color(0xFFCABFA4),
      'Classic Cream': Color(0xFFE9DCB8),
      'Shale Grey': Color(0xFFBDBFBA),
      'Bluegum': Color(0xFF969799),
      'Windspray': Color(0xFF888B8A),
      'Gully': Color(0xFF857E73),
      'Jasper': Color(0xFF6C6153),
      'Wallaby': Color(0xFF7F7C78),
      'Basalt': Color(0xFF6D6C6E),
      'Monument': Color(0xFF323233),
      'Night Sky': Color(0xFF000000),
      'Ironstone': Color(0xFF3E434C),
      'Deep Ocean': Color(0xFF364152),
      'Pale Eucalypt': Color(0xFF7C846A),
      'Cottage Green': Color(0xFF304C3C),
      'Manor Red': Color(0xFF5E1D0E),
      'Woodland Grey': Color(0xFF4B4C46),
      'Zinc': Color(0xFFBAC4C8),
    };

    String? selectedColorName;
    String selectedMaterial = 'Colorbond';
    bool isUltra = false; // ← new state
    final idCtrl = TextEditingController();
    final thicknessCtrl = TextEditingController(text: '0.55');
    final rows = <Map<String, TextEditingController>>[
      {
        'length': TextEditingController(text: ''),
        'count': TextEditingController(text: ''),
      }
    ];

    return showDialog<AddFlashingParams>(
      useSafeArea: false,
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Center(
        child: StatefulBuilder(
          builder: (ctx, setState) {
            bool canAdd() {
              final thick = double.tryParse(thicknessCtrl.text);
              if (thick == null || thick <= 0) return false;
              if ((selectedMaterial == 'Aluminium' ||
                      selectedMaterial == 'Colorbond') &&
                  selectedColorName == null) return false;
              for (var r in rows) {
                final len = int.tryParse(r['length']!.text);
                final cnt = int.tryParse(r['count']!.text);
                if (len == null || len <= 0) return false;
                if (cnt == null || cnt <= 0) return false;
              }
              return true;
            }

            const maxW = 500.0;
            final chipW = (maxW - (5 - 1) * 8) / 5;

            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              insetPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              title: const Center(
                child: Text(
                  'NEW FLASHING',
                  style: TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: 20,
                    color: Colors.deepPurple,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              content: SizedBox(
                width: maxW,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        height: 8,
                      ),
                      // Optional ID
                      TextField(
                        controller: idCtrl,
                        style: const TextStyle(
                            fontFamily: 'Kanit', fontWeight: FontWeight.bold),
                        decoration: InputDecoration(
                          labelText: 'Flashing ID (optional)',
                          labelStyle: const TextStyle(
                              fontFamily: 'Kanit', fontSize: 12),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6)),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Material dropdown
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'MATERIAL TYPE',
                          style: TextStyle(
                              fontFamily: 'Kanit', color: Colors.deepPurple),
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: selectedMaterial,
                        dropdownColor: Colors.white,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6)),
                        ),
                        items: const [
                          'Colorbond',
                          'Aluminium',
                          'Galvanised',
                          'Stainless Steel',
                        ]
                            .map((m) => DropdownMenuItem(
                                  value: m,
                                  child: Text(m,
                                      style: TextStyle(fontFamily: 'Kanit')),
                                ))
                            .toList(),
                        onChanged: (m) => setState(() {
                          selectedMaterial = m!;
                          if (m != 'Aluminium' && m != 'Colorbond') {
                            selectedColorName = null;
                            isUltra = false;
                          }
                        }),
                      ),

                      const SizedBox(height: 16),
                      // Thickness
                      TextField(
                        controller: thicknessCtrl,
                        style: const TextStyle(
                            fontFamily: 'Kanit', fontWeight: FontWeight.bold),
                        keyboardType:
                            TextInputType.numberWithOptions(decimal: true),
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          labelText: 'Thickness (mm)',
                          labelStyle: const TextStyle(
                              fontFamily: 'Kanit', fontSize: 12),
                          errorText: (thicknessCtrl.text.isNotEmpty &&
                                  (double.tryParse(thicknessCtrl.text) ==
                                          null ||
                                      double.parse(thicknessCtrl.text) <= 0))
                              ? 'Must be > 0'
                              : null,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6)),
                        ),
                      ),

                      // Colour selector—only for Aluminium or Colorbond
                      if (selectedMaterial == 'Aluminium' ||
                          selectedMaterial == 'Colorbond') ...[
                        const SizedBox(height: 16),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'SELECT COLOUR',
                            style: TextStyle(
                                fontFamily: 'Kanit', color: Colors.deepPurple),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: colorOptions.entries.map((e) {
                            final sel = e.key == selectedColorName;
                            return GestureDetector(
                              onTap: () =>
                                  setState(() => selectedColorName = e.key),
                              child: Container(
                                width: chipW,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: e.value.withValues(alpha: 0.5),
                                  border: Border.all(
                                    color: sel
                                        ? Colors.deepPurple
                                        : Colors.transparent,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  e.key,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontFamily: 'Kanit',
                                    color: Colors.black,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                      // Ultra checkbox—only for Colorbond
                      if (selectedMaterial == 'Colorbond') ...[
                        const SizedBox(height: 16),
                        CheckboxListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('ULTRA',
                              style: TextStyle(
                                  fontFamily: 'Kanit',
                                  color: Colors.deepPurple)),
                          value: isUltra,
                          activeColor: Colors.deepPurple,
                          onChanged: (v) => setState(() => isUltra = v!),
                        ),
                      ],
                      const SizedBox(height: 16),
                      // Lengths & counts
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'LENGTHS & AMOUNT',
                          style: TextStyle(
                              fontFamily: 'Kanit', color: Colors.deepPurple),
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...rows.asMap().entries.map((e) {
                        final idx = e.key;
                        final ctrls = e.value;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(children: [
                            Expanded(
                              child: TextField(
                                controller: ctrls['length'],
                                keyboardType: TextInputType.numberWithOptions(
                                    decimal: true),
                                onChanged: (_) => setState(() {}),
                                style: const TextStyle(
                                    fontFamily: 'Kanit',
                                    fontWeight: FontWeight.bold),
                                decoration: InputDecoration(
                                  labelText: 'Length (mm)',
                                  labelStyle: const TextStyle(
                                      fontFamily: 'Kanit', fontSize: 12),
                                  errorText: (ctrls['length']!
                                              .text
                                              .isNotEmpty &&
                                          (int.tryParse(
                                                      ctrls['length']!.text) ==
                                                  null ||
                                              int.parse(
                                                      ctrls['length']!.text) <=
                                                  0))
                                      ? 'Must be > 0'
                                      : null,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 80,
                              child: TextField(
                                controller: ctrls['count'],
                                keyboardType: TextInputType.number,
                                onChanged: (_) => setState(() {}),
                                style: const TextStyle(
                                    fontFamily: 'Kanit',
                                    fontWeight: FontWeight.bold),
                                decoration: InputDecoration(
                                  labelText: 'Count',
                                  labelStyle: const TextStyle(
                                      fontFamily: 'Kanit', fontSize: 12),
                                  errorText: (ctrls['count']!.text.isNotEmpty &&
                                          (int.tryParse(ctrls['count']!.text) ==
                                                  null ||
                                              int.parse(ctrls['count']!.text) <=
                                                  0))
                                      ? 'Must be > 0'
                                      : null,
                                  border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(6)),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            if (rows.length > 1)
                              IconButton(
                                icon: const Icon(Icons.remove_circle,
                                    color: Colors.redAccent),
                                onPressed: () =>
                                    setState(() => rows.removeAt(idx)),
                              ),
                          ]),
                        );
                      }),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          onPressed: () => setState(() {
                            rows.add({
                              'length': TextEditingController(text: ''),
                              'count': TextEditingController(text: ''),
                            });
                          }),
                          icon: const Icon(Icons.add, color: Colors.deepPurple),
                          label: const Text(
                            'Add Length',
                            style: TextStyle(
                                fontFamily: 'Kanit', color: Colors.deepPurple),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actionsPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text(
                    'Cancel',
                    style:
                        TextStyle(fontFamily: 'Kanit', color: Colors.redAccent),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: canAdd()
                      ? () {
                          final items = rows.map((r) {
                            final len = int.parse(r['length']!.text);
                            final cnt = int.parse(r['count']!.text);
                            return FlashingItem(len, cnt);
                          }).toList();
                          Navigator.of(ctx).pop(AddFlashingParams(
                            id: idCtrl.text.trim().isEmpty
                                ? null
                                : idCtrl.text.trim(),
                            material: selectedMaterial,
                            thickness: double.parse(thicknessCtrl.text),
                            isUltra: selectedMaterial == 'Colorbond'
                                ? isUltra
                                : false,
                            colorName: (selectedMaterial == 'Aluminium' ||
                                    selectedMaterial == 'Colorbond')
                                ? selectedColorName
                                : null,
                            color: (selectedMaterial == 'Aluminium' ||
                                    selectedMaterial == 'Colorbond')
                                ? colorOptions[selectedColorName]!
                                : null,
                            items: items,
                          ));
                        }
                      : null,
                  child: const Text(
                    'Add',
                    style: TextStyle(fontFamily: 'Kanit', color: Colors.white),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Utility from flutter_colorpicker to decide text color
  bool useWhiteForeground(Color backgroundColor) =>
      1.0 -
          (0.299 * backgroundColor.r +
                  0.587 * backgroundColor.g +
                  0.114 * backgroundColor.b) /
              255.0 >
      0.5;

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

                        final params = await showAddFlashingDialog(context);
                        if (params == null) return;
                        final colourPart = params.colorName != null &&
                                params.colorName!.isNotEmpty
                            ? '${params.colorName!} '
                            : '';
                        final ultra = (params.isUltra ? 'Ultra ' : '');
                        designerModel.material =
                            '$colourPart$ultra${params.thickness.toString() + 'mm'} ${params.material} ';

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
                    await OrderStorage.writeOrders(orders);
                  }

                  return GestureDetector(
                    onTap: () {
                      // local mutable state for this dialog
                      var currentIndex = 0;
                      final pageController = PageController(initialPage: 0);
                      showDialog(
                        context: ctx,
                        barrierColor: Colors.black87,
                        builder: (_) => StatefulBuilder(
                          builder: (dialogCtx, setDialogState) {
                            final images = flashings[flashingID].images;
                            return Dialog(
                              backgroundColor: Colors.black87,
                              insetPadding: EdgeInsets.zero,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  PhotoViewGallery.builder(
                                    pageController: pageController,
                                    itemCount: images.length,
                                    onPageChanged: (i) => setDialogState(() {
                                      currentIndex = i;
                                    }),
                                    builder: (ctx, index) =>
                                        PhotoViewGalleryPageOptions(
                                      filterQuality: FilterQuality.high,
                                      imageProvider: MemoryImage(images[index]),
                                      minScale:
                                          PhotoViewComputedScale.contained *
                                              0.8,
                                      maxScale:
                                          PhotoViewComputedScale.covered * 5.0,
                                      heroAttributes: PhotoViewHeroAttributes(
                                          tag: 'img$index'),
                                    ),
                                    backgroundDecoration: const BoxDecoration(
                                        color: Colors.black87),
                                    scrollPhysics:
                                        const BouncingScrollPhysics(),
                                    loadingBuilder: (_, __) => const Center(
                                        child: CircularProgressIndicator()),
                                  ),

                                  // ← left arrow
                                  if (currentIndex > 0)
                                    Positioned(
                                      left: 8,
                                      child: IconButton(
                                        iconSize: 32,
                                        color: Colors.white70,
                                        icon: const Icon(Icons.chevron_left),
                                        onPressed: () {
                                          pageController.previousPage(
                                            duration: const Duration(
                                                milliseconds: 300),
                                            curve: Curves.easeInOut,
                                          );
                                        },
                                      ),
                                    ),

                                  // → right arrow
                                  if (currentIndex < images.length - 1)
                                    Positioned(
                                      right: 8,
                                      child: IconButton(
                                        iconSize: 32,
                                        color: Colors.white70,
                                        icon: const Icon(Icons.chevron_right),
                                        onPressed: () {
                                          pageController.nextPage(
                                            duration: const Duration(
                                                milliseconds: 300),
                                            curve: Curves.easeInOut,
                                          );
                                        },
                                      ),
                                    ),

                                  // ✕ close
                                  Positioned(
                                    top: 16,
                                    right: 16,
                                    child: CircleAvatar(
                                      backgroundColor: Colors.deepPurple,
                                      child: IconButton(
                                        icon: const Icon(Icons.close,
                                            color: Colors.white),
                                        onPressed: () =>
                                            Navigator.of(dialogCtx).pop(),
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
                                  child: Image.memory(
                                    flashings[flashingID].images[0],
                                    width: 600,
                                    height: 600,
                                    cacheWidth: 600,
                                    cacheHeight: 600,
                                    fit: BoxFit.contain,
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
                                appBarKey.currentState
                                    ?.tap(designerModel.bottomBarIndex);

                                final params =
                                    await showAddFlashingDialog(context);
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
                                Icons.edit,
                                size: 25,
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
                    'No Flashings',
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
            await _manager.saveAndOpenPdf(context);
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
