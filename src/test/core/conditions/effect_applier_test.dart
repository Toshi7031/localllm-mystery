import 'package:flutter_test/flutter_test.dart';
import 'package:src/core/conditions/effect_data.dart';
import 'package:src/core/conditions/effect_applier.dart';
import 'package:src/domain/models/game_state.dart';

void main() {
  late GameState state;

  setUp(() {
    state = GameState(
      caseId: 'test_case',
      currentLocationId: 'loc1',
      unlockedLocationIds: {},
      inspectedSpotIds: {},
      discoveredEvidenceIds: {},
      revealedTopicIds: {},
      unlockedContradictionIds: {},
      npcTrust: {'npc1': 50},
      talkedNpcIds: {},
      askedQuestionIds: {},
      conversationLogs: [],
      presentedEvidenceHistory: [],
      deductionAnswers: {},
    );
  });

  test('apply revealTopic', () {
    EffectApplier.apply(const EffectData(type: 'revealTopic', id: 'topic1'), state);
    expect(state.revealedTopicIds.contains('topic1'), isTrue);
  });

  test('apply discoverEvidence', () {
    EffectApplier.apply(const EffectData(type: 'discoverEvidence', id: 'evidence1'), state);
    expect(state.discoveredEvidenceIds.contains('evidence1'), isTrue);
  });

  test('apply changeTrust', () {
    EffectApplier.apply(
        const EffectData(type: 'changeTrust', npcId: 'npc1', delta: 10), state);
    expect(state.npcTrust['npc1'], 60);

    EffectApplier.apply(
        const EffectData(type: 'changeTrust', npcId: 'npc1', delta: 50), state);
    expect(state.npcTrust['npc1'], 100);

    EffectApplier.apply(
        const EffectData(type: 'changeTrust', npcId: 'npc1', delta: -120), state);
    expect(state.npcTrust['npc1'], 0);
  });

  test('apply unknown effect does not crash', () {
    EffectApplier.apply(const EffectData(type: 'unknown_effect', id: 'xxx'), state);
    expect(state.revealedTopicIds.isEmpty, isTrue);
  });
}
