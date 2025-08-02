import 'package:flutter/material.dart';

/// A single length/count entry
class FlashingItem {
  final int length;
  final int count;
  FlashingItem(this.length, this.count);
}

/// The page’s result, with material, thickness, optional colour, etc.
class AddFlashingParams {
  final String? id;
  final String material;
  final double thickness;
  final bool isUltra;
  final String? colorName;
  final Color? color;
  final List<FlashingItem> items;

  AddFlashingParams({
    this.id,
    required this.material,
    required this.thickness,
    this.isUltra = false,
    this.colorName,
    this.color,
    required this.items,
  });
}

/// Copy & paste this page into your routes.
class AddFlashingPage extends StatefulWidget {
  final bool isEditing;
  const AddFlashingPage({Key? key, this.isEditing = false}) : super(key: key);

  @override
  _AddFlashingPageState createState() => _AddFlashingPageState();
}

class _AddFlashingPageState extends State<AddFlashingPage> {
  // ← exact same colour map
  static const colorOptions = <String, Color>{
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
    'Night Sky': Color(0xFF141414),
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
  bool isUltra = false;

  final idCtrl = TextEditingController();
  final thicknessCtrl = TextEditingController(text: '0.55');
  final rows = <Map<String, TextEditingController>>[
    {
      'length': TextEditingController(text: ''),
      'count': TextEditingController(text: ''),
    }
  ];

  bool canAdd() {
    final thick = double.tryParse(thicknessCtrl.text);
    if (thick == null || thick <= 0) return false;
    if ((selectedMaterial == 'Aluminium' || selectedMaterial == 'Colorbond') &&
        selectedColorName == null) return false;
    for (var r in rows) {
      final len = int.tryParse(r['length']!.text);
      final cnt = int.tryParse(r['count']!.text);
      if (len == null || len <= 0) return false;
      if (cnt == null || cnt <= 0) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    const maxW = 500.0;
    final chipW = (maxW - (5 - 1) * 8) / 5;

    return Scaffold(
      // ——— Purple AppBar like AddOrderPage ———
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        title: Text(
          widget.isEditing ? 'EDIT FLASHING' : 'NEW FLASHING',
          style: const TextStyle(
            fontFamily: 'Kanit',
            color: Colors.white,
          ),
        ),
      ),

      // light grey background
      backgroundColor: Colors.grey.shade50,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 24),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 12),

                      // ——— ID field ———
                      TextField(
                        controller: idCtrl,
                        autofocus: widget.isEditing,
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

                      // ——— Material dropdown ———
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
                          switch (m) {
                            case 'Aluminium':
                              thicknessCtrl.text = '0.9';
                              break;
                            case 'Colorbond':
                              thicknessCtrl.text = '0.55';
                              break;
                            case 'Galvanised':
                              thicknessCtrl.text = '1.2';
                              break;
                            case 'Stainless Steel':
                              thicknessCtrl.text = '0.55';
                              break;
                          }
                        }),
                      ),
                      const SizedBox(height: 16),

                      // ——— Thickness ———
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

                      // ——— Colour selector ———
                      if (selectedMaterial == 'Aluminium' ||
                          selectedMaterial == 'Colorbond') ...[
                        const SizedBox(height: 16),
                        Text('SELECT COLOUR',
                            style: TextStyle(
                                fontFamily: 'Kanit', color: Colors.deepPurple)),
                        const SizedBox(height: 8),
                        Center(
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: colorOptions.entries.map((e) {
                              final sel = e.key == selectedColorName;
                              return GestureDetector(
                                onTap: () =>
                                    setState(() => selectedColorName = e.key),
                                child: Container(
                                  width: chipW,
                                  height: 45,
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
                                    e.key.toUpperCase(),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontFamily: 'Kanit',
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                      ],

                      // ——— Ultra checkbox ———
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
                      // ——— Lengths & counts ———
                      Text('LENGTHS & AMOUNT',
                          style: TextStyle(
                              fontFamily: 'Kanit', color: Colors.deepPurple)),
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
                                      fontFamily: 'Kanit', fontSize: 13),
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
                                  labelText: 'Qty',
                                  labelStyle: const TextStyle(
                                      fontFamily: 'Kanit', fontSize: 13),
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
                          label: const Text('Add Length',
                              style: TextStyle(
                                  fontFamily: 'Kanit',
                                  color: Colors.deepPurple)),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // ——— Cancel & ADD(EDIT) buttons like AddOrderPage ———
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(
                                fontFamily: 'Kanit',
                                color: Colors.redAccent,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                            ),
                            onPressed: canAdd()
                                ? () {
                                    final items = rows.map((r) {
                                      final len = int.parse(r['length']!.text);
                                      final cnt = int.parse(r['count']!.text);
                                      return FlashingItem(len, cnt);
                                    }).toList();
                                    Navigator.of(context).pop(
                                      AddFlashingParams(
                                        id: idCtrl.text.trim().isEmpty
                                            ? null
                                            : idCtrl.text.trim(),
                                        material: selectedMaterial,
                                        thickness:
                                            double.parse(thicknessCtrl.text),
                                        isUltra: isUltra,
                                        colorName: (selectedMaterial ==
                                                    'Aluminium' ||
                                                selectedMaterial == 'Colorbond')
                                            ? selectedColorName
                                            : null,
                                        color: (selectedMaterial ==
                                                    'Aluminium' ||
                                                selectedMaterial == 'Colorbond')
                                            ? colorOptions[selectedColorName]!
                                            : null,
                                        items: items,
                                      ),
                                    );
                                  }
                                : null,
                            child: Text(
                              widget.isEditing ? 'EDIT' : 'ADD',
                              style: const TextStyle(
                                fontFamily: 'Kanit',
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
