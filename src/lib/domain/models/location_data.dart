import '../../core/conditions/condition_data.dart';

class LocationData {
  final String id;
  final String name;
  final String description;
  final bool initiallyUnlocked;
  final ConditionData? unlockCondition;
  final List<String> connectedLocationIds;
  final List<String> npcIds;

  const LocationData({
    required this.id,
    required this.name,
    required this.description,
    required this.initiallyUnlocked,
    this.unlockCondition,
    required this.connectedLocationIds,
    required this.npcIds,
  });

  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      initiallyUnlocked: json['initiallyUnlocked'] as bool? ?? true,
      unlockCondition: ConditionData.fromJson(
          json['unlockCondition'] as Map<String, dynamic>?),
      connectedLocationIds: (json['connectedLocationIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      npcIds: (json['npcIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }
}
