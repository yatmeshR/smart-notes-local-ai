import 'dart:io' show Platform;
import 'desktop_ocr_datasource.dart';
import 'mobile_ocr_datasource.dart';
import 'ocr_engine_datasource.dart';

/// Used on any platform where dart:io is available (desktop + mobile).
/// Runtime check picks the actual engine, since Android/iOS and
/// Windows/macOS/Linux are both "io" platforms but need different OCR
/// engines.
OcrEngineDataSource createOcrEngine() {
  if (Platform.isAndroid || Platform.isIOS) {
    return MobileOcrDataSource();
  }
  return DesktopOcrDataSource();
}
