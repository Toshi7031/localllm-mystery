import 'llm_generation_config.dart';
import 'llm_service.dart';

class MockLlmService implements LlmService {
  @override
  Future<void> initialize() async {
    // 開発用モックのため何もしない
  }

  @override
  Future<bool> isAvailable() async {
    return true;
  }

  @override
  Future<String> generateNpcReply({
    required String npcId,
    required String prompt,
    LlmGenerationConfig? config,
  }) async {
    // 擬似的な遅延
    await Future.delayed(const Duration(milliseconds: 500));
    return '[Mock] それについてはよくわかりません。';
  }

  @override
  Future<String> generateEvidenceReaction({
    required String npcId,
    required String evidenceId,
    required String prompt,
    LlmGenerationConfig? config,
  }) async {
    // 擬似的な遅延
    await Future.delayed(const Duration(milliseconds: 500));
    return '[Mock] その証拠($evidenceId)は初めて見ました。';
  }

  @override
  Future<void> dispose() async {
    // 何もしない
  }
}
