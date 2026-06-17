class TruthData {
  final String culpritId;
  final String summary;
  final String deathType;
  final String motive;
  final String method;
  final String coverUp;
  final List<String> criticalEvidenceIds;

  const TruthData({
    required this.culpritId,
    required this.summary,
    required this.deathType,
    required this.motive,
    required this.method,
    required this.coverUp,
    required this.criticalEvidenceIds,
  });

  factory TruthData.fromJson(Map<String, dynamic> json) {
    return TruthData(
      culpritId: json['culpritId'] as String? ?? '',
      summary: json['summary'] as String? ?? '',
      deathType: json['deathType'] as String? ?? '',
      motive: json['motive'] as String? ?? '',
      method: json['method'] as String? ?? '',
      coverUp: json['coverUp'] as String? ?? '',
      criticalEvidenceIds: (json['criticalEvidenceIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }
}
