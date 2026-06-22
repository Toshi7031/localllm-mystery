import 'dart:developer' as developer;
import 'package:llama_cpp_dart/llama_cpp_dart.dart';
import 'llm_generation_config.dart';
import 'llm_service.dart';

/// llama.cppと連携するためのクラス。
class LlamaCppLlmService implements LlmService {
  final String modelPath;
  LlamaEngine? _engine;
  bool _isInitialized = false;

  LlamaCppLlmService({required this.modelPath});

  @override
  Future<void> initialize() async {
    try {
      developer.log('Initializing Llama with model: $modelPath', name: 'LlamaCppLlmService');
      
      _engine = await LlamaEngine.spawn(
        libraryPath: 'libllama.so',
        modelParams: ModelParams(path: modelPath, gpuLayers: 99),
        contextParams: const ContextParams(nCtx: 2048),
      );
      
      _isInitialized = true;
      developer.log('LlamaCppLlmService initialized.', name: 'LlamaCppLlmService');
    } catch (e) {
      developer.log('Failed to initialize Llama: $e', name: 'LlamaCppLlmService', error: e);
      _isInitialized = false;
      rethrow;
    }
  }

  @override
  Future<bool> isAvailable() async {
    return _isInitialized && _engine != null;
  }

  @override
  Future<String> generateNpcReply({
    required String npcId,
    required String prompt,
    LlmGenerationConfig? config,
  }) async {
    if (!_isInitialized || _engine == null) {
      throw StateError('LlamaCppLlmService is not initialized.');
    }
    
    developer.log('Generating reply for NPC $npcId...', name: 'LlamaCppLlmService');
    
    final maxTokens = config?.maxTokens ?? const LlmGenerationConfig().maxTokens;
    final chat = await _engine!.createChat();
    chat.addUser(prompt);
    
    final buffer = StringBuffer();
    await for (final event in chat.generate(maxTokens: maxTokens)) {
      if (event is TokenEvent) {
        buffer.write(event.text);
      }
    }
    
    final result = buffer.toString();
    developer.log('Generated: $result', name: 'LlamaCppLlmService');
    return result;
  }

  @override
  Future<String> generateEvidenceReaction({
    required String npcId,
    required String evidenceId,
    required String prompt,
    LlmGenerationConfig? config,
  }) async {
    if (!_isInitialized || _engine == null) {
      throw StateError('LlamaCppLlmService is not initialized.');
    }
    
    developer.log('Generating reaction for NPC $npcId to evidence $evidenceId...', name: 'LlamaCppLlmService');
    
    final maxTokens = config?.maxTokens ?? const LlmGenerationConfig().maxTokens;
    final chat = await _engine!.createChat();
    chat.addUser(prompt);
    
    final buffer = StringBuffer();
    await for (final event in chat.generate(maxTokens: maxTokens)) {
      if (event is TokenEvent) {
        buffer.write(event.text);
      }
    }
    
    return buffer.toString();
  }

  @override
  Future<void> dispose() async {
    await _engine?.dispose();
    _engine = null;
    _isInitialized = false;
    developer.log('LlamaCppLlmService disposed.', name: 'LlamaCppLlmService');
  }
}

