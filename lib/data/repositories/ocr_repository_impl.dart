import '../../domain/entities/image_source.dart';
import '../../domain/entities/ocr_extraction.dart';
import '../../domain/repositories/ocr_repository.dart';
import '../datasources/ocr_engine_datasource.dart';

class OcrRepositoryImpl implements OcrRepository {
  final OcrEngineDataSource _engine;

  const OcrRepositoryImpl(this._engine);

  @override
  Future<bool> isAvailable() => _engine.isAvailable();

  @override
  Future<OcrExtraction> extractText(ImageSource source) async {
    final text = await _engine.extractText(source);
    return OcrExtraction(text: text);
  }
}
