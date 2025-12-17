import 'dart:io';
import 'package:llama_cpp_dart/llama_cpp_dart.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

import '../models/model_info.dart';
import 'inference_runtime.dart';

final _logger = Logger();

/// llama.cpp runtime implementation
class LlamaCppInferenceRuntime implements InferenceRuntime {
  LlamaModel? _model;
  LlamaContext? _context;
  ModelInfo? _currentModel;

  @override
  RuntimeType get runtime => RuntimeType.llamaCpp;

  @override
  bool get isLoaded => _model != null && _context != null;

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

      // Extract config
      final contextLength = model.config['contextLength'] as int? ?? 2048;
      final gpuLayers = model.config['gpuLayers'] as int? ?? 0;

      // Load model
      _model = await LlamaModel.loadFromFile(
        modelPath,
        contextLength: contextLength,
        gpuLayersToOffload: gpuLayers,
      );

      // Create context
      _context = _model!.createContext();

      _currentModel = model;
      _logger.i('Model loaded successfully');
    } catch (e) {
      _logger.e('Failed to load model', error: e);
      await unload();
      throw RuntimeException('Failed to load llama.cpp model', e);
    }
  }

  @override
  Future<String> generate(String prompt, GenerationConfig config) async {
    if (!isLoaded) {
      throw RuntimeException('No model loaded');
    }

    try {
      final buffer = StringBuffer();

      await for (final token in generateStream(prompt, config)) {
        buffer.write(token);
      }

      return buffer.toString();
    } catch (e) {
      _logger.e('Generation failed', error: e);
      throw RuntimeException('Generation failed', e);
    }
  }

  @override
  Stream<String> generateStream(String prompt, GenerationConfig config) async* {
    if (!isLoaded || _context == null) {
      throw RuntimeException('No model loaded');
    }

    try {
      _logger.d('Generating with prompt: ${prompt.substring(0, prompt.length > 50 ? 50 : prompt.length)}...');

      // Generate tokens
      await for (final token in _context!.generate(
        prompt,
        temperature: config.temperature,
        maxTokens: config.maxTokens,
        topK: config.topK,
        topP: config.topP,
        repeatPenalty: config.repeatPenalty,
      )) {
        yield token;
      }
    } catch (e) {
      _logger.e('Streaming generation failed', error: e);
      throw RuntimeException('Streaming generation failed', e);
    }
  }

  @override
  Future<void> unload() async {
    _logger.i('Unloading model');

    _context?.dispose();
    _context = null;

    _model?.dispose();
    _model = null;

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
