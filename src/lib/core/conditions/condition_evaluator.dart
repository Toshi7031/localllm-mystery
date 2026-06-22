import '../../domain/models/game_state.dart';
import 'condition_data.dart';

class ConditionEvaluator {
  static bool evaluate(ConditionData? condition, GameState state) {
    if (condition == null) {
      return true;
    }

    if (condition is AllConditionData) {
      return condition.conditions.every((c) => evaluate(c, state));
    }

    if (condition is AnyConditionData) {
      if (condition.conditions.isEmpty) return false;
      return condition.conditions.any((c) => evaluate(c, state));
    }

    if (condition is NotConditionData) {
      return !evaluate(condition.condition, state);
    }

    if (condition is SingleConditionData) {
      return _evaluateSingle(condition, state);
    }

    return false;
  }

  static bool _evaluateSingle(SingleConditionData condition, GameState state) {
    final id = condition.id;
    final npcId = condition.npcId;
    final value = condition.value;

    switch (condition.type) {
      case 'evidenceDiscovered':
        if (id == null) return false;
        return state.discoveredEvidenceIds.contains(id);

      case 'topicRevealed':
        if (id == null) return false;
        return state.revealedTopicIds.contains(id);

      case 'locationUnlocked':
        if (id == null) return false;
        return state.unlockedLocationIds.contains(id);

      case 'spotInspected':
        if (id == null) return false;
        return state.inspectedSpotIds.contains(id);

      case 'questionAsked':
        if (id == null) return false;
        return state.askedQuestionIds.contains(id);

      case 'contradictionUnlocked':
        if (id == null) return false;
        return state.unlockedContradictionIds.contains(id);

      case 'trustAtLeast':
        if (npcId == null || value == null) return false;
        final currentTrust = state.npcTrust[npcId] ?? 0;
        return currentTrust >= value;

      case 'trustLessThan':
        if (npcId == null || value == null) return false;
        final currentTrust = state.npcTrust[npcId] ?? 0;
        return currentTrust < value;

      case 'npcTalked':
        if (npcId == null) return false;
        return state.talkedNpcIds.contains(npcId);

      case 'evidencePresented':
        if (npcId == null || id == null) return false;
        return state.presentedEvidenceHistory
            .any((log) => log.npcId == npcId && log.evidenceId == id);

      default:
        return false;
    }
  }
}
