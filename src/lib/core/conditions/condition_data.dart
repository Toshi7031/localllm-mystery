abstract class ConditionData {
  const ConditionData();

  static ConditionData? fromJson(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) return null;

    if (json.containsKey('all')) {
      return AllConditionData.fromJson(json);
    }
    if (json.containsKey('any')) {
      return AnyConditionData.fromJson(json);
    }
    if (json.containsKey('not')) {
      return NotConditionData.fromJson(json);
    }

    final type = json['type'] as String?;
    if (type == null) {
      return UnknownConditionData(json);
    }

    return SingleConditionData.fromJson(json);
  }
}

class AllConditionData extends ConditionData {
  final List<ConditionData> conditions;

  const AllConditionData(this.conditions);

  factory AllConditionData.fromJson(Map<String, dynamic> json) {
    final list = json['all'] as List<dynamic>? ?? [];
    final conditions = list
        .map((e) => ConditionData.fromJson(e as Map<String, dynamic>?))
        .whereType<ConditionData>()
        .toList();
    return AllConditionData(conditions);
  }
}

class AnyConditionData extends ConditionData {
  final List<ConditionData> conditions;

  const AnyConditionData(this.conditions);

  factory AnyConditionData.fromJson(Map<String, dynamic> json) {
    final list = json['any'] as List<dynamic>? ?? [];
    final conditions = list
        .map((e) => ConditionData.fromJson(e as Map<String, dynamic>?))
        .whereType<ConditionData>()
        .toList();
    return AnyConditionData(conditions);
  }
}

class NotConditionData extends ConditionData {
  final ConditionData condition;

  const NotConditionData(this.condition);

  factory NotConditionData.fromJson(Map<String, dynamic> json) {
    final inner = ConditionData.fromJson(json['not'] as Map<String, dynamic>?) ??
        const UnknownConditionData({});
    return NotConditionData(inner);
  }
}

class SingleConditionData extends ConditionData {
  final String type;
  final String? id;
  final String? npcId;
  final int? value;

  const SingleConditionData({
    required this.type,
    this.id,
    this.npcId,
    this.value,
  });

  factory SingleConditionData.fromJson(Map<String, dynamic> json) {
    return SingleConditionData(
      type: json['type'] as String? ?? 'unknown',
      id: json['id'] as String?,
      npcId: json['npcId'] as String?,
      value: json['value'] as int?,
    );
  }
}

class UnknownConditionData extends ConditionData {
  final Map<String, dynamic> rawJson;

  const UnknownConditionData(this.rawJson);
}
