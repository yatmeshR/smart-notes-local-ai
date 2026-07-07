import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/app_exceptions.dart';
import '../../domain/entities/image_source.dart';
import '../../domain/entities/ocr_extraction.dart';
import '../../domain/usecases/extract_text_from_image.dart';
import 'injection.dart';

enum OcrStatus { idle, extracting, done, error }

class OcrState {
  final OcrStatus status;
  final OcrExtraction? extraction;
  final String? errorMessage;

  const OcrState({
    this.status = OcrStatus.idle,
    this.extraction,
    this.errorMessage,
  });
}

class OcrNotifier extends StateNotifier<OcrState> {
  final ExtractTextFromImage _extractTextFromImage;

  OcrNotifier(this._extractTextFromImage) : super(const OcrState());

  Future<void> extractFromImage(ImageSource source) async {
    state = const OcrState(status: OcrStatus.extracting);
    try {
      final extraction = await _extractTextFromImage(source);
      state = OcrState(status: OcrStatus.done, extraction: extraction);
    } on OcrException catch (e) {
      state = OcrState(status: OcrStatus.error, errorMessage: e.message);
    } catch (e) {
      state = OcrState(status: OcrStatus.error, errorMessage: e.toString());
    }
  }

  void reset() => state = const OcrState();
}

final ocrNotifierProvider = StateNotifierProvider<OcrNotifier, OcrState>((ref) {
  return OcrNotifier(ref.watch(extractTextFromImageProvider));
});
