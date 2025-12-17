import 'package:flutter/material.dart';
import 'package:flutter_sdk/llm_helper.dart';
import 'package:logger/logger.dart';

import '../theme/app_theme.dart';
import '../widgets/chat_message_widget.dart';
import '../widgets/quality_slider.dart';

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

  LLMInference? _llmModel;
  bool _isLoading = false;
  bool _isGenerating = false;
  String _status = 'Initializing...';

  // Generation parameters
  int _maxTokens = 100;
  double _temperature = 0.7;

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    setState(() {
      _isLoading = true;
      _status = 'Loading AI model...';
    });

    try {
      // NOTE: For demo purposes, we'll show the UI without a real model
      // In production, uncomment this and provide an actual ONNX model:
      // _llmModel = await LLMInference.load(
      //   'assets/llm_models/model.onnx',
      //   vocabPath: 'assets/llm_models/vocab.json',
      //   maxLength: 512,
      // );

      // Simulate model loading for demo
      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        _isLoading = false;
        _status = 'Ready';
      });

      // Add welcome message
      _addMessage(
        ChatMessage(
          text: 'Hello! I\'m your local AI assistant. Ask me anything!\n\nNote: This is a demo UI. To enable real inference, please add an ONNX model to assets/llm_models/',
          isUser: false,
        ),
      );
    } catch (e, stackTrace) {
      logger.e('Error loading model', error: e, stackTrace: stackTrace);
      setState(() {
        _isLoading = false;
        _status = 'Error: $e';
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

    // Add user message
    _addMessage(ChatMessage(text: question, isUser: true));
    _questionController.clear();

    setState(() => _isGenerating = true);

    try {
      if (_llmModel != null) {
        // Real inference
        final response = await _llmModel!.generate(
          question,
          maxNewTokens: _maxTokens,
          temperature: _temperature,
        );

        _addMessage(ChatMessage(text: response, isUser: false));
      } else {
        // Demo response
        await Future.delayed(const Duration(seconds: 2));
        _addMessage(
          ChatMessage(
            text: _generateDemoResponse(question),
            isUser: false,
          ),
        );
      }
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

  String _generateDemoResponse(String question) {
    // Simple demo responses
    final lowerQuestion = question.toLowerCase();

    if (lowerQuestion.contains('hello') || lowerQuestion.contains('hi')) {
      return 'Hello! How can I assist you today?';
    } else if (lowerQuestion.contains('how are you')) {
      return 'I\'m functioning well, thank you! I\'m a local AI assistant running on your device.';
    } else if (lowerQuestion.contains('what') && lowerQuestion.contains('you')) {
      return 'I\'m a local AI assistant that runs entirely on your device using ONNX Runtime. Once you add a language model, I can answer questions, help with tasks, and more - all without internet!';
    } else if (lowerQuestion.contains('2+2') || lowerQuestion.contains('2 + 2')) {
      return 'The answer is 4!';
    } else {
      return 'That\'s an interesting question! This is a demo response. To get real AI-powered answers, please add an ONNX language model to the assets/llm_models/ directory.';
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

    // Add welcome message back
    _addMessage(
      ChatMessage(
        text: 'Chat cleared. How can I help you?',
        isUser: false,
      ),
    );
  }

  @override
  void dispose() {
    _questionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Q&A'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
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
          if (_isLoading)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppTheme.spacingSm),
              color: AppTheme.primary.withOpacity(0.1),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
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
            child: _messages.isEmpty && !_isLoading
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
                    enabled: !_isLoading && !_isGenerating,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingSm),
                FloatingActionButton(
                  onPressed: _isLoading || _isGenerating ? null : _sendMessage,
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
              Icons.psychology_rounded,
              size: 80,
              color: AppTheme.textSecondary.withOpacity(0.3),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Text(
              'No messages yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              'Start a conversation with your local AI assistant',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary.withOpacity(0.7),
                  ),
              textAlign: TextAlign.center,
            ),
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
              Text(
                'Generation Settings',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: AppTheme.spacingLg),
              QualitySlider(
                label: 'Max Tokens',
                value: _maxTokens.toDouble(),
                min: 50,
                max: 500,
                divisions: 9,
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
