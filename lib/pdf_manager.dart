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

  /// Add a new flashing image.
  void addImage(Uint8List bytes) => _images.add(bytes);

  /// Clear all images.
  void reset() => _images.clear();

  /// Expose the current list of images (unmodifiable).
  List<Uint8List> get images => List.unmodifiable(_images);

  /// Remove the image at [index].
  void removeImageAt(int index) {
    _images.removeAt(index);
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
    final pdfBytes = await _generatePdfWithPdfLib(_images);

    // 3. Hide spinner
    if (context.mounted) Navigator.of(context, rootNavigator: true).pop();

    // 4. Trigger browser download
    _downloadPdfWeb(pdfBytes);
  }

  // ─── Web: build via pdf-lib + pure js_interop ───────────────────────────
  static Future<Uint8List> _generatePdfWithPdfLib(
      List<Uint8List> images) async {
    final pdfLib = _PDFLib(_pdfLibJs);
    final ns = pdfLib.PDFDocument;
    final doc = await ns.create().toDart;

    // A4 in points
    const pageW = 595.28;
    const pageH = 841.89;
    const padding = 20.0;

    for (final img in images) {
      final arr = img.toJS;
      final embedded = await doc.embedPng(arr).toDart;

      // Available area inside padding
      const availW = pageW - 2 * padding + 25;
      const availH = pageH - 2 * padding;

      // Compute aspect-fit inside availW/availH
      final iw = embedded.width;
      final ih = embedded.height;
      final ratio = iw / ih;
      double w, h;
      if (ratio >= 1) {
        w = availW;
        h = w / ratio;
        if (h > availH) {
          h = availH;
          w = h * ratio;
        }
      } else {
        h = availH;
        w = h * ratio;
        if (w > availW) {
          w = availW;
          h = w / ratio;
        }
      }

      // Create A4 page
      final page = doc.addPage(
        ([pageW, pageH] as List<JSAny?>).toJS,
      );

      // Center inside the padded box
      final cx = padding + (availW - w) / 2;
      final cy = padding + (availH - h) / 2;

      page.drawImage(
        embedded,
        DrawImageOptions(x: cx, y: cy, width: w, height: h),
      );
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

    final anchor = (web.document.createElement('a') as web.HTMLAnchorElement)
      ..href = url
      ..download = 'FlashingPDF-${DateTime.now().toLocal()}.pdf'
      ..style.display = 'none';
    web.document.body!.append(anchor);
    anchor.click();
    web.document.body!.removeChild(anchor);
    web.URL.revokeObjectURL(url);
  }
}
