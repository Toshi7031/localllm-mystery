import 'package:flutter/material.dart';
import '../../app/model_manager_provider.dart';
import '../../core/model/model_manifest_entry.dart';

class ModelManagementPage extends StatelessWidget {
  const ModelManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    final modelManager = ModelManagerProvider.of(context);

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

class _ModelListItem extends StatefulWidget {
  final ModelManifestEntry modelEntry;

  const _ModelListItem({required this.modelEntry});

  @override
  State<_ModelListItem> createState() => _ModelListItemState();
}

class _ModelListItemState extends State<_ModelListItem> {
  bool _isDownloading = false;
  double _progress = 0.0;

  @override
  Widget build(BuildContext context) {
    final modelManager = ModelManagerProvider.of(context);
    final modelEntry = widget.modelEntry;

    return FutureBuilder<bool>(
      future: modelManager.isModelInstalled(modelEntry.id),
      builder: (context, isInstalledSnapshot) {
        final isInstalled = isInstalledSnapshot.data ?? false;
        final isSelected = modelManager.selectedModelId == modelEntry.id;

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
                if (_isDownloading) ...[
                  LinearProgressIndicator(value: _progress),
                  const SizedBox(height: 8),
                  Text('${(_progress * 100).toStringAsFixed(1)}%'),
                ],
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (!isInstalled && !_isDownloading)
                      ElevatedButton.icon(
                        icon: const Icon(Icons.download),
                        label: const Text('ダウンロード'),
                        onPressed: () async {
                          setState(() {
                            _isDownloading = true;
                            _progress = 0.0;
                          });
                          try {
                            await modelManager.downloadModel(
                              modelEntry.id,
                              onProgress: (p) {
                                if (mounted) {
                                  setState(() {
                                    _progress = p;
                                  });
                                }
                              },
                            );
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('ダウンロード失敗: $e')),
                              );
                            }
                          } finally {
                            if (mounted) {
                              setState(() {
                                _isDownloading = false;
                              });
                            }
                          }
                        },
                      ),
                    if (isInstalled && !_isDownloading)
                      TextButton.icon(
                        icon: const Icon(Icons.delete),
                        label: const Text('削除'),
                        onPressed: () async {
                          await modelManager.deleteModel(modelEntry.id);
                        },
                      ),
                    if (isInstalled && !isSelected && !_isDownloading)
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
