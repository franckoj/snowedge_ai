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
      if (Platform.isMacOS) {
        // Use Homebrew-installed llama.cpp library
        Llama.libraryPath = '/opt/homebrew/lib/libllama.dylib';
      } else if (Platform.isLinux) {
        Llama.libraryPath = 'libllama.so';
      } else if (Platform.isWindows) {
        Llama.libraryPath = 'llama.dll';
      } else if (Platform.isAndroid || Platform.isIOS) {
        // Mobile platforms handle library loading differently
        Llama.libraryPath = '';
      }

      // Configure ModelParams
      final modelParams = ModelParams();
      modelParams.nGpuLayers = model.config['gpuLayers'] as int? ?? 0;

      // Configure ContextParams
      final contextParams = ContextParams();
      contextParams.nCtx = model.config['contextLength'] as int? ?? 2048;
      contextParams.nPredict = -1; // Unlimited generation
      contextParams.nBatch = 512;

      // Create Llama instance with model
      // Constructor: Llama(String modelPath, [ModelParams? modelParams, ContextParams? contextParams, ...])
      _llama = Llama(
        modelPath,
        modelParams,
        contextParams,
      );
      _logger.i('Model loaded successfully');
    } on FileSystemException catch (e) {
      _logger.e('llama.cpp library not found', error: e);
      await unload();
      throw RuntimeException(
        'llama.cpp library is not available on this system.\n\n'
        'To use llama.cpp models, you need to build the native library.\n'
        'For now, please use ONNX models instead.\n\n'
        'Alternative: The app works great with ONNX models!',
        e,
      );
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
      _logger.d('Setting prompt...');
      _llama!.setPrompt(prompt);
      _logger.d('Prompt set successfully');

      int tokenCount = 0;
      _logger.d('Starting token generation loop');
      
      while (true) {
        final result = _llama!.getNext();
        final token = result.$1;
        final done = result.$2;
        
        if (token.isNotEmpty) {
          _logger.d('Token: $token');
          yield token;
          tokenCount++;
        } else {
             // If token is empty but not done, we might be hitting a case where we should wait or it's just an internal step
             // but let's log it.
             // _logger.d('Empty token received, done=$done');
        }
        
        if (done) {
          _logger.d('Generation done');
          break;
        }
        
        // Check if we've reached max tokens
        if (tokenCount >= config.maxTokens) {
          _logger.d('Max tokens reached');
          break;
        }
        
        // Safety break for infinite loops if needed, though getNext() is blocking usually.
        // await Future.delayed(Duration.zero); // Yield to event loop just in case
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
