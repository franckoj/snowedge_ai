import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/model_info.dart';
import '../services/inference_runtime.dart';
import '../services/onnx_runtime.dart';
import '../services/llamacpp_runtime.dart';
import '../services/model_manager.dart';
import '../theme/app_theme.dart';
import '../widgets/chat_message_widget.dart';
import '../widgets/quality_slider.dart';
import 'model_selection_screen.dart';

final logger = Logger();

class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen> {
  final TextEditingController _questionController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  final ModelManager _modelManager = ModelManager();

  InferenceRuntime? _runtime;
  ModelInfo? _selectedModel;
  bool _isLoading = false;
  bool _isGenerating = false;
  String _status = 'No model loaded';

  // Generation parameters
  int _maxTokens = 256;
  double _temperature = 0.7;

  @override
  void initState() {
    super.initState();
    _loadLastSelectedModel();
  }

  Future<void> _loadLastSelectedModel() async {
    final prefs = await SharedPreferences.getInstance();
    final modelId = prefs.getString('last_selected_model');

    if (modelId != null) {
      await _modelManager.getAvailableModels();
      final model = _modelManager.getModelById(modelId);

      if (model != null && _modelManager.isModelDownloaded(modelId)) {
        await _loadModel(model);
      } else {
        _showWelcomeMessage();
      }
    } else {
      _showWelcomeMessage();
    }
  }

  void _showWelcomeMessage() {
    _addMessage(
      ChatMessage(
        text: 'Welcome! Tap the model icon above to select and download an AI model.',
        isUser: false,
      ),
    );
  }

  Future<void> _selectModel() async {
    final model = await Navigator.push<ModelInfo>(
      context,
      MaterialPageRoute(builder: (context) => const ModelSelectionScreen()),
    );

    if (model != null) {
      await _loadModel(model);
    }
  }

  Future<void> _loadModel(ModelInfo model) async {
    setState(() {
      _isLoading = true;
      _status = 'Loading ${model.name}...';
    });

    try {
      // Unload previous model
      if (_runtime != null) {
        await _runtime!.unload();
      }

      // Create appropriate runtime
      _runtime = model.runtime == RuntimeType.onnx
          ? OnnxInferenceRuntime()
          : LlamaCppInferenceRuntime();

      // Load model
      await _runtime!.loadModel(model);

      // Save preference
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_selected_model', model.id);

      setState(() {
        _selectedModel = model;
        _isLoading = false;
        _status = 'Ready';
      });

      // Add confirmation message
      _addMessage(
        ChatMessage(
          text: 'Loaded ${model.name}. How can I help you?',
          isUser: false,
        ),
      );
    } catch (e, stackTrace) {
      logger.e('Error loading model', error: e, stackTrace: stackTrace);
      setState(() {
        _isLoading = false;
        _status = 'Error loading model';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load model: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  Future<void> _sendMessage() async {
    final question = _questionController.text.trim();

    if (question.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a question')),
      );
      return;
    }

    if (_runtime == null || !_runtime!.isLoaded) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a model first')),
      );
      return;
    }

    // Add user message
    _addMessage(ChatMessage(text: question, isUser: true));
    _questionController.clear();

    setState(() => _isGenerating = true);

    try {
      final config = GenerationConfig(
        maxTokens: _maxTokens,
        temperature: _temperature,
      );

      final response = await _runtime!.generate(question, config);
      _addMessage(ChatMessage(text: response, isUser: false));
    } catch (e) {
      logger.e('Error generating response', error: e);
      _addMessage(
        ChatMessage(
          text: 'Sorry, I encountered an error: $e',
          isUser: false,
        ),
      );
    } finally {
      setState(() => _isGenerating = false);
    }
  }

  void _addMessage(ChatMessage message) {
    setState(() {
      _messages.add(message);
    });

    // Auto-scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _clearChat() {
    setState(() {
      _messages.clear();
    });
  }

  @override
  void dispose() {
    _questionController.dispose();
    _scrollController.dispose();
    _runtime?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedModel?.name ?? 'AI Q&A'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Model selector
          IconButton(
            icon: const Icon(Icons.model_training_rounded),
            onPressed: _selectModel,
            tooltip: 'Select model',
          ),
          if (_messages.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded),
              onPressed: _clearChat,
              tooltip: 'Clear chat',
            ),
          IconButton(
            icon: const Icon(Icons.settings_rounded),
            onPressed: _showSettings,
            tooltip: 'Settings',
          ),
        ],
      ),
      body: Column(
        children: [
          // Status indicator
          if (_selectedModel != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.spacingSm),
              color: _isLoading
                  ? AppTheme.primary.withOpacity(0.1)
                  : Colors.green.withOpacity(0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isLoading)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  if (!_isLoading)
                    Icon(
                      Icons.check_circle_rounded,
                      size: 16,
                      color: Colors.green.shade700,
                    ),
                  const SizedBox(width: AppTheme.spacingSm),
                  Text(
                    _status,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),

          // Chat messages
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppTheme.spacingMd,
                    ),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return ChatMessageWidget(message: _messages[index]);
                    },
                  ),
          ),

          // Generating indicator
          if (_isGenerating)
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingMd,
                vertical: AppTheme.spacingSm,
              ),
              child: Row(
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  const SizedBox(width: AppTheme.spacingSm),
                  Text(
                    'Thinking...',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                  ),
                ],
              ),
            ),

          // Input area
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surface,
              border: Border(
                top: BorderSide(
                  color: AppTheme.textSecondary.withOpacity(0.1),
                  width: 1,
                ),
              ),
            ),
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _questionController,
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                    decoration: const InputDecoration(
                      hintText: 'Ask me anything...',
                      border: OutlineInputBorder(),
                    ),
                    enabled: !_isLoading && !_isGenerating && _runtime != null,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingSm),
                FloatingActionButton(
                  onPressed: _isLoading || _isGenerating || _runtime == null
                      ? null
                      : _sendMessage,
                  mini: true,
                  child: Icon(
                    _isGenerating ? Icons.stop_rounded : Icons.send_rounded,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _selectedModel == null
                  ? Icons.model_training_rounded
                  : Icons.psychology_rounded,
              size: 80,
              color: AppTheme.textSecondary.withOpacity(0.3),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Text(
              _selectedModel == null
                  ? 'No model selected'
                  : 'No messages yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              _selectedModel == null
                  ? 'Tap the model icon above to select and download a model'
                  : 'Start a conversation with your local AI assistant',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary.withOpacity(0.7),
                  ),
              textAlign: TextAlign.center,
            ),
            if (_selectedModel == null) ...[
              const SizedBox(height: AppTheme.spacingLg),
              FilledButton.icon(
                onPressed: _selectModel,
                icon: const Icon(Icons.download_rounded),
                label: const Text('Browse Models'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusLg),
        ),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: const EdgeInsets.all(AppTheme.spacingXl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Generation Settings',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  if (_selectedModel != null)
                    Chip(
                      label: Text(_selectedModel!.runtimeName),
                      avatar: Icon(
                        _selectedModel!.runtime == RuntimeType.onnx
                            ? Icons.memory_rounded
                            : Icons.hub_rounded,
                        size: 16,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingLg),
              QualitySlider(
                label: 'Max Tokens',
                value: _maxTokens.toDouble(),
                min: 50,
                max: 1000,
                divisions: 19,
                onChanged: (value) {
                  setModalState(() => _maxTokens = value.toInt());
                  setState(() => _maxTokens = value.toInt());
                },
                labelFormatter: (val) => val.toInt().toString(),
              ),
              const SizedBox(height: AppTheme.spacingMd),
              QualitySlider(
                label: 'Temperature',
                value: _temperature,
                min: 0.1,
                max: 1.5,
                divisions: 14,
                onChanged: (value) {
                  setModalState(() => _temperature = value);
                  setState(() => _temperature = value);
                },
                labelFormatter: (val) => val.toStringAsFixed(1),
              ),
              const SizedBox(height: AppTheme.spacingMd),
              Text(
                'Higher temperature = more creative responses\nLower temperature = more focused responses',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
              ),
              const SizedBox(height: AppTheme.spacingLg),
            ],
          ),
        ),
      ),
    );
  }
}
