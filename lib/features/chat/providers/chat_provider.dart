import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class ChatProvider with ChangeNotifier {
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String _error = '';
  final GenerativeModel _model;
  ChatSession? _chat;

  ChatProvider()
    : _model = GenerativeModel(
        model: 'gemini-2.0-flash',
        apiKey: 'AIzaSyDdTQQqEcxFLNzFadFKGQxvzjjKWgTQ_pY',
      ) {
    _initializeChat();
  }

  void _initializeChat() {
    _chat = _model.startChat();
  }

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    try {
      _isLoading = true;
      _error = '';
      notifyListeners();

      // Add user message
      _messages.add(
        ChatMessage(text: text, isUser: true, timestamp: DateTime.now()),
      );
      notifyListeners();

      // Get AI response
      if (_chat == null) {
        _initializeChat();
      }

      final response = await _chat!.sendMessage(
        Content.text(
          'You are Serenity, a compassionate mental wellness AI companion. '
          'Your responses should be empathetic, supportive, and focused on mental well-being. '
          'Keep responses concise and helpful. Here is the user message: $text'
          "If someone expresses distress, offer comfort and suggest seeking professional help if needed. "
          "Always use a warm and caring tone.",
        ),
      );

      // Add AI response
      _messages.add(
        ChatMessage(
          text:
              response.text ??
              'I apologize, but I cannot process that right now.',
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
    } catch (e) {
      _error = 'Failed to send message. Please try again.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearChat() {
    _messages.clear();
    _error = '';
    _initializeChat(); // Reset the chat session
    notifyListeners();
  }
}
