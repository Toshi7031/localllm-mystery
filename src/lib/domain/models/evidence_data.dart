class EvidenceData {
  final String id;
  final String name;
  final String foundAtLocationId;
  final String description;
  final String detailText;
  final List<String> relatedTopics;
  final String clueLevel;

  const EvidenceData({
    required this.id,
    required this.name,
    required this.foundAtLocationId,
    required this.description,
    required this.detailText,
    required this.relatedTopics,
    required this.clueLevel,
  });

  factory EvidenceData.fromJson(Map<String, dynamic> json) {
    return EvidenceData(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      foundAtLocationId: json['foundAtLocationId'] as String? ?? '',
      description: json['description'] as String? ?? '',
      detailText: json['detailText'] as String? ?? '',
      relatedTopics: (json['relatedTopics'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      clueLevel: json['clueLevel'] as String? ?? 'low',
    );
  }
}
