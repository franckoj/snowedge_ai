import 'dart:io';
import 'package:llama_cpp_dart/llama_cpp_dart.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

import '../models/model_info.dart';
import 'inference_runtime.dart';

final _logger = Logger();

/// llama.cpp runtime implementation using high-level wrapper
class LlamaCppInferenceRuntime implements InferenceRuntime {
  Llama? _llama;
  ModelInfo? _currentModel;

  @override
  RuntimeType get runtime => RuntimeType.llamaCpp;

  @override
  bool get isLoaded => _llama != null;

  @override
  ModelInfo? get currentModel => _currentModel;

  @override
  Future<void> loadModel(ModelInfo model) async {
    try {
      _logger.i('Loading llama.cpp model: ${model.name}');

      // Get model path
      final modelPath = await _getModelPath(model);

      if (!File(modelPath).existsSync()) {
        throw RuntimeException('Model file not found: $modelPath');
      }

      // Set library path (platform-specific)
      // The package will handle finding the right library
      // Note: This might need adjustment based on platform
      if (Platform.isMacOS) {
        Llama.libraryPath = 'libllama.dylib';
      } else if (Platform.isLinux) {
        Llama.libraryPath = 'libllama.so';
      } else if (Platform.isWindows) {
        Llama.libraryPath = 'llama.dll';
      } else if (Platform.isAndroid || Platform.isIOS) {
        // Mobile platforms handle library loading differently
        // The package should auto-detect
        Llama.libraryPath = '';
      }

      // Create Llama instance with model
      _llama = Llama(
        modelPath,
        // Optional parameters can be configured from model.config
        // nCtx: model.config['contextLength'] as int? ?? 2048,
        // nGpuLayers: model.config['gpuLayers'] as int? ?? 0,
      );

      _currentModel = model;
      _logger.i('Model loaded successfully');
    } catch (e, stackTrace) {
      _logger.e('Failed to load model', error: e, stackTrace: stackTrace);
      await unload();
      throw RuntimeException('Failed to load llama.cpp model: $e', e);
    }
  }

  @override
  Future<String> generate(String prompt, GenerationConfig config) async {
    if (!isLoaded || _llama == null) {
      throw RuntimeException('No model loaded');
    }

    try {
      _logger.d('Generating response for prompt: ${prompt.substring(0, prompt.length > 50 ? 50 : prompt.length)}...');

      // Set the prompt
      _llama!.setPrompt(prompt);

      // Generate tokens and collect response
      final buffer = StringBuffer();
      
      while (true) {
        final result = _llama!.getNext();
        final token = result.$1;  // First element of record
        final done = result.$2;   // Second element of record
        
        if (token.isNotEmpty) {
          buffer.write(token);
        }
        
        if (done) break;
        
        // Check if we've reached max tokens
        if (buffer.length >= config.maxTokens) break;
      }

      return buffer.toString();
    } catch (e) {
      _logger.e('Generation failed', error: e);
      throw RuntimeException('Generation failed: $e', e);
    }
  }

  @override
  Stream<String> generateStream(String prompt, GenerationConfig config) async* {
    if (!isLoaded || _llama == null) {
      throw RuntimeException('No model loaded');
    }

    try {
      _logger.d('Streaming generation for prompt: ${prompt.substring(0, prompt.length > 50 ? 50 : prompt.length)}...');

      // Set the prompt
      _llama!.setPrompt(prompt);

      int tokenCount = 0;
      
      while (true) {
        final result = _llama!.getNext();
        final token = result.$1;  // First element of record
        final done = result.$2;   // Second element of record
        
        if (token.isNotEmpty) {
          yield token;
          tokenCount++;
        }
        
        if (done) break;
        
        // Check if we've reached max tokens
        if (tokenCount >= config.maxTokens) break;
      }
    } catch (e) {
      _logger.e('Streaming generation failed', error: e);
      throw RuntimeException('Streaming generation failed: $e', e);
    }
  }

  @override
  Future<void> unload() async {
    _logger.i('Unloading llama.cpp model');
    
    if (_llama != null) {
      _llama!.dispose();
      _llama = null;
    }
    
    _currentModel = null;
  }

  @override
  Future<void> dispose() async {
    await unload();
  }

  Future<String> _getModelPath(ModelInfo model) async {
    final dir = await getApplicationDocumentsDirectory();
    return '${dir.path}/models/llamacpp/${model.filename}';
  }
}
