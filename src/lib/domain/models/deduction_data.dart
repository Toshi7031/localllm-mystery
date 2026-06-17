class DeductionChoiceData {
  final String id;
  final String text;

  const DeductionChoiceData({
    required this.id,
    required this.text,
  });

  factory DeductionChoiceData.fromJson(Map<String, dynamic> json) {
    return DeductionChoiceData(
      id: json['id'] as String? ?? '',
      text: json['text'] as String? ?? '',
    );
  }
}

class DeductionQuestionData {
  final String id;
  final String text;
  final String type;
  final List<DeductionChoiceData> choices;
  final String correctChoiceId;

  const DeductionQuestionData({
    required this.id,
    required this.text,
    required this.type,
    required this.choices,
    required this.correctChoiceId,
  });

  factory DeductionQuestionData.fromJson(Map<String, dynamic> json) {
    return DeductionQuestionData(
      id: json['id'] as String? ?? '',
      text: json['text'] as String? ?? '',
      type: json['type'] as String? ?? '',
      choices: (json['choices'] as List<dynamic>?)
              ?.map((e) =>
                  DeductionChoiceData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      correctChoiceId: json['correctChoiceId'] as String? ?? '',
    );
  }
}

class DeductionData {
  final List<DeductionQuestionData> questions;
  final List<String> requiredForTrueEnding;

  const DeductionData({
    required this.questions,
    required this.requiredForTrueEnding,
  });

  factory DeductionData.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const DeductionData(questions: [], requiredForTrueEnding: []);
    }
    return DeductionData(
      questions: (json['questions'] as List<dynamic>?)
              ?.map((e) =>
                  DeductionQuestionData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      requiredForTrueEnding: (json['requiredForTrueEnding'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }
}
