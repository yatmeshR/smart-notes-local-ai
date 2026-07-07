/// Thrown when OCR extraction fails (Tesseract missing, bad image, etc).
class OcrException implements Exception {
  final String message;
  const OcrException(this.message);

  @override
  String toString() => message;
}

/// Thrown when the LLM request fails (Ollama unreachable, model not
/// pulled, bad response, etc).
class LlmException implements Exception {
  final String message;
  const LlmException(this.message);

  @override
  String toString() => message;
}
