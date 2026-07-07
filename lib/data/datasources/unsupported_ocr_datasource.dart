import '../../core/errors/app_exceptions.dart';
import '../../domain/entities/image_source.dart';
import 'ocr_engine_datasource.dart';

/// Web: no on-device OCR engine is available (no Tesseract binary, no
/// ML Kit). Rather than crash or silently no-op, this reports itself as
/// unavailable so the UI can show a clear "OCR isn't supported in the
/// browser" message -- consistent with how we handle Ollama being down.
class UnsupportedOcrDataSource implements OcrEngineDataSource {
  @override
  Future<bool> isAvailable() async => false;

  @override
  Future<String> extractText(ImageSource source) async {
    throw const OcrException(
      'OCR is not supported in the browser. Use the desktop or mobile app '
      'to scan images, or paste text directly.',
    );
  }
}
