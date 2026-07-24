class LlmGenerationConfig {
  final int maxTokens;
  final double temperature;
  final double topP;
  final int contextSize;
  final List<String> stopSequences;

  const LlmGenerationConfig({
    this.maxTokens = 2048,
    this.temperature = 0.7,
    this.topP = 0.9,
    this.contextSize = 2048,
    this.stopSequences = const [
      '\nプレイヤー:',
      '\nあなた:',
      '\n#',
    ],
  });
}
