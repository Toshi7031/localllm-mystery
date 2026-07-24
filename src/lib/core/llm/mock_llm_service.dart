import 'llm_generation_config.dart';
import 'llm_service.dart';

class MockLlmService implements LlmService {
  @override
  String get modelFamily => 'qwen';

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
    void Function(String token)? onToken,
  }) async {
    final mockText = '<think>\nこれはモックの思考プロセスです。\n色々考えています...\n</think>\n[Mock] それについてはよくわかりません。';
    
    for (int i = 0; i < mockText.length; i++) {
      await Future.delayed(const Duration(milliseconds: 20));
      onToken?.call(mockText[i]);
    }
    
    return mockText;
  }

  @override
  Future<String> generateEvidenceReaction({
    required String npcId,
    required String evidenceId,
    required String prompt,
    LlmGenerationConfig? config,
    void Function(String token)? onToken,
  }) async {
    final mockText = '<think>\n証拠$evidenceIdについての思考...\n</think>\n[Mock] その証拠($evidenceId)は初めて見ました。';
    
    for (int i = 0; i < mockText.length; i++) {
      await Future.delayed(const Duration(milliseconds: 20));
      onToken?.call(mockText[i]);
    }
    
    return mockText;
  }

  @override
  Future<void> dispose() async {
    // 何もしない
  }
}
