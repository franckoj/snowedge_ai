// Temporarily disabled until llama_cpp_dart API is verified
// import 'package:llama_cpp_dart/llama_cpp_dart.dart';
import 'package:logger/logger.dart';

import '../models/model_info.dart';
import 'inference_runtime.dart';

final _logger = Logger();

/// llama.cpp runtime implementation
/// TODO: Verify llama_cpp_dart package API and update implementation
class LlamaCppInferenceRuntime implements InferenceRuntime {
  ModelInfo? _currentModel;

  @override
  RuntimeType get runtime => RuntimeType.llamaCpp;

  @override
  bool get isLoaded => false; // Temporarily disabled

  @override
  ModelInfo? get currentModel => _currentModel;

  @override
  Future<void> loadModel(ModelInfo model) async {
    throw RuntimeException(
      'llama.cpp runtime temporarily disabled. '
      'Please use ONNX models or help update the llama_cpp_dart integration.',
    );
  }

  @override
  Future<String> generate(String prompt, GenerationConfig config) async {
    throw RuntimeException('llama.cpp runtime not available');
  }

  @override
  Stream<String> generateStream(String prompt, GenerationConfig config) async* {
    throw RuntimeException('llama.cpp runtime not available');
  }

  @override
  Future<void> unload() async {
    _logger.i('Unloading model (llama.cpp disabled)');
    _currentModel = null;
  }

  @override
  Future<void> dispose() async {
    await unload();
  }
}
