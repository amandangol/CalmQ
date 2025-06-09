import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:io';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final String? imageUrl;
  final bool isImage;
  final String? imageCaption;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.imageUrl,
    this.isImage = false,
    this.imageCaption,
  });
}

class ChatProvider with ChangeNotifier {
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String _error = '';
  final GenerativeModel _model;
  final GenerativeModel _visionModel;
  ChatSession? _chat;
  final FlutterTts _flutterTts = FlutterTts();
  bool _isSpeaking = false;
  String? _currentSpeakingMessage;

  ChatProvider()
    : _model = GenerativeModel(
        model: 'gemini-2.0-flash',
        apiKey: 'AIzaSyDdTQQqEcxFLNzFadFKGQxvzjjKWgTQ_pY',
      ),
      _visionModel = GenerativeModel(
        model: 'gemini-2.0-flash',
        apiKey: 'AIzaSyDdTQQqEcxFLNzFadFKGQxvzjjKWgTQ_pY',
      ) {
    _initializeChat();
    _initializeTts();
  }

  void _initializeTts() async {
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setPitch(1.0);
    await _flutterTts.setSpeechRate(0.5);

    // Add completion handler
    _flutterTts.setCompletionHandler(() {
      _isSpeaking = false;
      _currentSpeakingMessage = null;
      notifyListeners();
    });
  }

  void _initializeChat() {
    _chat = _model.startChat();
    _messages.clear();
    _error = '';
    _isLoading = false;
    _isSpeaking = false;
    _currentSpeakingMessage = null;
    notifyListeners();
  }

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  String get error => _error;
  bool get isSpeaking => _isSpeaking;
  String? get currentSpeakingMessage => _currentSpeakingMessage;

  Future<void> speak(String text) async {
    if (_isSpeaking) {
      await stopSpeaking();
      return;
    }

    _currentSpeakingMessage = text;
    _isSpeaking = true;
    notifyListeners();
    await _flutterTts.speak(text);
  }

  Future<void> stopSpeaking() async {
    await _flutterTts.stop();
    _isSpeaking = false;
    _currentSpeakingMessage = null;
    notifyListeners();
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessage(
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    _messages.add(userMessage);
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _generateResponse(text);
      final aiMessage = ChatMessage(
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
      );

      _messages.add(aiMessage);
    } catch (e) {
      _error = 'Failed to get response: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> _generateResponse(String text) async {
    if (_chat == null) {
      _initializeChat();
    }

    final response = await _chat!.sendMessage(
      Content.text(
        'You are Serenity, a compassionate mental wellness AI companion. '
        'Your responses should be empathetic, supportive, and focused on mental well-being. '
        'Keep responses concise and helpful. Here is the user message: $text\n\n'
        'If someone expresses distress, offer comfort and suggest seeking professional help if needed. '
        'Always use a warm and caring tone.',
      ),
    );

    return response.text ?? 'I apologize, but I cannot process that right now.';
  }

  Future<void> sendImage(File imageFile, {String? caption}) async {
    final userMessage = ChatMessage(
      text: caption ?? 'Sent an image',
      isUser: true,
      timestamp: DateTime.now(),
      imageUrl: imageFile.path,
      isImage: true,
      imageCaption: caption,
    );

    _messages.add(userMessage);
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _analyzeImage(imageFile, caption);
      final aiMessage = ChatMessage(
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
      );

      _messages.add(aiMessage);
    } catch (e) {
      _error = 'Failed to process image: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> _analyzeImage(File imageFile, String? caption) async {
    try {
      final imageBytes = await imageFile.readAsBytes();
      final prompt = caption != null
          ? 'Analyze this image and respond to the user\'s query: "$caption". '
                'Be empathetic and supportive in your response.'
          : 'Analyze this image and provide a supportive, empathetic response. '
                'Focus on any emotional or mental wellness aspects you notice.';

      final response = await _visionModel.generateContent([
        Content.multi([TextPart(prompt), DataPart('image/jpeg', imageBytes)]),
      ]);

      return response.text ??
          'I see the image, but I\'m having trouble analyzing it right now.';
    } catch (e) {
      return 'I apologize, but I\'m having trouble processing the image. Please try again.';
    }
  }

  void clearChat() {
    _messages.clear();
    _error = '';
    _isLoading = false;
    _isSpeaking = false;
    _currentSpeakingMessage = null;
    _initializeChat();
    notifyListeners();
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _flutterTts.setCompletionHandler(() {});
    _messages.clear();
    _chat = null;
    super.dispose();
  }
}
