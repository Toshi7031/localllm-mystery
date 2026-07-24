import 'dart:developer' as developer;
import 'package:llama_cpp_dart/llama_cpp_dart.dart';
import 'llm_generation_config.dart';
import 'llm_service.dart';

/// llama.cppと連携するためのクラス。
class LlamaCppLlmService implements LlmService {
  final String modelPath;
  
  @override
  final String modelFamily;
  
  LlamaEngine? _engine;
  bool _isInitialized = false;

  LlamaCppLlmService({required this.modelPath, required this.modelFamily});

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
    void Function(String token)? onToken,
  }) async {
    if (!_isInitialized || _engine == null) {
      throw StateError('LlamaCppLlmService is not initialized.');
    }
    
    developer.log('Generating reply for NPC $npcId...', name: 'LlamaCppLlmService');
    
    final maxTokens = config?.maxTokens ?? const LlmGenerationConfig().maxTokens;
    final session = await _engine!.createSession();
    final stopTokens = ['<end_of_turn>', '<|eot_id|>', '<|im_end|>'];
    
    try {
      final buffer = StringBuffer();
      await for (final event in session.generate(
        prompt: prompt,
        maxTokens: maxTokens,
        addSpecial: true,
      )) {
        if (event is TokenEvent) {
          onToken?.call(event.text);
          buffer.write(event.text);
          final currentText = buffer.toString();
          
          bool shouldStop = false;
          for (final token in stopTokens) {
            if (currentText.contains(token)) {
              shouldStop = true;
              break;
            }
          }
          if (shouldStop) {
            break;
          }
        }
      }
      
      var result = buffer.toString();
      for (final token in stopTokens) {
        final index = result.indexOf(token);
        if (index != -1) {
          result = result.substring(0, index);
        }
      }
      result = result.trim();
      
      developer.log('Generated: $result', name: 'LlamaCppLlmService');
      return result;
    } finally {
      await session.dispose();
    }
  }

  @override
  Future<String> generateEvidenceReaction({
    required String npcId,
    required String evidenceId,
    required String prompt,
    LlmGenerationConfig? config,
    void Function(String token)? onToken,
  }) async {
    if (!_isInitialized || _engine == null) {
      throw StateError('LlamaCppLlmService is not initialized.');
    }
    
    developer.log('Generating reaction for NPC $npcId to evidence $evidenceId...', name: 'LlamaCppLlmService');
    
    final maxTokens = config?.maxTokens ?? const LlmGenerationConfig().maxTokens;
    final session = await _engine!.createSession();
    final stopTokens = ['<end_of_turn>', '<|eot_id|>', '<|im_end|>'];
    
    try {
      final buffer = StringBuffer();
      await for (final event in session.generate(
        prompt: prompt,
        maxTokens: maxTokens,
        addSpecial: true,
      )) {
        if (event is TokenEvent) {
          onToken?.call(event.text);
          buffer.write(event.text);
          final currentText = buffer.toString();
          
          bool shouldStop = false;
          for (final token in stopTokens) {
            if (currentText.contains(token)) {
              shouldStop = true;
              break;
            }
          }
          if (shouldStop) {
            break;
          }
        }
      }
      
      var result = buffer.toString();
      for (final token in stopTokens) {
        final index = result.indexOf(token);
        if (index != -1) {
          result = result.substring(0, index);
        }
      }
      result = result.trim();
      
      return result;
    } finally {
      await session.dispose();
    }
  }

  @override
  Future<void> dispose() async {
    await _engine?.dispose();
    _engine = null;
    _isInitialized = false;
    developer.log('LlamaCppLlmService disposed.', name: 'LlamaCppLlmService');
  }
}

