import '../../domain/repositories/llm_repository.dart';
import '../datasources/ollama_datasource.dart';

/// Implements the domain's [LlmRepository] contract using Ollama.
class LlmRepositoryImpl implements LlmRepository {
  final OllamaDataSource _dataSource;

  const LlmRepositoryImpl(this._dataSource);

  @override
  Future<bool> isAvailable() => _dataSource.isAvailable();

  @override
  Stream<String> generateStream(String prompt) => _dataSource.generateStream(prompt);
}
