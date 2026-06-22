import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:src/core/llm/mock_llm_service.dart';
import 'package:src/core/storage/save_service.dart';
import 'package:src/domain/models/case_data.dart';
import 'package:src/game/game_controller.dart';

void main() {
  late GameController controller;
  late CaseData caseData;
  late MemorySaveService saveService;
  late MockLlmService llmService;

  setUp(() async {
    final file = File('assets/cases/case_001/case_001.json');
    expect(file.existsSync(), isTrue, reason: 'Test requires case_001.json');

    final jsonString = file.readAsStringSync();
    final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
    caseData = CaseData.fromJson(jsonMap);

    saveService = MemorySaveService();
    llmService = MockLlmService();

    controller = GameController(
      saveService: saveService,
      llmService: llmService,
      caseData: caseData,
    );
  });

  test('startNewGame sets up initial state', () async {
    await controller.startNewGame();
    expect(controller.state, isNotNull);
    expect(controller.state!.currentLocationId, 'warehouse');

    final savedState = await saveService.load(caseData.caseId);
    expect(savedState, isNotNull);
    expect(savedState!.caseId, caseData.caseId);
  });

  test('inspectSpot unlocks evidence and records spot', () async {
    await controller.startNewGame();

    final result = controller.inspectSpot('warehouse_broken_watch_spot');
    expect(result.isLocked, isFalse);
    expect(result.isFirstTime, isTrue);

    expect(controller.state!.inspectedSpotIds.contains('warehouse_broken_watch_spot'),
        isTrue);
    expect(
        controller.state!.discoveredEvidenceIds
            .contains('broken_pocket_watch'),
        isTrue);

    final result2 = controller.inspectSpot('warehouse_broken_watch_spot');
    expect(result2.isFirstTime, isFalse);
  });

  test('sendMessage records conversation and returns mock reply', () async {
    await controller.startNewGame();

    final reply = await controller.sendMessage(npcId: 'mina', text: 'こんにちは');
    expect(reply.text, '[Mock] それについてはよくわかりません。');

    final logs = controller.state!.conversationLogs;
    expect(logs.length, 2);
    expect(logs[0].speaker, 'player');
    expect(logs[1].speaker, 'npc');
  });

  test('presentEvidence records history and triggers reaction', () async {
    await controller.startNewGame();

    controller.inspectSpot('warehouse_red_umbrella_spot');

    final reaction = await controller.presentEvidence(
        npcId: 'mina', evidenceId: 'red_umbrella');
    expect(reaction.reactionType, 'scripted');

    expect(controller.state!.presentedEvidenceHistory.length, 1);
  });

  test('submitDeduction determines correct ending', () async {
    await controller.startNewGame();

    final answers = {
      'culprit': 'yui',
      'critical_evidence': 'broken_pocket_watch',
      'motive': 'fraud_invoice_copy',
      'coverup': 'used_red_umbrella',
    };

    final ending = controller.submitDeduction(answers);
    expect(ending.id, 'true_ending');
    expect(controller.state!.isCaseFinished, isTrue);
  });
}
