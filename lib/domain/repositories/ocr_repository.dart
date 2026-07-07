import '../entities/image_source.dart';
import '../entities/ocr_extraction.dart';

abstract class OcrRepository {
  Future<bool> isAvailable();

  /// Extracts text from [source]. Throws [OcrException] on failure.
  Future<OcrExtraction> extractText(ImageSource source);
}
