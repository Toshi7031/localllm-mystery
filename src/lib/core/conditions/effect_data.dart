class EffectData {
  final String type;
  final String? id;
  final String? npcId;
  final int? delta;

  const EffectData({
    required this.type,
    this.id,
    this.npcId,
    this.delta,
  });

  factory EffectData.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const EffectData(type: 'unknown');
    }
    return EffectData(
      type: json['type'] as String? ?? 'unknown',
      id: json['id'] as String?,
      npcId: json['npcId'] as String?,
      delta: json['delta'] as int?,
    );
  }
}
