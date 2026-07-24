import 'package:flutter/material.dart';
import '../../app/game_provider.dart';

class EvidenceDetailPage extends StatelessWidget {
  final String evidenceId;
  const EvidenceDetailPage({super.key, required this.evidenceId});

  @override
  Widget build(BuildContext context) {
    final controller = GameProvider.of(context);
    final ev =
        controller.caseData.evidence.firstWhere((e) => e.id == evidenceId);

    // detailTextがある場合はそちらを優先する想定。
    // detailTextは空文字で初期化されているので、isNotEmptyで判定。
    final detailText = ev.detailText.isNotEmpty 
        ? ev.detailText 
        : ev.description;

    return Scaffold(
      appBar: AppBar(title: Text(ev.name)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '【詳細】',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  detailText,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
