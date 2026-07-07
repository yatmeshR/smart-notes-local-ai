import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/ocr_engine_datasource.dart';
import '../../data/datasources/ocr_engine_selector.dart';
import '../../data/datasources/ollama_datasource.dart';
import '../../data/repositories/llm_repository_impl.dart';
import '../../data/repositories/ocr_repository_impl.dart';
import '../../domain/repositories/llm_repository.dart';
import '../../domain/repositories/ocr_repository.dart';
import '../../domain/usecases/build_prompt.dart';
import '../../domain/usecases/extract_text_from_image.dart';
import '../../domain/usecases/generate_text.dart';
import 'settings_notifier.dart';

/// Composition root. Everything downstream depends only on the domain
/// interfaces/use cases below -- never on concrete datasources directly.

// ---- Data sources ----

/// createOcrEngine() resolves at COMPILE time to desktop/mobile/web via
/// the conditional export in ocr_engine_selector.dart.
final ocrEngineProvider = Provider<OcrEngineDataSource>((ref) {
  return createOcrEngine();
});

/// Ollama's base URL is user-configurable (see settings_notifier.dart),
/// since "localhost" only makes sense on desktop. Rebuilds automatically
/// whenever settings change, thanks to ref.watch.
final ollamaDataSourceProvider = Provider<OllamaDataSource>((ref) {
  final settings = ref.watch(settingsNotifierProvider);
  return OllamaDataSource(baseUrl: settings.ollamaBaseUrl);
});

// ---- Repositories (bound to their abstract domain type) ----

final ocrRepositoryProvider = Provider<OcrRepository>((ref) {
  return OcrRepositoryImpl(ref.watch(ocrEngineProvider));
});

final llmRepositoryProvider = Provider<LlmRepository>((ref) {
  return LlmRepositoryImpl(ref.watch(ollamaDataSourceProvider));
});

// ---- Use cases ----

final extractTextFromImageProvider = Provider<ExtractTextFromImage>((ref) {
  return ExtractTextFromImage(ref.watch(ocrRepositoryProvider));
});

final generateTextProvider = Provider<GenerateText>((ref) {
  return GenerateText(ref.watch(llmRepositoryProvider));
});

final buildPromptProvider = Provider<BuildPrompt>((ref) {
  return const BuildPrompt();
});

// ---- Availability checks ----

final ocrAvailableProvider = FutureProvider<bool>((ref) {
  return ref.watch(ocrRepositoryProvider).isAvailable();
});

final llmAvailableProvider = FutureProvider<bool>((ref) {
  return ref.watch(llmRepositoryProvider).isAvailable();
});
