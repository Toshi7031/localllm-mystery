import '../../core/conditions/condition_data.dart';

class NpcSecretData {
  final String id;
  final String summary;
  final String reason;
  final ConditionData? revealCondition;

  const NpcSecretData({
    required this.id,
    required this.summary,
    required this.reason,
    this.revealCondition,
  });

  factory NpcSecretData.fromJson(Map<String, dynamic> json) {
    return NpcSecretData(
      id: json['id'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      reason: json['reason'] as String? ?? '',
      revealCondition: ConditionData.fromJson(
          json['revealCondition'] as Map<String, dynamic>?),
    );
  }
}

class NpcLieData {
  final String id;
  final String topic;
  final String lie;
  final String truth;
  final ConditionData? revealCondition;

  const NpcLieData({
    required this.id,
    required this.topic,
    required this.lie,
    required this.truth,
    this.revealCondition,
  });

  factory NpcLieData.fromJson(Map<String, dynamic> json) {
    return NpcLieData(
      id: json['id'] as String? ?? '',
      topic: json['topic'] as String? ?? '',
      lie: json['lie'] as String? ?? '',
      truth: json['truth'] as String? ?? '',
      revealCondition: ConditionData.fromJson(
          json['revealCondition'] as Map<String, dynamic>?),
    );
  }
}

class NpcMistakeData {
  final String id;
  final String topic;
  final String wrongMemory;
  final String actual;
  final ConditionData? clarifyCondition;

  const NpcMistakeData({
    required this.id,
    required this.topic,
    required this.wrongMemory,
    required this.actual,
    this.clarifyCondition,
  });

  factory NpcMistakeData.fromJson(Map<String, dynamic> json) {
    return NpcMistakeData(
      id: json['id'] as String? ?? '',
      topic: json['topic'] as String? ?? '',
      wrongMemory: json['wrongMemory'] as String? ?? '',
      actual: json['actual'] as String? ?? '',
      clarifyCondition: ConditionData.fromJson(
          json['clarifyCondition'] as Map<String, dynamic>?),
    );
  }
}

class NpcData {
  final String id;
  final String name;
  final String role;
  final String locationId;
  final String personality;
  final String speakingStyle;
  final int initialTrust;
  final List<String> publicInfo;
  final List<String> knows;
  final List<NpcSecretData> secrets;
  final List<NpcLieData> lies;
  final List<NpcMistakeData> mistakes;

  const NpcData({
    required this.id,
    required this.name,
    required this.role,
    required this.locationId,
    required this.personality,
    required this.speakingStyle,
    required this.initialTrust,
    required this.publicInfo,
    required this.knows,
    required this.secrets,
    required this.lies,
    required this.mistakes,
  });

  factory NpcData.fromJson(Map<String, dynamic> json) {
    return NpcData(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      role: json['role'] as String? ?? '',
      locationId: json['locationId'] as String? ?? '',
      personality: json['personality'] as String? ?? '',
      speakingStyle: json['speakingStyle'] as String? ?? '',
      initialTrust: json['initialTrust'] as int? ?? 50,
      publicInfo: (json['publicInfo'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      knows: (json['knows'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      secrets: (json['secrets'] as List<dynamic>?)
              ?.map((e) => NpcSecretData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      lies: (json['lies'] as List<dynamic>?)
              ?.map((e) => NpcLieData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      mistakes: (json['mistakes'] as List<dynamic>?)
              ?.map((e) => NpcMistakeData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
