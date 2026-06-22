class ConversationLogEntry {
  final String id;
  final String npcId;
  final String speaker; // player / npc / system
  final String text;
  final String? topicId;
  final DateTime createdAt;

  ConversationLogEntry({
    required this.id,
    required this.npcId,
    required this.speaker,
    required this.text,
    this.topicId,
    required this.createdAt,
  });

  factory ConversationLogEntry.fromJson(Map<String, dynamic> json) {
    return ConversationLogEntry(
      id: json['id'] as String? ?? '',
      npcId: json['npcId'] as String? ?? '',
      speaker: json['speaker'] as String? ?? '',
      text: json['text'] as String? ?? '',
      topicId: json['topicId'] as String?,
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'npcId': npcId,
      'speaker': speaker,
      'text': text,
      'topicId': topicId,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
