import 'package:flutter/material.dart';
import '../../app/game_provider.dart';
import 'ending_page.dart';

class DeductionPage extends StatefulWidget {
  const DeductionPage({super.key});

  @override
  State<DeductionPage> createState() => _DeductionPageState();
}

class _DeductionPageState extends State<DeductionPage> {
  final Map<String, String> _answers = {};

  @override
  Widget build(BuildContext context) {
    final controller = GameProvider.of(context);
    final caseData = controller.caseData;
    final deduction = caseData.deduction;

    return Scaffold(
      appBar: AppBar(title: Text('${caseData.title} - 推理')),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12.0),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            width: double.infinity,
            child: const Text(
              '集めた証拠と証言をもとに、黒瀬直人の死の真相を推理しましょう。\nすべての問いに答えると、事件の結末が決まります。',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ...deduction.questions.map((q) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(q.text,
                              style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          ...q.choices.map((choice) {
                            return RadioListTile<String>(
                              title: Text(choice.text),
                              value: choice.id,
                              groupValue: _answers[q.id],
                              onChanged: (val) {
                                if (val != null) {
                                  setState(() {
                                    _answers[q.id] = val;
                                  });
                                }
                              },
                            );
                          }),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (_answers.length < deduction.questions.length) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('すべての問いに答えてください。')),
                      );
                      return;
                    }
                    
                    final ending = controller.submitDeduction(_answers);
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (_) => EndingPage(endingId: ending.id),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                  ),
                  child: const Text('提出する'),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
