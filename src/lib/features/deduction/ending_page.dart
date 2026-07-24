import 'package:flutter/material.dart';
import '../../app/game_provider.dart';

class EndingPage extends StatelessWidget {
  final String endingId;
  const EndingPage({super.key, required this.endingId});

  @override
  Widget build(BuildContext context) {
    final controller = GameProvider.of(context);
    final state = controller.state!;
    final caseData = controller.caseData;
    final ending = caseData.endings.firstWhere((e) => e.id == endingId);
    final questions = caseData.deduction.questions;
    final answers = state.deductionAnswers;

    return Scaffold(
      appBar: AppBar(
        title: const Text('結末'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  ending.title,
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    ending.summary,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                const SizedBox(height: 32),
                const Text('【あなたの推理】', style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...questions.map((q) {
                  final answerId = answers[q.id];
                  final choiceText = answerId != null 
                      ? q.choices.firstWhere((c) => c.id == answerId, orElse: () => q.choices.first).text 
                      : '未回答';
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text('Q: ${q.text}\nA: $choiceText'),
                  );
                }),
                const SizedBox(height: 48),
                Center(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.home),
                    label: const Text('タイトルへ戻る'),
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
