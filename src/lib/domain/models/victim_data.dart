class VictimData {
  final String id;
  final String name;
  final int age;
  final String role;
  final String description;
  final String publicImage;
  final String hiddenSide;
  final Map<String, String> relationships;

  const VictimData({
    required this.id,
    required this.name,
    required this.age,
    required this.role,
    required this.description,
    required this.publicImage,
    required this.hiddenSide,
    required this.relationships,
  });

  factory VictimData.fromJson(Map<String, dynamic> json) {
    return VictimData(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      age: json['age'] as int? ?? 0,
      role: json['role'] as String? ?? '',
      description: json['description'] as String? ?? '',
      publicImage: json['publicImage'] as String? ?? '',
      hiddenSide: json['hiddenSide'] as String? ?? '',
      relationships: (json['relationships'] as Map<String, dynamic>?)?.map(
            (k, v) => MapEntry(k, v as String),
          ) ??
          {},
    );
  }
}
