@JS()
library pdf_manager;

import 'dart:js_interop';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

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

// ─── PdfManager (Web-only) ────────────────────────────────────────────────
class PdfManager {
  PdfManager._();
  static final PdfManager _instance = PdfManager._();
  factory PdfManager() => _instance;

  final List<Uint8List> _images = [];
  final List<Uint8List> _taperedImages = [];

  /// Add a new flashing image.
  void addImage(Uint8List bytes) => _images.add(bytes);

  /// Add a new tapered flashing image.
  void addTaperedImage(Uint8List bytes) => _taperedImages.add(bytes);

  /// Clear all images.
  void reset() {
    _images.clear();
    _taperedImages.clear();
  }

  /// Expose the current list of images (unmodifiable).
  List<Uint8List> get images => List.unmodifiable(_images);
  List<Uint8List> get taperedImages => List.unmodifiable(_taperedImages);

  /// Remove the image at [index].
  void removeImageAt(int index) {
    _images.removeAt(index);
  }

  void removeTaperedImageAt(int index) {
    taperedImages.removeAt(index);
  }

  void removeTaperedPairAt(int pairIdx) {
    // remove far first, then near
    _taperedImages.removeRange(pairIdx * 2, pairIdx * 2 + 2);
  }

  /// Show spinner, build PDF with pdf-lib, then download.
  Future<void> saveAndDownload(BuildContext context) async {
    // 1. Spinner
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    // 2. Build PDF via pdf-lib
    final pdfBytes = await _generatePdfWithPdfLib(_images, taperedImages);

    // 3. Hide spinner
    if (context.mounted) Navigator.of(context, rootNavigator: true).pop();

    // 4. Trigger browser download
    _downloadPdfWeb(pdfBytes);
  }

  // ─── Web: build via pdf-lib + pure js_interop ───────────────────────────
  static Future<Uint8List> _generatePdfWithPdfLib(
    List<Uint8List> images, // single flashings
    List<Uint8List> taperedImages, // [near0, far0, near1, far1, …]
  ) async {
    final pdfLib = _PDFLib(_pdfLibJs);
    final ns = pdfLib.PDFDocument;
    final doc = await ns.create().toDart;

    // A4 in points
    const pageW = 595.28, pageH = 841.89;
    const outerPad = 20.0, innerPad = 10.0;
    const contentW = pageW - 2 * outerPad, contentH = pageH - 2 * outerPad;
    const cellW = (contentW - innerPad) / 2, cellH = (contentH - innerPad) / 2;

    late List<List<bool>> occupancy;
    late var page; // JS proxy for the current page

    void newPage() {
      page = doc.addPage(([pageW, pageH] as List<JSAny?>).toJS);
      occupancy = [
        [false, false],
        [false, false],
      ];
    }

    double cellX(int col) => outerPad + col * (cellW + innerPad);
    double cellY(int row) =>
        pageH - outerPad - cellH - row * (cellH + innerPad);

    Future<void> draw(Uint8List bytes, int row, int col) async {
      final img = await doc.embedPng(bytes.toJS).toDart;
      final ratio = img.width / img.height;
      double w = cellW, h = w / ratio;
      if (h > cellH) {
        h = cellH;
        w = h * ratio;
      }
      final x = cellX(col) + (cellW - w) / 2;
      final y = cellY(row) + (cellH - h) / 2;
      page.drawImage(img, DrawImageOptions(x: x, y: y, width: w, height: h));
    }

    newPage();
    var singleIdx = 0;
    var taperedIdx = 0; // advance by 2 for each pair

    while (singleIdx < images.length || taperedIdx + 1 < taperedImages.length) {
      // page full? start a new one
      if (!occupancy.any((row) => row.contains(false))) {
        newPage();
      }

      // try to place a tapered pair
      if (taperedIdx + 1 < taperedImages.length) {
        final row = occupancy.indexWhere((r) => !r[0] && !r[1]);
        if (row >= 0) {
          await draw(taperedImages[taperedIdx], row, 0);
          await draw(taperedImages[taperedIdx + 1], row, 1);
          occupancy[row][0] = occupancy[row][1] = true;
          taperedIdx += 2;
          continue;
        }
      }

      // otherwise place a single
      if (singleIdx < images.length) {
        for (var r = 0; r < 2; r++) {
          for (var c = 0; c < 2; c++) {
            if (!occupancy[r][c]) {
              await draw(images[singleIdx++], r, c);
              occupancy[r][c] = true;
              r = 2; // break outer loop
              break;
            }
          }
        }
        continue;
      }

      // nothing left that fits
      break;
    }

    final buf = await doc.save().toDart;
    return buf.toDart;
  }

  // ─── Browser download helper (package:web) ─────────────────────────────
  void _downloadPdfWeb(Uint8List bytes) {
    final arrayBuf = bytes.buffer.toJS;
    final parts = [arrayBuf].toJS as JSArray<web.BlobPart>;
    final blob = web.Blob(parts, web.BlobPropertyBag(type: 'application/pdf'));
    final url = web.URL.createObjectURL(blob);
    // final anchor = (web.document.createElement('a') as web.HTMLAnchorElement)
    //..href = url
    // ..download = 'FlashingPDF-${DateTime.now().toLocal()}.pdf'
    // ..style.display = 'none';
    //  web.document.body!.append(anchor);
    //  anchor.click();
    // web.document.body!.removeChild(anchor);
    web.window.open(url, '_blank');

    // web.URL.revokeObjectURL(url);
  }
}
