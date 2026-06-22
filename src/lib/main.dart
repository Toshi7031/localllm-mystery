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

  final modelManager = ModelManager(downloadService: LocalModelDownloadService());
  await modelManager.loadManifest();

  final saveService = MemorySaveService();
  
  // 初期LlmServiceの決定
  LlmService llmService;
  final installedModels = await modelManager.getInstalledModels();
  final selectedModel = installedModels.where((m) => m.modelId == modelManager.selectedModelId).firstOrNull;
  
  if (selectedModel != null) {
    llmService = LlamaCppLlmService(modelPath: selectedModel.filePath);
  } else {
    llmService = MockLlmService();
  }
  await llmService.initialize();

  final gameController = GameController(
    saveService: saveService,
    llmService: llmService,
    caseData: caseData,
  );

  // モデルの選択状態が変更されたらLLMサービスを切り替える
  modelManager.addListener(() async {
    final currentModels = await modelManager.getInstalledModels();
    final newSelected = currentModels.where((m) => m.modelId == modelManager.selectedModelId).firstOrNull;
    
    // すでに同じパスで初期化済みなら何もしない（厳密な比較は省略し、再生成する）
    LlmService newService;
    if (newSelected != null) {
      newService = LlamaCppLlmService(modelPath: newSelected.filePath);
    } else {
      newService = MockLlmService();
    }
    await newService.initialize();
    
    // 古いサービスを破棄
    gameController.setLlmService(newService);
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
