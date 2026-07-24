import 'llm_generation_config.dart';

abstract class LlmService {
  String get modelFamily => 'qwen';

  Future<void> initialize();

  Future<bool> isAvailable();

  Future<String> generateNpcReply({
    required String npcId,
    required String prompt,
    LlmGenerationConfig? config,
    void Function(String token)? onToken,
  });

  Future<String> generateEvidenceReaction({
    required String npcId,
    required String evidenceId,
    required String prompt,
    LlmGenerationConfig? config,
    void Function(String token)? onToken,
  });

  Future<void> dispose();
}
