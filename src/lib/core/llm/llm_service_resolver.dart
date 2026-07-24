import 'dart:developer' as developer;
import '../model/model_manager.dart';
import 'llama_cpp_llm_service.dart';
import 'llm_service.dart';
import 'mock_llm_service.dart';

/// インストール済みモデル情報やManifestに基づき、
/// 適切な [LlmService] の初期化・切替・フォールバック処理を担うリゾルバクラス。
class LlmServiceResolver {
  /// 現在選択されているモデルから適切な [LlmService] を非同期で生成・初期化します。
  static Future<LlmService> createAndInitialize(ModelManager modelManager) async {
    final installedModels = await modelManager.getInstalledModels();
    final selectedModel = installedModels
        .where((m) => m.modelId == modelManager.selectedModelId)
        .firstOrNull;

    LlmService service;
    if (selectedModel != null) {
      final manifestEntry = modelManager.manifest?.models
          .where((m) => m.id == selectedModel.modelId)
          .firstOrNull;
      final modelFamily = manifestEntry?.family ?? 'qwen';
      service = LlamaCppLlmService(
        modelPath: selectedModel.filePath,
        modelFamily: modelFamily,
      );
    } else {
      service = MockLlmService();
    }

    await service.initialize();
    return service;
  }

  /// モデル選択が変更された際のLLMサービスの安全な切り替え処理を行います。
  /// 切替失敗時には自動的に [MockLlmService] へフォールバックします。
  static Future<LlmService> switchService({
    required ModelManager modelManager,
    required LlmService currentService,
  }) async {
    final currentModels = await modelManager.getInstalledModels();
    final newSelected = currentModels
        .where((m) => m.modelId == modelManager.selectedModelId)
        .firstOrNull;
    final newModelId = newSelected?.modelId;

    developer.log('Switching LLM service to model ID: $newModelId', name: 'LlmServiceResolver');

    LlmService newService;
    if (newSelected != null) {
      final manifestEntry = modelManager.manifest?.models
          .where((m) => m.id == newSelected.modelId)
          .firstOrNull;
      final modelFamily = manifestEntry?.family ?? 'qwen';
      newService = LlamaCppLlmService(
        modelPath: newSelected.filePath,
        modelFamily: modelFamily,
      );
    } else {
      newService = MockLlmService();
    }

    try {
      await newService.initialize();
      await currentService.dispose();
      developer.log('Successfully switched to new LLM service.', name: 'LlmServiceResolver');
      return newService;
    } catch (e, st) {
      developer.log('Failed to initialize new LLM service: $e', name: 'LlmServiceResolver', error: e, stackTrace: st);
      if (newService is! MockLlmService) {
        developer.log('Falling back to MockLlmService due to initialization failure.', name: 'LlmServiceResolver');
        final fallbackService = MockLlmService();
        await fallbackService.initialize();
        await currentService.dispose();
        return fallbackService;
      }
      return currentService;
    }
  }
}
