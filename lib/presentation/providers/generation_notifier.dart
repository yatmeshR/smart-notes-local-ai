import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/errors/app_exceptions.dart';
import '../../domain/entities/prompt_mode.dart';
import '../../domain/usecases/build_prompt.dart';
import '../../domain/usecases/generate_text.dart';
import 'injection.dart';

enum GenerationStatus { idle, streaming, done, error }

class GenerationState {
  final GenerationStatus status;
  final String text;
  final String? errorMessage;

  const GenerationState({
    this.status = GenerationStatus.idle,
    this.text = '',
    this.errorMessage,
  });

  GenerationState copyWith({GenerationStatus? status, String? text}) {
    return GenerationState(
      status: status ?? this.status,
      text: text ?? this.text,
    );
  }
}

/// Depends only on [GenerateText] and [BuildPrompt] -- two use cases.
/// Has no idea Ollama exists, no idea HTTP is involved, no idea what the
/// streaming JSON format looks like. That knowledge is fully contained
/// in the data layer.
class GenerationNotifier extends StateNotifier<GenerationState> {
  final GenerateText _generateText;
  final BuildPrompt _buildPrompt;

  GenerationNotifier(this._generateText, this._buildPrompt)
      : super(const GenerationState());

  Future<void> run({
    required PromptMode mode,
    required String sourceText,
    String? question,
  }) async {
    final prompt = _buildPrompt(
      mode: mode,
      sourceText: sourceText,
      question: question,
    );

    state = const GenerationState(status: GenerationStatus.streaming);

    try {
      final buffer = StringBuffer();
      await for (final chunk in _generateText(prompt)) {
        buffer.write(chunk);
        state = state.copyWith(
          status: GenerationStatus.streaming,
          text: buffer.toString(),
        );
      }
      state = state.copyWith(status: GenerationStatus.done);
    } on LlmException catch (e) {
      state = GenerationState(
        status: GenerationStatus.error,
        errorMessage: e.message,
      );
    } catch (e) {
      state = GenerationState(
        status: GenerationStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  void reset() => state = const GenerationState();
}

final generationNotifierProvider =
    StateNotifierProvider<GenerationNotifier, GenerationState>((ref) {
  return GenerationNotifier(
    ref.watch(generateTextProvider),
    ref.watch(buildPromptProvider),
  );
});
