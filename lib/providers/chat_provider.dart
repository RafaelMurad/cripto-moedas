import 'package:flutter/foundation.dart';
import '../models/chat_message.dart';
import '../services/ai_assistant_service.dart';

/// Provider for AI chat state management.
class ChatProvider extends ChangeNotifier {
  final AIAssistantService _aiService = AIAssistantService();

  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  List<String> _suggestedQuestions = [];

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isTyping => _isTyping;
  List<String> get suggestedQuestions => _suggestedQuestions;

  ChatProvider() {
    _initializeChat();
  }

  void _initializeChat() {
    // Add welcome message
    _messages.add(ChatMessage.system(
      'Welcome to your AI Crypto Learning Assistant! Ask me anything about blockchain, cryptocurrency, or how this wallet works.',
    ));
    _suggestedQuestions = [
      'What is blockchain?',
      'How do wallets work?',
      'Explain private keys',
    ];
    notifyListeners();
  }

  /// Send a message and get AI response
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty) return;

    // Add user message
    final userMessage = ChatMessage.user(content);
    _messages.add(userMessage);
    _isTyping = true;
    _suggestedQuestions = [];
    notifyListeners();

    try {
      // Simulate typing delay for better UX
      await Future.delayed(const Duration(milliseconds: 500));

      // Get AI response
      final response = await _aiService.generateResponse(content);
      _messages.add(response);

      // Update suggested questions based on response
      if (response.relatedTopics != null && response.relatedTopics!.isNotEmpty) {
        _suggestedQuestions = _aiService.getSuggestedQuestions(
          response.relatedTopics!.first,
        );
      }
    } catch (e) {
      _messages.add(ChatMessage.assistant(
        'I apologize, but I encountered an error processing your question. Please try again.',
      ));
    } finally {
      _isTyping = false;
      notifyListeners();
    }
  }

  /// Handle suggested question tap
  void askSuggestedQuestion(String question) {
    sendMessage(question);
  }

  /// Clear chat history
  void clearChat() {
    _messages.clear();
    _initializeChat();
  }

  /// Get all available learning topics
  List<LearningTopic> getTopics() {
    return LearningTopic.allTopics;
  }

  /// Get topics by category
  Map<String, List<LearningTopic>> getTopicsByCategory() {
    final Map<String, List<LearningTopic>> categorized = {};
    for (final topic in LearningTopic.allTopics) {
      categorized.putIfAbsent(topic.category, () => []);
      categorized[topic.category]!.add(topic);
    }
    return categorized;
  }
}
