import 'llm_generation_config.dart';

abstract class LlmService {
  Future<void> initialize();

  Future<bool> isAvailable();

  Future<String> generateNpcReply({
    required String npcId,
    required String prompt,
    LlmGenerationConfig? config,
  });

  Future<String> generateEvidenceReaction({
    required String npcId,
    required String evidenceId,
    required String prompt,
    LlmGenerationConfig? config,
  });

  Future<void> dispose();
}
