import 'package:flutter/material.dart';
import '../../app/game_provider.dart';
import '../../shared/widgets/main_layout.dart';
import '../case_intro/case_intro_page.dart';
import '../model_management/model_management_page.dart';

class TitlePage extends StatelessWidget {
  const TitlePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '嘘つきたちの港町',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                'ローカルAIで住人に聞き込み、雨夜の事件を解き明かせ。',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),
              ElevatedButton(
                onPressed: () async {
                  final controller = GameProvider.of(context);
                  // 既存のセーブデータがある場合は確認する（MVPではMemorySaveServiceだが、将来を見据えて）
                  // 簡易的に直接 CaseIntroPage に行く前に確認フローを入れる
                  final hasSave = await controller.saveService.load(controller.caseData.caseId) != null;
                  if (hasSave && context.mounted) {
                    final proceed = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('確認'),
                        content: const Text('既存のセーブデータがあります。最初からやり直しますか？'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: const Text('キャンセル'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: const Text('やり直す'),
                          ),
                        ],
                      ),
                    );
                    if (proceed != true) return;
                  }

                  await controller.startNewGame();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const CaseIntroPage()),
                    );
                  }
                },
                child: const Text('はじめから'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  final controller = GameProvider.of(context);
                  final state = await controller.saveService.load(controller.caseData.caseId);
                  if (state == null && context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('セーブデータがありません')),
                    );
                    return;
                  }
                  await controller.loadGame();
                  if (context.mounted) {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const MainLayout()),
                    );
                  }
                },
                child: const Text('つづきから'),
              ),
              const SizedBox(height: 32),
              TextButton.icon(
                icon: const Icon(Icons.settings),
                label: const Text('モデル管理'),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ModelManagementPage()),
                  );
                },
              ),
              const SizedBox(height: 40),
              const Text(
                '※現在、開発用MockLlmServiceを使用中です',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }
}
