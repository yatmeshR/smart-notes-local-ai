/// Contract for LLM text generation. Swapping Ollama for OpenAI/Claude/
/// any other provider later means writing a new implementation of this
/// interface -- nothing in domain or presentation needs to change.
abstract class LlmRepository {
  /// Whether the underlying LLM service is reachable right now.
  Future<bool> isAvailable();

  /// Streams a generated response for [prompt], chunk by chunk.
  /// Throws [LlmException] on failure.
  Stream<String> generateStream(String prompt);
}
