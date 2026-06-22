import 'package:flutter/foundation.dart';
import '../../domain/models/game_state.dart';
import 'effect_data.dart';

class EffectApplier {
  static void apply(EffectData effect, GameState state) {
    switch (effect.type) {
      case 'revealTopic':
        if (effect.id != null) {
          state.revealedTopicIds.add(effect.id!);
        }
        break;

      case 'discoverEvidence':
        if (effect.id != null) {
          state.discoveredEvidenceIds.add(effect.id!);
        }
        break;

      case 'unlockLocation':
        if (effect.id != null) {
          state.unlockedLocationIds.add(effect.id!);
        }
        break;

      case 'unlockContradiction':
        if (effect.id != null) {
          state.unlockedContradictionIds.add(effect.id!);
        }
        break;

      case 'changeTrust':
        if (effect.npcId != null && effect.delta != null) {
          final current = state.npcTrust[effect.npcId!] ?? 0;
          final newValue = (current + effect.delta!).clamp(0, 100);
          state.npcTrust[effect.npcId!] = newValue;
        }
        break;

      default:
        debugPrint('Warning: Unknown effect type "${effect.type}" applied.');
        break;
    }
  }
}
