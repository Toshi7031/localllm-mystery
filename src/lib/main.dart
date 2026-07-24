import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'app/app.dart';
import 'app/game_provider.dart';
import 'app/model_manager_provider.dart';
import 'core/llm/mock_llm_service.dart';
import 'core/llm/llama_cpp_llm_service.dart';
import 'core/llm/llm_service.dart';
import 'core/model/local_model_download_service.dart';
import 'core/model/model_manager.dart';
import 'core/storage/asset_case_loader.dart';
import 'core/storage/save_service.dart';
import 'game/game_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final loader = AssetCaseLoader();
  final caseData = await loader.loadCase('case_001');

  final downloadService = LocalModelDownloadService();
  await downloadService.initialize();
  final modelManager = ModelManager(downloadService: downloadService);
  await modelManager.loadManifest();

  final saveService = MemorySaveService();
  
  // 初期LlmServiceの決定
  LlmService llmService;
  final installedModels = await modelManager.getInstalledModels();
  final selectedModel = installedModels.where((m) => m.modelId == modelManager.selectedModelId).firstOrNull;
  
  if (selectedModel != null) {
    final manifestEntry = modelManager.manifest?.models.where((m) => m.id == selectedModel.modelId).firstOrNull;
    final modelFamily = manifestEntry?.family ?? 'qwen';
    llmService = LlamaCppLlmService(modelPath: selectedModel.filePath, modelFamily: modelFamily);
  } else {
    llmService = MockLlmService();
  }
  await llmService.initialize();

  final gameController = GameController(
    saveService: saveService,
    llmService: llmService,
    caseData: caseData,
  );

  // 現在初期化されているモデルのIDを保持（MockLlmServiceの場合はnull）
  String? currentModelId = selectedModel?.modelId;

  // モデルの選択状態が変更されたらLLMサービスを切り替える
  modelManager.addListener(() async {
    final currentModels = await modelManager.getInstalledModels();
    final newSelected = currentModels.where((m) => m.modelId == modelManager.selectedModelId).firstOrNull;
    final newModelId = newSelected?.modelId;
    
    // 選択モデルIDが変わっていない場合は何もしない（進捗更新時のnotifyによる再生成を避ける）
    if (newModelId == currentModelId) {
      return;
    }
    
    currentModelId = newModelId;
    developer.log('Switching LLM service to model ID: $newModelId', name: 'main');
    
    LlmService newService;
    if (newSelected != null) {
      final manifestEntry = modelManager.manifest?.models.where((m) => m.id == newSelected.modelId).firstOrNull;
      final modelFamily = manifestEntry?.family ?? 'qwen';
      newService = LlamaCppLlmService(modelPath: newSelected.filePath, modelFamily: modelFamily);
    } else {
      newService = MockLlmService();
    }
    
    try {
      await newService.initialize();
      final oldService = gameController.llmService;
      gameController.setLlmService(newService);
      await oldService.dispose();
      developer.log('Successfully switched to new LLM service.', name: 'main');
    } catch (e) {
      developer.log('Failed to initialize new LLM service: $e', name: 'main', error: e);
      // 初期化に失敗した場合は Mock にフォールバックする
      if (newService is! MockLlmService) {
        developer.log('Falling back to MockLlmService due to initialization failure.', name: 'main');
        final fallbackService = MockLlmService();
        await fallbackService.initialize();
        final oldService = gameController.llmService;
        gameController.setLlmService(fallbackService);
        await oldService.dispose();
        currentModelId = null;
      }
    }
  });

  runApp(
    ModelManagerProvider(
      manager: modelManager,
      child: GameProvider(
        controller: gameController,
        child: const MysteryApp(),
      ),
    ),
  );
}
