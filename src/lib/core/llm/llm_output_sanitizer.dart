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

  /// ストリーミング中のテキストから思考タグ `<think>...</think>` の中身を伏せ字（█）に置換し、
  /// 末尾の予期せぬプレフィックスを除去して取得します。
  static String maskThinkingProcess(String rawText) {
    if (!rawText.contains('<think>')) {
      return _stripPrefixes(rawText);
    }

    final buffer = StringBuffer();
    bool insideThink = false;
    int currentIndex = 0;
    
    while (currentIndex < rawText.length) {
      if (!insideThink) {
        final nextThink = rawText.indexOf('<think>', currentIndex);
        if (nextThink == -1) {
          buffer.write(rawText.substring(currentIndex));
          break;
        } else {
          buffer.write(rawText.substring(currentIndex, nextThink));
          insideThink = true;
          currentIndex = nextThink + '<think>'.length;
        }
      } else {
        final nextEndThink = rawText.indexOf('</think>', currentIndex);
        if (nextEndThink == -1) {
          final textToMask = rawText.substring(currentIndex);
          buffer.write(textToMask.replaceAll(RegExp(r'[^\s]'), '█'));
          break;
        } else {
          final textToMask = rawText.substring(currentIndex, nextEndThink);
          buffer.write(textToMask.replaceAll(RegExp(r'[^\s]'), '█'));
          insideThink = false;
          currentIndex = nextEndThink + '</think>'.length;
        }
      }
    }
    
    final text = buffer.toString().trim();
    return _stripPrefixes(text, rawText: rawText);
  }

  static String _stripPrefixes(String text, {String? rawText}) {
    var stripped = text;
    final prefixesToStrip = ['プレイヤー:', 'あなた:', '#'];
    for (final prefix in prefixesToStrip) {
      final index = stripped.indexOf(prefix);
      if (index != -1) {
        stripped = stripped.substring(0, index);
      }
    }
    return stripped.isEmpty && rawText != null && rawText.isNotEmpty ? '...' : stripped;
  }
}

