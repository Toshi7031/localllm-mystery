import 'package:flutter/material.dart';
import '../../app/game_provider.dart';
import '../../shared/widgets/main_layout.dart';

class CaseIntroPage extends StatelessWidget {
  const CaseIntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = GameProvider.of(context);
    final caseData = controller.caseData;

    return Scaffold(
      appBar: AppBar(
        title: const Text('導入'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              caseData.title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 24),
            Text(
              '【舞台】',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(caseData.setting?.summary ?? ''),
            const SizedBox(height: 24),
            Text(
              '【被害者】',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('${caseData.victim?.name ?? ''} - ${caseData.victim?.description ?? ''}'),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.search),
                label: const Text('調査を始める'),
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (_) => const MainLayout()),
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
