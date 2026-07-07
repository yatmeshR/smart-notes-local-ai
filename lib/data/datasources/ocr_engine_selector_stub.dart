import 'ocr_engine_datasource.dart';
import 'web_ocr_datasource.dart';

/// Used when dart:io is unavailable -- i.e. web. Backed by a real engine
/// (Tesseract.js via JS interop) rather than an "unsupported" stub, since
/// web OCR is fully supported this way.
OcrEngineDataSource createOcrEngine() {
  return WebOcrDataSource();
}
