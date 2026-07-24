import 'package:flutter/material.dart';
import 'app/app.dart';
import 'app/game_provider.dart';
import 'app/model_manager_provider.dart';
import 'core/llm/llm_service_resolver.dart';
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
  
  final llmService = await LlmServiceResolver.createAndInitialize(modelManager);

  final gameController = GameController(
    saveService: saveService,
    llmService: llmService,
    caseData: caseData,
  );

  String? currentModelId = modelManager.selectedModelId;

  // モデルの選択状態が変更されたらLLMサービスを切り替える
  modelManager.addListener(() async {
    final newSelectedId = modelManager.selectedModelId;
    
    // 選択モデルIDが変わっていない場合は何もしない
    if (newSelectedId == currentModelId) {
      return;
    }
    
    currentModelId = newSelectedId;
    final newService = await LlmServiceResolver.switchService(
      modelManager: modelManager,
      currentService: gameController.llmService,
    );
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
