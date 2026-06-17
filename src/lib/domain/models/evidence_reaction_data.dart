import '../../core/conditions/condition_data.dart';
import '../../core/conditions/effect_data.dart';

class EvidenceReactionData {
  final String id;
  final String npcId;
  final String evidenceId;
  final String reactionType;
  final String text;
  final ConditionData? unlockCondition;
  final List<EffectData> effectsOnReact;
  final List<String> candidateContradictionIds;

  const EvidenceReactionData({
    required this.id,
    required this.npcId,
    required this.evidenceId,
    required this.reactionType,
    required this.text,
    this.unlockCondition,
    required this.effectsOnReact,
    required this.candidateContradictionIds,
  });

  factory EvidenceReactionData.fromJson(Map<String, dynamic> json) {
    return EvidenceReactionData(
      id: json['id'] as String? ?? '',
      npcId: json['npcId'] as String? ?? '',
      evidenceId: json['evidenceId'] as String? ?? '',
      reactionType: json['reactionType'] as String? ?? '',
      text: json['text'] as String? ?? '',
      unlockCondition: ConditionData.fromJson(
          json['unlockCondition'] as Map<String, dynamic>?),
      effectsOnReact: (json['effectsOnReact'] as List<dynamic>?)
              ?.map((e) => EffectData.fromJson(e as Map<String, dynamic>?))
              .toList() ??
          [],
      candidateContradictionIds:
          (json['candidateContradictionIds'] as List<dynamic>?)
                  ?.map((e) => e as String)
                  .toList() ??
              [],
    );
  }
}
