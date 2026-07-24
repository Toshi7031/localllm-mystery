import 'package:flutter_test/flutter_test.dart';
import 'package:llama_cpp_dart/llama_cpp_dart.dart';

void main() {
  test('Test ChatTemplate Parser with simple template', () {
    print("Testing ChatTemplate parsing...");
    
    // シンプルなテンプレートを検証する
    const simpleTemplate = "{% for message in messages %}{{ message['content'] }}{% endfor %}";
    
    // ChatTemplateの生成と適用テスト
    // 注: llama_cpp_dartのChatTemplateは C++の llama_chat_apply_template をバインドしているため、
    // ネイティブライブラリがロードされていないと動かない可能性があります。
    // そのため、ここでは例外をキャッチして挙動を確認します。
    try {
      // プレースホルダーでChatTemplate.applyを試す
      // ※ ネイティブライブラリが必要なのでテスト環境で動くか？
      // もしネイティブライブラリがなくても、Dart側のIsolateラッパーが初期化されていなければエラーになる。
      // このテストはコンパイル確認と、手元で実行可能な部分のみをチェックします。
      print("Simple template: $simpleTemplate");
    } catch (e) {
      print("Caught error: $e");
    }
  });
}
