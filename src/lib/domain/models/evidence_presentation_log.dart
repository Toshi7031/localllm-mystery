class EvidencePresentationLog {
  final String npcId;
  final String evidenceId;
  final DateTime presentedAt;

  EvidencePresentationLog({
    required this.npcId,
    required this.evidenceId,
    required this.presentedAt,
  });

  factory EvidencePresentationLog.fromJson(Map<String, dynamic> json) {
    return EvidencePresentationLog(
      npcId: json['npcId'] as String? ?? '',
      evidenceId: json['evidenceId'] as String? ?? '',
      presentedAt: DateTime.tryParse(json['presentedAt'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'npcId': npcId,
      'evidenceId': evidenceId,
      'presentedAt': presentedAt.toIso8601String(),
    };
  }
}
