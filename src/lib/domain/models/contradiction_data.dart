import '../../core/conditions/condition_data.dart';
import '../../core/conditions/effect_data.dart';

class ContradictionData {
  final String id;
  final String title;
  final String npcId;
  final String statementTopic;
  final ConditionData? unlockCondition;
  final String description;
  final String successMessage;
  final List<EffectData> effectsOnUnlock;

  const ContradictionData({
    required this.id,
    required this.title,
    required this.npcId,
    required this.statementTopic,
    this.unlockCondition,
    required this.description,
    required this.successMessage,
    required this.effectsOnUnlock,
  });

  factory ContradictionData.fromJson(Map<String, dynamic> json) {
    return ContradictionData(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      npcId: json['npcId'] as String? ?? '',
      statementTopic: json['statementTopic'] as String? ?? '',
      unlockCondition: ConditionData.fromJson(
          json['unlockCondition'] as Map<String, dynamic>?),
      description: json['description'] as String? ?? '',
      successMessage: json['successMessage'] as String? ?? '',
      effectsOnUnlock: (json['effectsOnUnlock'] as List<dynamic>?)
              ?.map((e) => EffectData.fromJson(e as Map<String, dynamic>?))
              .toList() ??
          [],
    );
  }
}
