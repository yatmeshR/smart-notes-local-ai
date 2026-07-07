import 'dart:io';
import 'package:path/path.dart' as p;
import '../../core/errors/app_exceptions.dart';
import '../../domain/entities/image_source.dart';
import 'ocr_engine_datasource.dart';

class DesktopOcrDataSource implements OcrEngineDataSource {
  @override
  Future<bool> isAvailable() async {
    try {
      final result = await Process.run('tesseract', ['--version']);
      return result.exitCode == 0;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<String> extractText(ImageSource source) async {
    final imagePath = source.path;
    if (imagePath == null) {
      throw const OcrException('Desktop OCR requires a file path.');
    }

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
