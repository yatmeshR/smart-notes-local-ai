import '../entities/prompt_mode.dart';

/// Pure business logic: turns (mode, source text, optional question) into
/// the actual prompt string sent to the LLM. This is exactly the kind of
/// logic that's easy to accidentally bury in a widget's build() method --
/// pulling it into a use case means it's testable with zero Flutter
/// dependency and reusable if you ever add a second UI (e.g. a CLI).
class BuildPrompt {
  const BuildPrompt();

  String call({
    required PromptMode mode,
    required String sourceText,
    String? question,
  }) {
    final source = sourceText.trim();

    switch (mode) {
      case PromptMode.summarize:
        return 'Summarize the following text in 3-5 concise bullet points:'
            '\n\n$source';
      case PromptMode.actionItems:
        return 'Extract a clear list of action items from the following '
            'text. If there are none, say so explicitly:\n\n$source';
      case PromptMode.ask:
        final q = (question ?? '').trim();
        return 'Based on the following text, answer this question: "$q"'
            '\n\nText:\n$source';
    }
  }
}
