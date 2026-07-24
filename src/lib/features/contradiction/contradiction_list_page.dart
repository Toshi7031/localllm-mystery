import 'package:flutter/material.dart';
import '../../app/game_provider.dart';
import '../../shared/widgets/empty_view.dart';

class ContradictionListPage extends StatelessWidget {
  const ContradictionListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = GameProvider.of(context);
    final state = controller.state!;
    final caseData = controller.caseData;

    final unlockedContradictionIds = state.unlockedContradictionIds.toList();

    return Scaffold(
      appBar: AppBar(title: Text('${caseData.title} - 矛盾一覧')),
      body: SafeArea(
        child: unlockedContradictionIds.isEmpty
            ? const EmptyView(
                message: 'まだ矛盾は見つかっていません。\n証拠を集め、関係者に突きつけてみましょう。',
                icon: Icons.warning_amber_rounded,
              )
            : ListView.builder(
                itemCount: unlockedContradictionIds.length,
                itemBuilder: (context, index) {
                  final cId = unlockedContradictionIds[index];
                  final contradiction = caseData.contradictions
                      .firstWhere((c) => c.id == cId);
                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            contradiction.title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(contradiction.description),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
