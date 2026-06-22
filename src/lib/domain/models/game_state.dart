import 'case_data.dart';
import 'conversation_log_entry.dart';
import 'evidence_presentation_log.dart';

class GameState {
  final String caseId;
  String currentLocationId;

  final Set<String> unlockedLocationIds;
  final Set<String> inspectedSpotIds;
  final Set<String> discoveredEvidenceIds;
  final Set<String> revealedTopicIds;
  final Set<String> unlockedContradictionIds;

  final Map<String, int> npcTrust;

  final Set<String> talkedNpcIds;
  final Set<String> askedQuestionIds;

  final List<ConversationLogEntry> conversationLogs;
  final List<EvidencePresentationLog> presentedEvidenceHistory;

  final Map<String, String> deductionAnswers;

  bool isCaseFinished;
  String? reachedEndingId;

  GameState({
    required this.caseId,
    required this.currentLocationId,
    required this.unlockedLocationIds,
    required this.inspectedSpotIds,
    required this.discoveredEvidenceIds,
    required this.revealedTopicIds,
    required this.unlockedContradictionIds,
    required this.npcTrust,
    required this.talkedNpcIds,
    required this.askedQuestionIds,
    required this.conversationLogs,
    required this.presentedEvidenceHistory,
    required this.deductionAnswers,
    this.isCaseFinished = false,
    this.reachedEndingId,
  });

  factory GameState.initial(CaseData caseData) {
    final unlockedLocationIds = caseData.locations
        .where((loc) => loc.initiallyUnlocked)
        .map((loc) => loc.id)
        .toSet();

    final npcTrust = {
      for (final npc in caseData.npcs) npc.id: npc.initialTrust,
    };

    return GameState(
      caseId: caseData.caseId,
      currentLocationId: caseData.startLocationId,
      unlockedLocationIds: unlockedLocationIds,
      inspectedSpotIds: {},
      discoveredEvidenceIds: {},
      revealedTopicIds: {},
      unlockedContradictionIds: {},
      npcTrust: npcTrust,
      talkedNpcIds: {},
      askedQuestionIds: {},
      conversationLogs: [],
      presentedEvidenceHistory: [],
      deductionAnswers: {},
      isCaseFinished: false,
    );
  }

  factory GameState.fromJson(Map<String, dynamic> json) {
    return GameState(
      caseId: json['caseId'] as String? ?? '',
      currentLocationId: json['currentLocationId'] as String? ?? '',
      unlockedLocationIds: (json['unlockedLocationIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toSet() ??
          {},
      inspectedSpotIds: (json['inspectedSpotIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toSet() ??
          {},
      discoveredEvidenceIds: (json['discoveredEvidenceIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toSet() ??
          {},
      revealedTopicIds: (json['revealedTopicIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toSet() ??
          {},
      unlockedContradictionIds:
          (json['unlockedContradictionIds'] as List<dynamic>?)
                  ?.map((e) => e as String)
                  .toSet() ??
              {},
      npcTrust: (json['npcTrust'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v as int)) ??
          {},
      talkedNpcIds: (json['talkedNpcIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toSet() ??
          {},
      askedQuestionIds: (json['askedQuestionIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toSet() ??
          {},
      conversationLogs: (json['conversationLogs'] as List<dynamic>?)
              ?.map((e) =>
                  ConversationLogEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      presentedEvidenceHistory: (json['presentedEvidenceHistory'] as List<dynamic>?)
              ?.map((e) =>
                  EvidencePresentationLog.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      deductionAnswers: (json['deductionAnswers'] as Map<String, dynamic>?)
              ?.map((k, v) => MapEntry(k, v as String)) ??
          {},
      isCaseFinished: json['isCaseFinished'] as bool? ?? false,
      reachedEndingId: json['reachedEndingId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'caseId': caseId,
      'currentLocationId': currentLocationId,
      'unlockedLocationIds': unlockedLocationIds.toList(),
      'inspectedSpotIds': inspectedSpotIds.toList(),
      'discoveredEvidenceIds': discoveredEvidenceIds.toList(),
      'revealedTopicIds': revealedTopicIds.toList(),
      'unlockedContradictionIds': unlockedContradictionIds.toList(),
      'npcTrust': npcTrust,
      'talkedNpcIds': talkedNpcIds.toList(),
      'askedQuestionIds': askedQuestionIds.toList(),
      'conversationLogs': conversationLogs.map((e) => e.toJson()).toList(),
      'presentedEvidenceHistory':
          presentedEvidenceHistory.map((e) => e.toJson()).toList(),
      'deductionAnswers': deductionAnswers,
      'isCaseFinished': isCaseFinished,
      'reachedEndingId': reachedEndingId,
    };
  }
}
