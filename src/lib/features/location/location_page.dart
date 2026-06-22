import 'package:flutter/material.dart';
import '../../app/game_provider.dart';
import '../conversation/conversation_page.dart';

class LocationPage extends StatelessWidget {
  const LocationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = GameProvider.of(context);
    final state = controller.state;
    if (state == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final locId = state.currentLocationId;
    final locData = controller.caseData.locations.firstWhere((l) => l.id == locId);
    
    final npcs = controller.caseData.npcs.where((n) => n.locationId == locId).toList();
    final spots = controller.caseData.investigationSpots.where((s) => s.locationId == locId).toList();

    return Scaffold(
      appBar: AppBar(title: Text(locData.name)),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12.0),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            width: double.infinity,
            child: const Text(
              '気になる場所を調べるか、住人に話を聞いてみましょう。',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(locData.description, style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 24),
                if (npcs.isNotEmpty) ...[
                  Text('この場所にいる人物', style: Theme.of(context).textTheme.titleLarge),
                  const Divider(),
                  ...npcs.map((npc) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.person),
                      title: Text(npc.name),
                      subtitle: Text(npc.role),
                      trailing: const Icon(Icons.chat),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => ConversationPage(npcId: npc.id)),
                        );
                      },
                    ),
                  )),
                  const SizedBox(height: 24),
                ],
                if (spots.isNotEmpty) ...[
                  Text('調べられる場所', style: Theme.of(context).textTheme.titleLarge),
                  const Divider(),
                  ...spots.map((spot) {
                    final isInspected = state.inspectedSpotIds.contains(spot.id);
                    return Card(
                      color: isInspected ? Theme.of(context).colorScheme.surfaceContainerHighest : null,
                      child: ListTile(
                        leading: Icon(isInspected ? Icons.search_off : Icons.search),
                        title: Text(spot.title, style: TextStyle(color: isInspected ? Colors.grey : null)),
                        onTap: () {
                          final result = controller.inspectSpot(spot.id);
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: Text(result.isLocked ? '調査不可' : (result.isFirstTime ? '発見' : '調査済み')),
                              content: Text(result.text),
                              actions: [
                                TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('OK'))
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  }),
                ]
              ],
            ),
          ),
        ],
      ),
    );
  }
}
