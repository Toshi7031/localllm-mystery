import 'package:flutter_test/flutter_test.dart';

import 'package:src/core/model/model_download_service.dart';
import 'package:src/core/model/model_manager.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ModelManager', () {
    late ModelManager modelManager;

    setUp(() {
      modelManager = ModelManager(downloadService: MockModelDownloadService());
    });

    test('loadManifest loads from json and sets default model', () async {
      await modelManager.loadManifest();
      
      expect(modelManager.manifest, isNotNull);
      expect(modelManager.manifest!.models.isNotEmpty, true);
      expect(modelManager.selectedModelId, modelManager.manifest!.defaultModelId);
    });

    test('downloadModel adds to installedModels', () async {
      await modelManager.loadManifest();
      final targetModelId = modelManager.manifest!.models.first.id;

      await modelManager.downloadModel(targetModelId);

      final isInstalled = await modelManager.isModelInstalled(targetModelId);
      expect(isInstalled, true);

      final installed = await modelManager.getInstalledModels();
      expect(installed.length, 1);
      expect(installed.first.modelId, targetModelId);
    });

    test('selectModel changes selectedModelId', () async {
      await modelManager.loadManifest();
      final targetModelId = modelManager.manifest!.models.first.id;

      await modelManager.selectModel(targetModelId);
      expect(modelManager.selectedModelId, targetModelId);
    });

    test('deleteModel removes from installedModels', () async {
      await modelManager.loadManifest();
      final targetModelId = modelManager.manifest!.models.first.id;

      await modelManager.downloadModel(targetModelId);
      expect(await modelManager.isModelInstalled(targetModelId), true);

      await modelManager.deleteModel(targetModelId);
      expect(await modelManager.isModelInstalled(targetModelId), false);
    });
  });
}
