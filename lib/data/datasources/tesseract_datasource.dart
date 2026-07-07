import 'dart:io';
import 'package:path/path.dart' as p;
import '../../core/errors/app_exceptions.dart';

/// The only class in the entire app that knows Tesseract exists.
/// If you swapped this for ML Kit or a cloud OCR API later, this is the
/// one file you'd rewrite -- everything above it (repository, use case,
/// UI) is unaffected because they only know about [OcrRepository].
class TesseractDataSource {
  Future<bool> isAvailable() async {
    try {
      final result = await Process.run('tesseract', ['--version']);
      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  /// Runs `tesseract <input> <outputBase>`, which writes `<outputBase>.txt`.
  /// Returns the raw extracted text.
  Future<String> extractText(String imagePath) async {
    final inputFile = File(imagePath);
    if (!await inputFile.exists()) {
      throw OcrException('Image file not found: $imagePath');
    }

    final tempDir = await Directory.systemTemp.createTemp('smart_notes_ocr_');
    final outputBase = p.join(tempDir.path, 'output');
    final outputTxtPath = '$outputBase.txt';

    try {
      final result = await Process.run('tesseract', [imagePath, outputBase]);

      if (result.exitCode != 0) {
        throw OcrException('Tesseract exited with an error: ${result.stderr}');
      }

      final outputFile = File(outputTxtPath);
      if (!await outputFile.exists()) {
        throw const OcrException('Tesseract did not produce output text.');
      }

      return (await outputFile.readAsString()).trim();
    } on OcrException {
      rethrow;
    } catch (e) {
      throw OcrException('Failed to run OCR: $e');
    } finally {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    }
  }
}
