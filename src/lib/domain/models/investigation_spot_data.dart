import '../../core/conditions/condition_data.dart';
import '../../core/conditions/effect_data.dart';

class InvestigationSpotData {
  final String id;
  final String locationId;
  final String title;
  final String shortDescription;
  final String inspectText;
  final String afterInspectText;
  final ConditionData? unlockCondition;
  final List<EffectData> effects;

  const InvestigationSpotData({
    required this.id,
    required this.locationId,
    required this.title,
    required this.shortDescription,
    required this.inspectText,
    required this.afterInspectText,
    this.unlockCondition,
    required this.effects,
  });

  factory InvestigationSpotData.fromJson(Map<String, dynamic> json) {
    return InvestigationSpotData(
      id: json['id'] as String? ?? '',
      locationId: json['locationId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      shortDescription: json['shortDescription'] as String? ?? '',
      inspectText: json['inspectText'] as String? ?? '',
      afterInspectText: json['afterInspectText'] as String? ?? '',
      unlockCondition: ConditionData.fromJson(
          json['unlockCondition'] as Map<String, dynamic>?),
      effects: (json['effects'] as List<dynamic>?)
              ?.map((e) => EffectData.fromJson(e as Map<String, dynamic>?))
              .toList() ??
          [],
    );
  }
}
