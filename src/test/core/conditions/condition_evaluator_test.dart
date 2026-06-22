import 'package:flutter_test/flutter_test.dart';
import 'package:src/core/conditions/condition_data.dart';
import 'package:src/core/conditions/condition_evaluator.dart';
import 'package:src/domain/models/game_state.dart';

void main() {
  late GameState state;

  setUp(() {
    state = GameState(
      caseId: 'test_case',
      currentLocationId: 'loc1',
      unlockedLocationIds: {'loc1'},
      inspectedSpotIds: {'spot1'},
      discoveredEvidenceIds: {'evidence1'},
      revealedTopicIds: {'topic1'},
      unlockedContradictionIds: {'contra1'},
      npcTrust: {'npc1': 50, 'npc2': 30},
      talkedNpcIds: {'npc1'},
      askedQuestionIds: {'question1'},
      conversationLogs: [],
      presentedEvidenceHistory: [],
      deductionAnswers: {},
    );
  });

  test('null condition evaluates to true', () {
    expect(ConditionEvaluator.evaluate(null, state), isTrue);
  });

  test('evaluate SingleConditionData', () {
    // evidenceDiscovered
    expect(
        ConditionEvaluator.evaluate(
            const SingleConditionData(type: 'evidenceDiscovered', id: 'evidence1'), state),
        isTrue);
    expect(
        ConditionEvaluator.evaluate(
            const SingleConditionData(type: 'evidenceDiscovered', id: 'evidence2'), state),
        isFalse);

    // trustAtLeast
    expect(
        ConditionEvaluator.evaluate(
            const SingleConditionData(type: 'trustAtLeast', npcId: 'npc1', value: 40),
            state),
        isTrue);
    expect(
        ConditionEvaluator.evaluate(
            const SingleConditionData(type: 'trustAtLeast', npcId: 'npc1', value: 60),
            state),
        isFalse);

    // unknown
    expect(
        ConditionEvaluator.evaluate(
            const SingleConditionData(type: 'unknown_type', id: 'xxx'), state),
        isFalse);
  });

  test('evaluate AllConditionData', () {
    final allCond = AllConditionData([
      const SingleConditionData(type: 'evidenceDiscovered', id: 'evidence1'),
      const SingleConditionData(type: 'trustAtLeast', npcId: 'npc1', value: 40),
    ]);
    expect(ConditionEvaluator.evaluate(allCond, state), isTrue);

    final allCondFalse = AllConditionData([
      const SingleConditionData(type: 'evidenceDiscovered', id: 'evidence1'),
      const SingleConditionData(type: 'evidenceDiscovered', id: 'evidence2'),
    ]);
    expect(ConditionEvaluator.evaluate(allCondFalse, state), isFalse);
  });

  test('evaluate AnyConditionData', () {
    final anyCond = AnyConditionData([
      const SingleConditionData(type: 'evidenceDiscovered', id: 'evidence2'),
      const SingleConditionData(type: 'trustAtLeast', npcId: 'npc1', value: 40),
    ]);
    expect(ConditionEvaluator.evaluate(anyCond, state), isTrue);

    final anyCondFalse = AnyConditionData([
      const SingleConditionData(type: 'evidenceDiscovered', id: 'evidence2'),
      const SingleConditionData(type: 'trustAtLeast', npcId: 'npc2', value: 60),
    ]);
    expect(ConditionEvaluator.evaluate(anyCondFalse, state), isFalse);
  });

  test('evaluate NotConditionData', () {
    final notCond = NotConditionData(const SingleConditionData(
        type: 'evidenceDiscovered', id: 'evidence2'));
    expect(ConditionEvaluator.evaluate(notCond, state), isTrue);

    final notCondFalse = NotConditionData(const SingleConditionData(
        type: 'evidenceDiscovered', id: 'evidence1'));
    expect(ConditionEvaluator.evaluate(notCondFalse, state), isFalse);
  });
}
