import '../../domain/entities/image_source.dart';

abstract class OcrEngineDataSource {
  Future<bool> isAvailable();

  /// Returns raw extracted text. Throws [OcrException] on failure.
  Future<String> extractText(ImageSource source);
}
