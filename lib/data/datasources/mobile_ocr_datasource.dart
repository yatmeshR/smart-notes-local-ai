import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../../core/errors/app_exceptions.dart';
import '../../domain/entities/image_source.dart';
import 'ocr_engine_datasource.dart';

class MobileOcrDataSource implements OcrEngineDataSource {
  final TextRecognizer _recognizer =
      TextRecognizer(script: TextRecognitionScript.latin);

  @override
  Future<bool> isAvailable() async => true;

  @override
  Future<String> extractText(ImageSource source) async {
    final imagePath = source.path;
    if (imagePath == null) {
      throw const OcrException('Mobile OCR requires a file path.');
    }
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await _recognizer.processImage(inputImage);
      return recognizedText.text.trim();
    } catch (e) {
      throw OcrException('ML Kit text recognition failed: $e');
    }
  }

  void dispose() => _recognizer.close();
}
