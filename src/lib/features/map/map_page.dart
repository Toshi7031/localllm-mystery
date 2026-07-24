import 'package:flutter/material.dart';
import '../../app/game_provider.dart';
import '../location/location_page.dart';

class MapPage extends StatelessWidget {
  const MapPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = GameProvider.of(context);
    final state = controller.state;
    if (state == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final unlockedLocations = state.unlockedLocationIds.toList();
    final caseData = controller.caseData;

    return Scaffold(
      appBar: AppBar(
        title: Text('${caseData.title} - マップ'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12.0),
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              width: double.infinity,
              child: const Text(
                '場所を選んで調査を進めましょう。',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: unlockedLocations.length,
                itemBuilder: (context, index) {
                  final locId = unlockedLocations[index];
                  final locData = caseData.locations.firstWhere((l) => l.id == locId);
                  
                  final npcs = caseData.npcs.where((n) => n.locationId == locId);
                  final npcText = npcs.isEmpty ? 'なし' : npcs.map((n) => n.name).join(', ');

                  final spots = caseData.investigationSpots.where((s) => s.locationId == locId);
                  final uninspectedSpots = spots.where((s) => !state.inspectedSpotIds.contains(s.id)).length;

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: ListTile(
                      title: Text(locData.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 4),
                          Text(locData.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 8),
                          Text('未調査: $uninspectedSpots', style: TextStyle(color: uninspectedSpots > 0 ? Colors.orange : Colors.grey)),
                          Text('人物: $npcText', style: const TextStyle(color: Colors.grey)),
                        ],
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      isThreeLine: true,
                      onTap: () {
                        controller.moveToLocation(locId);
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const LocationPage()),
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
