import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/errors/app_exceptions.dart';

/// The only class in the app that knows Ollama's API shape (endpoints,
/// JSON structure, streaming format). Swapping to OpenAI/Claude/another
/// local runtime later means rewriting this file only.
class OllamaDataSource {
  final String baseUrl;
  final String model;
  final http.Client _client;

  OllamaDataSource({
    this.baseUrl = 'http://localhost:11434',
    this.model = 'llama3.2',
    http.Client? client,
  }) : _client = client ?? http.Client();

  Future<bool> isAvailable() async {
    try {
      final response = await _client
          .get(Uri.parse('$baseUrl/api/tags'))
          .timeout(const Duration(seconds: 3));
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Streams raw text chunks from Ollama's /api/generate endpoint, which
  /// returns newline-delimited JSON objects like:
  ///   {"response":"Hello","done":false}
  Stream<String> generateStream(String prompt) async* {
    final request = http.Request('POST', Uri.parse('$baseUrl/api/generate'))
      ..headers['Content-Type'] = 'application/json'
      ..body = jsonEncode({'model': model, 'prompt': prompt, 'stream': true});

    final http.StreamedResponse streamedResponse;
    try {
      streamedResponse = await _client.send(request);
    } catch (e) {
      throw LlmException('Could not reach Ollama at $baseUrl: $e');
    }

    if (streamedResponse.statusCode != 200) {
      throw LlmException(
        'Ollama returned status ${streamedResponse.statusCode}. '
        'Is the model "$model" pulled? Try: ollama pull $model',
      );
    }

    final buffer = StringBuffer();

    await for (final bytes in streamedResponse.stream) {
      buffer.write(utf8.decode(bytes));
      final lines = buffer.toString().split('\n');

      buffer.clear();
      buffer.write(lines.removeLast()); // keep incomplete trailing line

      for (final line in lines) {
        if (line.trim().isEmpty) continue;
        final Map<String, dynamic> json;
        try {
          json = jsonDecode(line) as Map<String, dynamic>;
        } catch (e) {
          throw LlmException('Malformed response from Ollama: $e');
        }
        final chunk = json['response'] as String? ?? '';
        if (chunk.isNotEmpty) yield chunk;
        if (json['done'] == true) return;
      }
    }
  }
}
