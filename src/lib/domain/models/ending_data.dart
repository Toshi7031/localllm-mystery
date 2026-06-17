class EndingConditionData {
  final int correctDeductionCountAtLeast;

  const EndingConditionData({
    required this.correctDeductionCountAtLeast,
  });

  factory EndingConditionData.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const EndingConditionData(correctDeductionCountAtLeast: 0);
    }
    return EndingConditionData(
      correctDeductionCountAtLeast:
          json['correctDeductionCountAtLeast'] as int? ?? 0,
    );
  }
}

class EndingData {
  final String id;
  final String title;
  final EndingConditionData condition;
  final String summary;
  final String tone;

  const EndingData({
    required this.id,
    required this.title,
    required this.condition,
    required this.summary,
    required this.tone,
  });

  factory EndingData.fromJson(Map<String, dynamic> json) {
    return EndingData(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      condition: EndingConditionData.fromJson(
          json['condition'] as Map<String, dynamic>?),
      summary: json['summary'] as String? ?? '',
      tone: json['tone'] as String? ?? '',
    );
  }
}
