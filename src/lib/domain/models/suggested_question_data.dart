import '../../core/conditions/condition_data.dart';
import '../../core/conditions/effect_data.dart';

class SuggestedQuestionData {
  final String id;
  final String npcId;
  final String text;
  final String topic;
  final int priority;
  final ConditionData? unlockCondition;
  final List<EffectData> effectsOnAsked;

  const SuggestedQuestionData({
    required this.id,
    required this.npcId,
    required this.text,
    required this.topic,
    required this.priority,
    this.unlockCondition,
    required this.effectsOnAsked,
  });

  factory SuggestedQuestionData.fromJson(Map<String, dynamic> json) {
    return SuggestedQuestionData(
      id: json['id'] as String? ?? '',
      npcId: json['npcId'] as String? ?? '',
      text: json['text'] as String? ?? '',
      topic: json['topic'] as String? ?? '',
      priority: json['priority'] as int? ?? 0,
      unlockCondition: ConditionData.fromJson(
          json['unlockCondition'] as Map<String, dynamic>?),
      effectsOnAsked: (json['effectsOnAsked'] as List<dynamic>?)
              ?.map((e) => EffectData.fromJson(e as Map<String, dynamic>?))
              .toList() ??
          [],
    );
  }
}
