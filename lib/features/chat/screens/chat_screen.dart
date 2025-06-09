import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../providers/chat_provider.dart';
import '../../../app_theme.dart';
import '../../../widgets/custom_confirmation_dialog.dart';
import '../../../widgets/custom_app_bar.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _textFieldFocusNode = FocusNode();
  late AnimationController _sendButtonAnimationController;
  late Animation<double> _sendButtonScaleAnimation;
  bool _isComposing = false;
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  late AnimationController _listeningAnimationController;
  late Animation<double> _listeningScaleAnimation;
  final ImagePicker _imagePicker = ImagePicker();
  File? _selectedImage;
  String? _imageCaption;
  late ChatProvider _chatProvider;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _chatProvider = context.read<ChatProvider>();
    _sendButtonAnimationController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );
    _sendButtonScaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _sendButtonAnimationController,
        curve: Curves.elasticOut,
      ),
    );

    _listeningAnimationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _listeningScaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _listeningAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    _messageController.addListener(_onTextChanged);
    _initializeSpeech();

    // Auto-scroll to bottom when new messages arrive
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _chatProvider.addListener(_scrollToBottomIfNeeded);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isDisposed) {
      _chatProvider = context.read<ChatProvider>();
    }
  }

  void _initializeSpeech() async {
    await _speech.initialize(
      onStatus: (status) {
        if (status == 'done') {
          setState(() => _isListening = false);
        }
      },
      onError: (error) {
        setState(() => _isListening = false);
      },
    );
  }

  void _startListening() async {
    if (!_isListening) {
      bool available = await _speech.initialize();
      if (available) {
        setState(() => _isListening = true);
        _listeningAnimationController.repeat(reverse: true);
        _speech.listen(
          onResult: (result) {
            setState(() {
              _messageController.text = result.recognizedWords;
              if (result.finalResult) {
                _isListening = false;
                _listeningAnimationController.stop();
                if (_messageController.text.isNotEmpty) {
                  _sendMessage();
                }
              }
            });
          },
        );
      }
    } else {
      setState(() => _isListening = false);
      _listeningAnimationController.stop();
      _speech.stop();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _listeningAnimationController.dispose();
    _messageController.removeListener(_onTextChanged);
    _messageController.dispose();
    _scrollController.dispose();
    _textFieldFocusNode.dispose();
    _sendButtonAnimationController.dispose();

    // Stop any ongoing speech when leaving the screen
    if (mounted) {
      _chatProvider.stopSpeaking();
    }

    super.dispose();
  }

  void _onTextChanged() {
    final isComposing = _messageController.text.trim().isNotEmpty;
    if (_isComposing != isComposing) {
      setState(() {
        _isComposing = isComposing;
      });
      if (isComposing) {
        _sendButtonAnimationController.forward();
      } else {
        _sendButtonAnimationController.reverse();
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _scrollToBottomIfNeeded() {
    if (_scrollController.hasClients) {
      final threshold = _scrollController.position.maxScrollExtent - 100;
      if (_scrollController.position.pixels > threshold) {
        _scrollToBottom();
      }
    }
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty || _selectedImage != null) {
      HapticFeedback.lightImpact();

      if (_selectedImage != null) {
        _chatProvider.sendImage(_selectedImage!, caption: text);
        setState(() {
          _selectedImage = null;
        });
      } else {
        _chatProvider.sendMessage(text);
      }

      _messageController.clear();
      Future.delayed(Duration(milliseconds: 100), () {
        _scrollToBottom();
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to pick image: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _removeSelectedImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  void _copyMessage(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Message copied to clipboard'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _chatProvider.stopSpeaking();
        return true;
      },
      child: Scaffold(
        backgroundColor: Color(0xFFF5F7FA),
        resizeToAvoidBottomInset: true,
        body: Column(
          children: [
            CustomAppBar(
              title: 'Serenity',
              leadingIcon: Icons.chat_rounded,
              actions: [
                Container(
                  margin: EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: Icon(Icons.delete_outline, color: Colors.white),
                    onPressed: _chatProvider.messages.isEmpty
                        ? null
                        : () {
                            HapticFeedback.mediumImpact();
                            showDialog(
                              context: context,
                              builder: (context) => CustomConfirmationDialog(
                                title: 'Clear Chat',
                                message:
                                    'Are you sure you want to clear all messages? This action cannot be undone.',
                                confirmText: 'Clear',
                                cancelText: 'Cancel',
                                confirmColor: AppColors.error,
                                onConfirm: () {
                                  _chatProvider.clearChat();
                                  Navigator.of(context).pop();
                                },
                              ),
                            );
                          },
                  ),
                ),
              ],
            ),
            // Body content
            Expanded(
              child: Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFFF5F7FA), Color(0xFFE8ECF4)],
                      ),
                    ),
                  ),
                  Column(
                    children: [
                      Expanded(
                        child: _chatProvider.messages.isEmpty
                            ? _EmptyStateWidget()
                            : ListView.builder(
                                controller: _scrollController,
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                itemCount: _chatProvider.messages.length,
                                itemBuilder: (context, index) {
                                  final message = _chatProvider.messages[index];
                                  return AnimatedSlide(
                                    offset: Offset(0, 0),
                                    duration: Duration(milliseconds: 300),
                                    curve: Curves.easeOutCubic,
                                    child: AnimatedOpacity(
                                      opacity: 1.0,
                                      duration: Duration(milliseconds: 300),
                                      child: _ChatBubble(
                                        message: message,
                                        isLastMessage:
                                            index ==
                                            _chatProvider.messages.length - 1,
                                        onCopy: () =>
                                            _copyMessage(message.text),
                                        onSpeak: () =>
                                            _chatProvider.speak(message.text),
                                        isSpeaking:
                                            _chatProvider.isSpeaking &&
                                            _chatProvider
                                                    .currentSpeakingMessage ==
                                                message.text,
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                      if (_chatProvider.isLoading &&
                          _chatProvider.messages.isNotEmpty)
                        _TypingIndicator(),
                      if (_isListening)
                        Container(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          color: Colors.white.withOpacity(0.9),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedBuilder(
                                animation: _listeningScaleAnimation,
                                builder: (context, child) {
                                  return Transform.scale(
                                    scale: _listeningScaleAnimation.value,
                                    child: Icon(
                                      Icons.mic,
                                      color: AppColors.primary,
                                      size: 20,
                                    ),
                                  );
                                },
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Listening...',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        padding: EdgeInsets.fromLTRB(
                          16,
                          12,
                          16,
                          16 + MediaQuery.of(context).viewInsets.bottom * 0.05,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: Offset(0, -5),
                            ),
                          ],
                        ),
                        child: SafeArea(
                          child: _MessageInputWidget(
                            controller: _messageController,
                            focusNode: _textFieldFocusNode,
                            isComposing: _isComposing,
                            onSend: _sendMessage,
                            sendButtonAnimation: _sendButtonScaleAnimation,
                            isEnabled: !_chatProvider.isLoading,
                            isListening: _isListening,
                            onVoicePressed: _startListening,
                            onImagePick: _pickImage,
                            selectedImage: _selectedImage,
                            onRemoveImage: _removeSelectedImage,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyStateWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withOpacity(0.3),
                  AppColors.secondary.withOpacity(0.3),
                ],
              ),
              borderRadius: BorderRadius.circular(40),
            ),
            child: Image.asset("assets/images/chatbotimage.png", height: 40),
          ),
          SizedBox(height: 24),
          Text(
            'Hello! I\'m Serenity',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'I\'m here to listen and help. Start a conversation by typing a message below.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textLight,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  @override
  _TypingIndicatorState createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late List<Animation<double>> _dotAnimations;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _dotAnimations = List.generate(3, (index) {
      return Tween<double>(begin: 0.4, end: 1.0).animate(
        CurvedAnimation(
          parent: _animationController,
          curve: Interval(
            index * 0.2,
            (index * 0.2) + 0.4,
            curve: Curves.easeInOut,
          ),
        ),
      );
    });

    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.secondary],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Image.asset("assets/images/chatbotimage.png", height: 30),
          ),
          SizedBox(width: 8),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (index) {
                return AnimatedBuilder(
                  animation: _dotAnimations[index],
                  builder: (context, child) {
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 2),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppColors.textLight.withOpacity(
                          _dotAnimations[index].value,
                        ),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  },
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageInputWidget extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isComposing;
  final VoidCallback onSend;
  final Animation<double> sendButtonAnimation;
  final bool isEnabled;
  final bool isListening;
  final VoidCallback onVoicePressed;
  final VoidCallback onImagePick;
  final File? selectedImage;
  final VoidCallback onRemoveImage;

  const _MessageInputWidget({
    required this.controller,
    required this.focusNode,
    required this.isComposing,
    required this.onSend,
    required this.sendButtonAnimation,
    required this.isEnabled,
    required this.isListening,
    required this.onVoicePressed,
    required this.onImagePick,
    this.selectedImage,
    required this.onRemoveImage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (selectedImage != null)
          Container(
            margin: EdgeInsets.only(bottom: 8),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    selectedImage!,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: onRemoveImage,
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.close, color: Colors.white, size: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(25),
              ),
              child: IconButton(
                icon: AnimatedSwitcher(
                  duration: Duration(milliseconds: 200),
                  child: Icon(
                    isListening ? Icons.mic : Icons.mic_none,
                    key: ValueKey<bool>(isListening),
                    color: isListening
                        ? AppColors.primary
                        : AppColors.textLight,
                  ),
                ),
                onPressed: isEnabled ? onVoicePressed : null,
              ),
            ),
            SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(25),
              ),
              child: IconButton(
                icon: Icon(Icons.image, color: AppColors.textLight),
                onPressed: isEnabled ? onImagePick : null,
              ),
            ),
            SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                enabled: isEnabled,
                decoration: InputDecoration(
                  hintText: isEnabled
                      ? (selectedImage != null
                            ? 'Add a caption...'
                            : 'Type your message...')
                      : 'Please wait...',
                  hintStyle: TextStyle(
                    color: AppColors.textLight.withOpacity(
                      isEnabled ? 1.0 : 0.5,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: isEnabled
                      ? AppColors.surfaceVariant
                      : AppColors.surfaceVariant.withOpacity(0.5),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                maxLines: 5,
                minLines: 1,
                textInputAction: TextInputAction.send,
                textCapitalization: TextCapitalization.sentences,
                onSubmitted: isEnabled ? (_) => onSend() : null,
                style: TextStyle(
                  color: isEnabled
                      ? AppColors.textPrimary
                      : AppColors.textLight,
                ),
              ),
            ),
            SizedBox(width: 8),
            AnimatedBuilder(
              animation: sendButtonAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: sendButtonAnimation.value,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient:
                          (isComposing || selectedImage != null) && isEnabled
                          ? LinearGradient(
                              colors: [AppColors.primary, AppColors.secondary],
                            )
                          : LinearGradient(
                              colors: [
                                AppColors.textLight.withOpacity(0.3),
                                AppColors.textLight.withOpacity(0.3),
                              ],
                            ),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.send,
                        color:
                            (isComposing || selectedImage != null) && isEnabled
                            ? Colors.white
                            : AppColors.textLight.withOpacity(0.7),
                      ),
                      onPressed:
                          ((isComposing || selectedImage != null) && isEnabled)
                          ? onSend
                          : null,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isLastMessage;
  final VoidCallback onCopy;
  final VoidCallback onSpeak;
  final bool isSpeaking;

  const _ChatBubble({
    required this.message,
    this.isLastMessage = false,
    required this.onCopy,
    required this.onSpeak,
    required this.isSpeaking,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isUser = message.isUser;

    return Padding(
      padding: EdgeInsets.only(bottom: isLastMessage ? 8 : 16),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Image.asset("assets/images/chatbotimage.png", height: 30),
            ),
            SizedBox(width: 8),
          ],
          Flexible(
            child: GestureDetector(
              onLongPress: onCopy,
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.75,
                ),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: isUser ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(isUser ? 20 : 4),
                    bottomRight: Radius.circular(isUser ? 4 : 20),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (message.isImage && message.imageUrl != null) ...[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(message.imageUrl!),
                          width: double.infinity,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                      ),
                      if (message.imageCaption != null) ...[
                        SizedBox(height: 8),
                        Text(
                          message.imageCaption!,
                          style: TextStyle(
                            color: isUser
                                ? Colors.white70
                                : AppColors.textPrimary.withOpacity(0.7),
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                      SizedBox(height: 8),
                    ],
                    Text(
                      message.text,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isUser ? Colors.white : AppColors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                    if (!isUser)
                      Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(
                                isSpeaking ? Icons.stop : Icons.volume_up,
                                size: 16,
                                color: AppColors.textPrimary.withOpacity(0.7),
                              ),
                              onPressed: onSpeak,
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(),
                            ),
                            SizedBox(width: 8),
                            IconButton(
                              icon: Icon(
                                Icons.copy,
                                size: 16,
                                color: AppColors.textPrimary.withOpacity(0.7),
                              ),
                              onPressed: onCopy,
                              padding: EdgeInsets.zero,
                              constraints: BoxConstraints(),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (isUser) ...[
            SizedBox(width: 8),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(Icons.person, color: AppColors.primary, size: 20),
            ),
          ],
        ],
      ),
    );
  }
}
