class EvidenceReactionResult {
  final String text;
  final String reactionType; // 'scripted', 'llm', 'unrelated'

  EvidenceReactionResult({
    required this.text,
    required this.reactionType,
  });
}
