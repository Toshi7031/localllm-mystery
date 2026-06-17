class TopicData {
  final String id;
  final String label;
  final List<String> keywords;

  const TopicData({
    required this.id,
    required this.label,
    required this.keywords,
  });

  factory TopicData.fromJson(Map<String, dynamic> json) {
    return TopicData(
      id: json['id'] as String? ?? '',
      label: json['label'] as String? ?? '',
      keywords: (json['keywords'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }
}
