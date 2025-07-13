// lib/pdf_manager.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'dart:js_interop';
import 'package:provider/provider.dart';
import 'package:web/web.dart' as web;

import 'models/designer_model.dart';
import 'models/flashing.dart';

Future<Uint8List> _generatePdfIsolate(Map<String, dynamic> params) async {
  final images = (params['images'] as List).cast<Uint8List>();
  final tapered = (params['tapered'] as List).cast<Uint8List>();
  final pageFmt = PdfPageFormat(
    params['pageWidth'] as double,
    params['pageHeight'] as double,
  );
  final orderName = params['orderName'] as String;
  final orderDateStr = params['orderDate'] as String;
  final custName = params['customerName'] as String;
  final custAddr = params['customerAddress'] as String;
  final custPhone = params['customerPhone'] as String;
  final custEmail = params['customerEmail'] as String;
  // parse back to DateTime if you want formatting:
  DateTime? orderDate =
      orderDateStr.isNotEmpty ? DateTime.parse(orderDateStr).toLocal() : null;

  // choose a date format:
  final dateFormatter = DateFormat('MMM d y');
  final dateLine = orderDate != null ? dateFormatter.format(orderDate) : '';

  final doc = pw.Document();

  // Build flat list of entries: tapered pairs first, then singles
  final entries = <_Entry>[];
  for (var i = 0; i + 1 < tapered.length; i += 2) {
    entries.add(_Entry.pair(tapered[i], tapered[i + 1]));
  }
  for (final img in images) {
    entries.add(_Entry.single(img));
  }

  const double hGap = 20.0;
  const double vGap = 100.0;

  // Paginate 2 rows per page (4 slots)
  for (var pos = 0; pos < entries.length;) {
    // prepare four slots
    final pageCells = List<Uint8List?>.filled(4, null);
    var slot = 0;
    while (slot < 4 && pos < entries.length) {
      final e = entries[pos++];
      if (e.isPair) {
        // only place pairs at even slot (col 0)
        if (slot.isEven && slot + 1 < 4) {
          pageCells[slot] = e.near;
          pageCells[slot + 1] = e.far;
          slot += 2;
        } else {
          // move to next row start
          slot = ((slot ~/ 2) + 1) * 2;
        }
      } else {
        pageCells[slot] = e.single;
        slot += 1;
      }
    }

    doc.addPage(pw.Page(
      pageFormat: pageFmt,
      margin: const pw.EdgeInsets.only(left: 17.5),
      build: (context) => pw.LayoutBuilder(
        builder: (ctx, constraints) {
          final contentW = constraints?.maxWidth;
          final contentH = constraints?.maxHeight;
          final cellW = (contentW! - hGap) / 2;
          final cellH = (contentH! - 3 * vGap) / 2;

          return pw.Column(
            children: [
              pw.SizedBox(height: 20),
              pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // CUSTOMER INFO
                    pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            orderName.toUpperCase(),
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(
                              color: PdfColors.black,
                              fontSize: 14,
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                          if (custName.isNotEmpty)
                            pw.Text('Customer:  $custName',
                                textAlign: pw.TextAlign.center,
                                style: const pw.TextStyle(fontSize: 12)),
                          if (custAddr.isNotEmpty)
                            pw.Text('Address:    $custAddr',
                                textAlign: pw.TextAlign.center,
                                style: const pw.TextStyle(fontSize: 12)),
                          if (custPhone.isNotEmpty)
                            pw.Text('Phone:       $custPhone',
                                textAlign: pw.TextAlign.center,
                                style: const pw.TextStyle(fontSize: 12)),
                          if (custEmail.isNotEmpty)
                            pw.Text('Email:        $custEmail',
                                textAlign: pw.TextAlign.center,
                                style: const pw.TextStyle(fontSize: 12)),
                        ]),

                    pw.Spacer(),
                    if (dateLine.isNotEmpty)
                      pw.Text(
                        dateLine,
                        textAlign: pw.TextAlign.start,
                        style: const pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.grey700,
                        ),
                      ),

                    pw.SizedBox(
                      width: 17.5,
                    ),
                  ]),

              pw.SizedBox(height: 20),

              pw.SizedBox(height: vGap - 100),

              // first row
              pw.Row(children: [
                pw.Container(
                  width: cellW,
                  height: cellH,
                  child: pageCells[0] != null
                      ? pw.Image(pw.MemoryImage(pageCells[0]!),
                          fit: pw.BoxFit.contain)
                      : pw.SizedBox(),
                ),
                pw.SizedBox(width: hGap),
                pw.Container(
                  width: cellW,
                  height: cellH,
                  child: pageCells[1] != null
                      ? pw.Image(pw.MemoryImage(pageCells[1]!),
                          fit: pw.BoxFit.contain)
                      : pw.SizedBox(),
                ),
              ]),

              // middle gap
              pw.SizedBox(height: vGap),

              // second row
              pw.Row(children: [
                pw.Container(
                  width: cellW,
                  height: cellH,
                  child: pageCells[2] != null
                      ? pw.Image(pw.MemoryImage(pageCells[2]!),
                          fit: pw.BoxFit.contain)
                      : pw.SizedBox(),
                ),
                pw.SizedBox(width: hGap),
                pw.Container(
                  width: cellW,
                  height: cellH,
                  child: pageCells[3] != null
                      ? pw.Image(pw.MemoryImage(pageCells[3]!),
                          fit: pw.BoxFit.contain)
                      : pw.SizedBox(),
                ),
              ]),

              // bottom gap
              pw.SizedBox(height: vGap),
            ],
          );
        },
      ),
    ));
  }

  return doc.save();
}

/// Internal entry type: either one image (1 slot) or a tapered pair (2 slots).
class _Entry {
  final Uint8List? _single;
  final Uint8List? _near;
  final Uint8List? _far;

  bool get isSingle => _single != null;
  bool get isPair => _near != null && _far != null;

  Uint8List get single => _single!;
  Uint8List get near => _near!;
  Uint8List get far => _far!;

  _Entry.single(Uint8List bytes)
      : _single = bytes,
        _near = null,
        _far = null;

  _Entry.pair(Uint8List nearBytes, Uint8List farBytes)
      : _single = null,
        _near = nearBytes,
        _far = farBytes;
}

class PdfManager {
  PdfManager._();
  static final PdfManager _instance = PdfManager._();
  factory PdfManager() => _instance;

  Future<void> saveAndOpenPdf(BuildContext context) async {
    // 1) Gather images exactly as before
    final designer = Provider.of<DesignerModel>(context, listen: false);
    final List<Uint8List> images = [];
    final List<Uint8List> tapered = [];
    for (final f in designer.flashings) {
      if (f.tapered) {
        tapered.add(f.images[0]);
        tapered.add(f.images[1]);
      } else {
        images.add(f.images[0]);
      }
    }

    // 2) Generate PDF bytes (you can still use compute if it works on your web target)
    final bytes = await compute<Map<String, dynamic>, Uint8List>(
      _generatePdfIsolate,
      {
        'images': images,
        'tapered': tapered,
        'pageWidth': PdfPageFormat.a4.width,
        'pageHeight': PdfPageFormat.a4.height,
        'orderName': designer.currentOrderName ?? '',
        'orderDate': designer.currentOrderDate?.toIso8601String() ?? '',
        'customerName': designer.currentCustomerName ?? '',
        'customerAddress': designer.currentCustomerAddress ?? '',
        'customerEmail': designer.currentCustomerEmail ?? '',
        'customerPhone': designer.currentCustomerPhone ?? '',
      },
    );

    // 3) Create a PDF Blob and open it in a new tab
    final arrayBuffer = bytes.buffer.toJS;
    final blob = web.Blob(
      [arrayBuffer].toJS, // JSArray of JSAny
      web.BlobPropertyBag(type: 'application/pdf'),
    );
    final url = web.URL.createObjectURL(blob);
    web.window.open(url, '_blank');

    // 4) (Optional) clean up the object URL after a short delay
    //Future.delayed(const Duration(seconds: 5), () {
    // web.URL.revokeObjectURL(url);
    // });
  }
}
