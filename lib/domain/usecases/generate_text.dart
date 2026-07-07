import '../repositories/llm_repository.dart';

/// Single-responsibility use case: "generate a streamed response for a
/// prompt." Kept separate from BuildPrompt so each use case does exactly
/// one thing and can be tested in isolation.
class GenerateText {
  final LlmRepository _repository;

  const GenerateText(this._repository);

  Stream<String> call(String prompt) {
    return _repository.generateStream(prompt);
  }
}
