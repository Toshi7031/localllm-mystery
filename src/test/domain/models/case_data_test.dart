import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:src/domain/models/case_data.dart';

void main() {
  test('case_001.json parses successfully into CaseData', () {
    // 実行パスが `src/` になる想定
    final file = File('assets/cases/case_001/case_001.json');
    expect(file.existsSync(), isTrue, reason: 'Test requires case_001.json to be present');

    final jsonString = file.readAsStringSync();
    final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;

    final caseData = CaseData.fromJson(jsonMap);

    expect(caseData.caseId, 'case_001');
    expect(caseData.title, '雨夜の倉庫事件');
    expect(caseData.schemaVersion, 2);
    expect(caseData.startLocationId, 'warehouse');

    // Setting
    expect(caseData.setting?.townName, 'ミナト町');

    // Victim
    expect(caseData.victim?.id, 'kurose');

    // Truth
    expect(caseData.truth?.culpritId, 'yui');
    expect(caseData.truth?.criticalEvidenceIds, contains('broken_pocket_watch'));

    // Locations
    expect(caseData.locations, isNotEmpty);
    final warehouse = caseData.locations.firstWhere((l) => l.id == 'warehouse');
    expect(warehouse.initiallyUnlocked, isTrue);

    // NPCs
    expect(caseData.npcs, isNotEmpty);
    final yui = caseData.npcs.firstWhere((n) => n.id == 'yui');
    expect(yui.lies, isNotEmpty);
    expect(yui.secrets, isNotEmpty);

    // InvestigationSpots
    expect(caseData.investigationSpots, isNotEmpty);
    final spot = caseData.investigationSpots.first;
    expect(spot.effects, isNotEmpty);

    // Evidence
    expect(caseData.evidence, isNotEmpty);
    
    // Topics
    expect(caseData.topics, isNotEmpty);

    // SuggestedQuestions
    expect(caseData.suggestedQuestions, isNotEmpty);

    // EvidenceReactions
    expect(caseData.evidenceReactions, isNotEmpty);

    // Contradictions
    expect(caseData.contradictions, isNotEmpty);

    // Deduction
    expect(caseData.deduction.questions, isNotEmpty);
    expect(caseData.deduction.requiredForTrueEnding, isNotEmpty);

    // Endings
    expect(caseData.endings, isNotEmpty);
  });
}
