import 'dart:io';
import 'package:flutter/material.dart';
import '../../app/game_provider.dart';
import '../../app/model_manager_provider.dart';
import '../../core/llm/llama_cpp_llm_service.dart';
import '../../core/model/model_manifest_entry.dart';
import '../../shared/widgets/empty_view.dart';
import '../../shared/widgets/instruction_banner.dart';
import '../../shared/widgets/loading_view.dart';

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
            return const LoadingView(message: 'マニフェスト読み込み中...');
          }
          if (snapshot.hasError) {
            return Center(child: Text('エラーが発生しました: ${snapshot.error}'));
          }

          final manifest = modelManager.manifest;
          if (manifest == null || manifest.models.isEmpty) {
            return const EmptyView(
              message: 'モデルが見つかりません。',
              icon: Icons.memory,
            );
          }

          final activeLlm = GameProvider.of(context).llmService;
          String engineStatus = '現在: MockLlmService (テスト用)';
          if (activeLlm is LlamaCppLlmService) {
            engineStatus = activeLlm.gpuStatusSummary;
          } else {
            final c = Platform.numberOfProcessors;
            final threads = (c * 0.75).round().clamp(2, 8);
            engineStatus = 'OS: ${Platform.operatingSystem} | Cores: $c | 推奨Threads: $threads | GPU Target: 99 layers';
          }

          return SafeArea(
            child: Column(
              children: [
                InstructionBanner(
                  text: '【LLM 動作ステータス】',
                  child: Column(
                    children: [
                      const Text(
                        '【LLM 動作ステータス】',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        engineStatus,
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
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
            ),
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
