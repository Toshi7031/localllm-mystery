import 'package:flutter/material.dart';
import '../../app/game_provider.dart';
import 'evidence_detail_page.dart';

class EvidenceListPage extends StatelessWidget {
  const EvidenceListPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = GameProvider.of(context);
    final state = controller.state!;
    final caseData = controller.caseData;

    final evidenceIds = state.discoveredEvidenceIds.toList();

    return Scaffold(
      appBar: AppBar(title: Text('${caseData.title} - 証拠一覧')),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12.0),
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              width: double.infinity,
              child: const Text(
                '証拠は会話中に突きつけることで、新しい矛盾につながることがあります。',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: evidenceIds.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Text(
                          'まだ証拠を見つけていません。\n場所を調べて証拠を探しましょう。',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  : ListView.builder(
                      itemCount: evidenceIds.length,
                      itemBuilder: (context, index) {
                        final ev = caseData.evidence
                            .firstWhere((e) => e.id == evidenceIds[index]);
                        return Card(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          child: ListTile(
                            leading: const Icon(Icons.inventory),
                            title: Text(ev.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text(ev.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => EvidenceDetailPage(evidenceId: ev.id),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
