import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:src/domain/models/case_data.dart';
import 'package:src/domain/models/game_state.dart';

void main() {
  test('GameState.initial creates correct initial state from case_001.json', () {
    final file = File('assets/cases/case_001/case_001.json');
    expect(file.existsSync(), isTrue, reason: 'Test requires case_001.json');

    final jsonString = file.readAsStringSync();
    final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
    final caseData = CaseData.fromJson(jsonMap);

    final gameState = GameState.initial(caseData);

    expect(gameState.caseId, 'case_001');
    expect(gameState.currentLocationId, 'warehouse');
    expect(
        gameState.unlockedLocationIds,
        containsAll([
          'warehouse',
          'bakery',
          'fishing_port',
          'general_store',
          'guard_room'
        ]));
    expect(gameState.unlockedLocationIds.contains('town_office'), isFalse);

    expect(gameState.npcTrust['mina'], 35);
    expect(gameState.npcTrust['gorou'], 25);
    expect(gameState.npcTrust['riku'], 45);
    expect(gameState.npcTrust['yui'], 20);
    expect(gameState.npcTrust['tatsu'], 40);

    expect(gameState.isCaseFinished, isFalse);
    expect(gameState.inspectedSpotIds, isEmpty);
    expect(gameState.discoveredEvidenceIds, isEmpty);
  });
}
