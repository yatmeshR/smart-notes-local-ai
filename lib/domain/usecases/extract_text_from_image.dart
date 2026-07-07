import '../entities/image_source.dart';
import '../entities/ocr_extraction.dart';
import '../repositories/ocr_repository.dart';

class ExtractTextFromImage {
  final OcrRepository _repository;

  const ExtractTextFromImage(this._repository);

  Future<OcrExtraction> call(ImageSource source) {
    return _repository.extractText(source);
  }
}
