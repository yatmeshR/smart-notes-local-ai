import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';

import '../../core/errors/app_exceptions.dart';
import '../../domain/entities/image_source.dart';
import 'ocr_engine_datasource.dart';

/// Calls the global `Tesseract.recognize(image, lang)` function exposed
/// by the tesseract.js <script> tag loaded in web/index.html.
/// Returns a JS Promise, which we convert to a Dart Future below.
@JS('Tesseract.recognize')
external JSPromise<JSObject> _tesseractRecognize(
  JSString imageDataUrl,
  JSString lang,
);

/// Web: runs Tesseract.js, a WASM port of Tesseract that executes
/// entirely client-side in the browser -- no server, no native binary.
/// This is real JS interop (calling into a <script>-loaded library),
/// distinct from the desktop/mobile engines in kind, not just platform.
class WebOcrDataSource implements OcrEngineDataSource {
  @override
  Future<bool> isAvailable() async {
    try {
      // True only if the tesseract.js script tag actually loaded.
      return globalContext.has('Tesseract');
    } catch (_) {
      return false;
    }
  }

  @override
  Future<String> extractText(ImageSource source) async {
    final bytes = source.bytes;
    if (bytes == null) {
      throw const OcrException('Web OCR requires image bytes.');
    }

    if (!await isAvailable()) {
      throw const OcrException(
        'Tesseract.js did not load. Check the <script> tag in '
        'web/index.html and your network connection.',
      );
    }

    // Tesseract.js accepts a data URL directly -- simplest way to hand
    // it an in-memory image without ever touching the filesystem.
    final dataUrl = 'data:image/png;base64,${base64Encode(bytes)}';

    try {
      final result = await _tesseractRecognize(dataUrl.toJS, 'eng'.toJS).toDart;
      final data = result.getProperty<JSObject>('data'.toJS);
      final text = data.getProperty<JSString>('text'.toJS).toDart;
      return text.trim();
    } catch (e) {
      throw OcrException('Tesseract.js failed: $e');
    }
  }
}
