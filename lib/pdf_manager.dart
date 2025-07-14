// lib/pdf_manager.dart
@JS()
library pdf_manager;

import 'dart:js_interop';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:provider/provider.dart';
import 'package:web/web.dart' as web;

import 'models/designer_model.dart';

// ─── bind the global PDFLib UMD object ────────────────────────────────────
@JS('PDFLib')
external JSObject get _pdfLibJs;

// ─── pdf-lib interop wrappers ────────────────────────────────────────────
extension type _PDFLib(JSObject ptr) implements JSObject {
  external PDFDocumentNamespaceJS get PDFDocument;
}

extension type PDFDocumentNamespaceJS(JSObject ptr) implements JSObject {
  external JSPromise<PDFDocumentJS> create();
}

extension type PDFDocumentJS(JSObject ptr) implements JSObject {
  external JSPromise<PDFImageJS> embedPng(JSUint8Array bytes);
  external JSPromise<PDFImageJS> embedJpg(JSUint8Array bytes);

  external PDFPageJS addPage(JSArray<JSAny?> size);
  external JSPromise<JSUint8Array> save();
}

extension type PDFPageJS(JSObject ptr) implements JSObject {
  external void drawImage(PDFImageJS image, DrawImageOptions opts);
  external void drawText(String text, DrawTextOptions opts);
  external double getWidth(); // ← add
  external double getHeight();
}

extension type PDFImageJS(JSObject ptr) implements JSObject {
  external double get width;
  external double get height;
}

// ─── object-literal for drawImage options ────────────────────────────────
extension type DrawImageOptions._(JSObject o) implements JSObject {
  external DrawImageOptions({
    double x,
    double y,
    double width,
    double height,
  });
}
extension type DrawTextOptions._(JSObject o) implements JSObject {
  external DrawTextOptions({
    double x,
    double y,
    double size,
  });
}

class PdfManager {
  PdfManager._();
  static final PdfManager _instance = PdfManager._();
  factory PdfManager() => _instance;

  // ─── Web: build via pdf-lib + pure js_interop ───────────────────────────
  static Future<Uint8List> _generatePdfWithPdfLib(
    List<Uint8List> images, // single flashings
    List<Uint8List> taperedImages, // [near0, far0, near1, far1, …]
    String orderName,
    DateTime? orderDate,
    String customerName,
    String customerAddress,
    String customerEmail,
    String customerPhone,
  ) async {
    // 1) bootstrap PDF-lib.js
    final pdfLib = _PDFLib(_pdfLibJs);
    final doc = await pdfLib.PDFDocument.create().toDart;

    // 2) page & margin constants
    const pageW = 595.28, pageH = 841.89; // A4 in points
    const outerPad = 20.0, innerPad = 10.0;
    const contentW = pageW - 2 * outerPad;
    const cellW = (contentW - innerPad) / 2;

    // 3) state that gets reinitialized on every page
    late double headerHeight;
    late double cellH;
    late List<List<bool>> occupancy;
    late PDFPageJS page;

    // 4) pre-format the date line
    final dateLine =
        (orderDate != null) ? DateFormat('MMM d, yyyy').format(orderDate) : '';

    // 5) helper to start a fresh page + draw header + compute heights
    void newPage() {
      // a) blank slate
      page = doc.addPage(([pageW, pageH] as List<JSAny?>).toJS);
      occupancy = [
        [false, false],
        [false, false],
      ];

      // b) draw header lines, tracking Y
      final topY = pageH - outerPad;
      double y = topY;

      // Order title + date
      page.drawText(
        orderName.toUpperCase(),
        DrawTextOptions(x: outerPad, y: y, size: 16),
      );
      page.drawText(
        dateLine,
        DrawTextOptions(
          x: pageW - outerPad - 100,
          y: y,
          size: 12,
        ),
      );
      y -= 18;

      // Customer info
      if (customerName.isNotEmpty) {
        page.drawText(
          'Customer: $customerName',
          DrawTextOptions(x: outerPad, y: y, size: 12),
        );
        y -= 15;
      }
      if (customerAddress.isNotEmpty) {
        page.drawText(
          'Address:  $customerAddress',
          DrawTextOptions(x: outerPad, y: y, size: 12),
        );
        y -= 15;
      }
      if (customerPhone.isNotEmpty) {
        page.drawText(
          'Phone:    $customerPhone',
          DrawTextOptions(x: outerPad, y: y, size: 12),
        );
        y -= 15;
      }
      if (customerEmail.isNotEmpty) {
        page.drawText(
          'Email:    $customerEmail',
          DrawTextOptions(x: outerPad, y: y, size: 12),
        );
        y -= 15;
      }

      // c) compute how tall header+gap actually was
      headerHeight = (topY - y) + innerPad;

      // d) recompute cellH for two rows in the remaining vertical space
      final availableH = (pageH - 2 * outerPad) - headerHeight;
      cellH = (availableH - innerPad) / 2;
    }

    // 6) helpers to position each grid cell
    double cellX(int col) => outerPad + col * (cellW + innerPad);

    double cellY(int row) =>
        pageH - outerPad - headerHeight - (row + 1) * cellH - row * innerPad;

    // 7) draw a single image into a given cell
    Future<void> draw(Uint8List bytes, int row, int col) async {
      final img = await doc.embedPng(bytes.toJS).toDart;
      final ratio = img.width / img.height;

      double w = cellW, h = w / ratio;
      if (h > cellH) {
        h = cellH;
        w = h * ratio;
      }

      final dx = cellX(col) + (cellW - w) / 2;
      final dy = cellY(row) + (cellH - h) / 2;

      page.drawImage(
        img,
        DrawImageOptions(x: dx, y: dy, width: w, height: h),
      );
    }

    // 8) now tile your images across pages
    newPage();
    int singleIdx = 0, taperedIdx = 0;

    while (singleIdx < images.length || taperedIdx + 1 < taperedImages.length) {
      // if full, start a fresh page
      if (!occupancy.any((r) => r.contains(false))) {
        newPage();
      }

      // try a tapered pair
      if (taperedIdx + 1 < taperedImages.length) {
        final r = occupancy.indexWhere((row) => !row[0] && !row[1]);
        if (r >= 0) {
          await draw(taperedImages[taperedIdx], r, 0);
          await draw(taperedImages[taperedIdx + 1], r, 1);
          occupancy[r][0] = occupancy[r][1] = true;
          taperedIdx += 2;
          continue;
        }
      }

      // else place a single
      if (singleIdx < images.length) {
        outer:
        for (var r = 0; r < 2; r++) {
          for (var c = 0; c < 2; c++) {
            if (!occupancy[r][c]) {
              await draw(images[singleIdx++], r, c);
              occupancy[r][c] = true;
              break outer;
            }
          }
        }
        continue;
      }

      // nothing left
      break;
    }

    // 9) finish & return
    final jsBuf = await doc.save().toDart;
    return jsBuf.toDart;
  }

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

    // 2) Generate PDF bytes
    final bytes = await _generatePdfWithPdfLib(
        images,
        tapered,
        designer.currentOrderName ?? '',
        designer.currentOrderDate!,
        designer.currentCustomerName ?? '',
        designer.currentCustomerAddress ?? '',
        designer.currentCustomerEmail ?? '',
        designer.currentCustomerPhone ?? '');

    // 3) Create a PDF Blob and object URL
    final arrayBuffer = bytes.buffer.toJS;
    final blob = web.Blob(
      [arrayBuffer].toJS,
      web.BlobPropertyBag(type: 'application/pdf'),
    );
    final url = web.URL.createObjectURL(blob);

    // 4) Open in new tab
    web.window.open(url, '_blank');

    // 5) Trigger download
    final anchor = web.document.createElement('a') as web.HTMLAnchorElement;
    anchor.href = url;
    anchor.download = 'flashings.pdf';
    // Must add to DOM for click() to work in some browsers
    web.document.body!.append(anchor);
    anchor.click();
    anchor.remove();

    // 6) Clean up the object URL after a short delay
    Future.delayed(const Duration(seconds: 5), () {
      web.URL.revokeObjectURL(url);
    });
  }
}
