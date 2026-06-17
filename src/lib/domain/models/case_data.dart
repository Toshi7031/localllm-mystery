import 'setting_data.dart';
import 'victim_data.dart';
import 'truth_data.dart';
import 'location_data.dart';
import 'investigation_spot_data.dart';
import 'npc_data.dart';
import 'evidence_data.dart';
import 'topic_data.dart';
import 'suggested_question_data.dart';
import 'evidence_reaction_data.dart';
import 'contradiction_data.dart';
import 'deduction_data.dart';
import 'ending_data.dart';

class CaseData {
  final int schemaVersion;
  final String caseId;
  final String title;
  final int version;
  final String difficulty;
  final int estimatedPlayMinutes;
  final String startLocationId;
  final List<String> tags;

  final SettingData? setting;
  final VictimData? victim;
  final TruthData? truth;

  final List<LocationData> locations;
  final List<InvestigationSpotData> investigationSpots;
  final List<NpcData> npcs;
  final List<EvidenceData> evidence;
  final List<TopicData> topics;
  final List<SuggestedQuestionData> suggestedQuestions;
  final List<EvidenceReactionData> evidenceReactions;
  final List<ContradictionData> contradictions;
  final DeductionData deduction;
  final List<EndingData> endings;

  const CaseData({
    required this.schemaVersion,
    required this.caseId,
    required this.title,
    required this.version,
    required this.difficulty,
    required this.estimatedPlayMinutes,
    required this.startLocationId,
    required this.tags,
    this.setting,
    this.victim,
    this.truth,
    required this.locations,
    required this.investigationSpots,
    required this.npcs,
    required this.evidence,
    required this.topics,
    required this.suggestedQuestions,
    required this.evidenceReactions,
    required this.contradictions,
    required this.deduction,
    required this.endings,
  });

  factory CaseData.fromJson(Map<String, dynamic> json) {
    return CaseData(
      schemaVersion: json['schemaVersion'] as int? ?? 1,
      caseId: json['caseId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      version: json['version'] as int? ?? 1,
      difficulty: json['difficulty'] as String? ?? '',
      estimatedPlayMinutes: json['estimatedPlayMinutes'] as int? ?? 0,
      startLocationId: json['startLocationId'] as String? ?? '',
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      setting: json['setting'] != null ? SettingData.fromJson(json['setting'] as Map<String, dynamic>) : null,
      victim: json['victim'] != null ? VictimData.fromJson(json['victim'] as Map<String, dynamic>) : null,
      truth: json['truth'] != null ? TruthData.fromJson(json['truth'] as Map<String, dynamic>) : null,
      locations: (json['locations'] as List<dynamic>?)?.map((e) => LocationData.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      investigationSpots: (json['investigationSpots'] as List<dynamic>?)?.map((e) => InvestigationSpotData.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      npcs: (json['npcs'] as List<dynamic>?)?.map((e) => NpcData.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      evidence: (json['evidence'] as List<dynamic>?)?.map((e) => EvidenceData.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      topics: (json['topics'] as List<dynamic>?)?.map((e) => TopicData.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      suggestedQuestions: (json['suggestedQuestions'] as List<dynamic>?)?.map((e) => SuggestedQuestionData.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      evidenceReactions: (json['evidenceReactions'] as List<dynamic>?)?.map((e) => EvidenceReactionData.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      contradictions: (json['contradictions'] as List<dynamic>?)?.map((e) => ContradictionData.fromJson(e as Map<String, dynamic>)).toList() ?? [],
      deduction: DeductionData.fromJson(json['deduction'] as Map<String, dynamic>?),
      endings: (json['endings'] as List<dynamic>?)?.map((e) => EndingData.fromJson(e as Map<String, dynamic>)).toList() ?? [],
    );
  }
}
