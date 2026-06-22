class LlmOutputSanitizer {
  static String sanitize(String output) {
    var text = output;

    // Remove <think>...</think> tags and their content, even if </think> is missing
    text = text.replaceAll(RegExp(r'<think>[\s\S]*?(?:</think>|$)'), '');
    
    text = text.trim();

    final prefixesToStrip = ['プレイヤー:', 'あなた:', '#'];
    for (final prefix in prefixesToStrip) {
      final index = text.indexOf(prefix);
      if (index != -1) {
        text = text.substring(0, index).trim();
      }
    }


    if (text.isEmpty) {
      return '……。';
    }
    return text;
  }
}
