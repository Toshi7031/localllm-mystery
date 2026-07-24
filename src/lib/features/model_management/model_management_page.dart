import 'package:flutter/material.dart';
import '../../app/model_manager_provider.dart';
import '../../core/model/model_manifest_entry.dart';

class ModelManagementPage extends StatelessWidget {
  const ModelManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final modelManager = ModelManagerProvider.read(context);

    return Scaffold(
      appBar: AppBar(title: const Text('モデル管理')),
      body: FutureBuilder(
        future: modelManager.loadManifest(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('エラーが発生しました: ${snapshot.error}'));
          }

          final manifest = modelManager.manifest;
          if (manifest == null || manifest.models.isEmpty) {
            return const Center(child: Text('モデルが見つかりません。'));
          }

          return Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12.0),
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                width: double.infinity,
                child: const Text(
                  '現在は開発用MockLlmServiceで動作しています。\nローカルGGUFモデル連携は後続実装予定です。',
                  style: TextStyle(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: manifest.models.length,
                  itemBuilder: (context, index) {
                    final modelEntry = manifest.models[index];
                    return _ModelListItem(modelEntry: modelEntry);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ModelListItem extends StatelessWidget {
  final ModelManifestEntry modelEntry;

  const _ModelListItem({required this.modelEntry});

  @override
  Widget build(BuildContext context) {
    final modelManager = ModelManagerProvider.read(context);
    final modelEntry = this.modelEntry;

    return ListenableBuilder(
      listenable: modelManager,
      builder: (context, child) {
        final isInstalled = modelManager.isModelInstalledSync(modelEntry.id);
        final isSelected = modelManager.selectedModelId == modelEntry.id;
        final isDownloading = modelManager.isDownloading(modelEntry.id);
        final progress = modelManager.getDownloadProgress(modelEntry.id);

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(modelEntry.displayName, style: Theme.of(context).textTheme.titleLarge),
                    if (isSelected) const Chip(label: Text('選択中'), backgroundColor: Colors.blue),
                  ],
                ),
                const SizedBox(height: 8),
                Text(modelEntry.description),
                const SizedBox(height: 8),
                Text('パラメータ: ${modelEntry.parameterSize} / 推奨メモリ: ${modelEntry.recommendedMemoryMb}MB'),
                const SizedBox(height: 16),
                if (isDownloading) ...[
                  LinearProgressIndicator(value: progress),
                  const SizedBox(height: 8),
                  Text('${(progress * 100).toStringAsFixed(1)}%'),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (!isInstalled && !isDownloading)
                      ElevatedButton.icon(
                        icon: const Icon(Icons.download),
                        label: const Text('ダウンロード'),
                        onPressed: () async {
                          try {
                            await modelManager.downloadModel(modelEntry.id);
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('ダウンロード失敗: $e')),
                              );
                            }
                          }
                        },
                      ),
                    if (isInstalled && !isDownloading)
                      TextButton.icon(
                        icon: const Icon(Icons.delete),
                        label: const Text('削除'),
                        onPressed: () async {
                          await modelManager.deleteModel(modelEntry.id);
                        },
                      ),
                    if (isInstalled && !isSelected && !isDownloading)
                      ElevatedButton(
                        onPressed: () async {
                          await modelManager.selectModel(modelEntry.id);
                        },
                        child: const Text('選択'),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
