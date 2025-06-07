import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/chat_provider.dart';
import '../../../app_theme.dart';
import '../../../widgets/custom_confirmation_dialog.dart';
import '../../../widgets/custom_app_bar.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _textFieldFocusNode = FocusNode();
  late AnimationController _sendButtonAnimationController;
  late Animation<double> _sendButtonScaleAnimation;
  bool _isComposing = false;

  @override
  void initState() {
    super.initState();
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

    _messageController.addListener(_onTextChanged);

    // Auto-scroll to bottom when new messages arrive
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatProvider = context.read<ChatProvider>();
      chatProvider.addListener(_scrollToBottomIfNeeded);
    });
  }

  @override
  void dispose() {
    _messageController.removeListener(_onTextChanged);
    _messageController.dispose();
    _scrollController.dispose();
    _textFieldFocusNode.dispose();
    _sendButtonAnimationController.dispose();
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
    // Only auto-scroll if user is near the bottom
    if (_scrollController.hasClients) {
      final threshold = _scrollController.position.maxScrollExtent - 100;
      if (_scrollController.position.pixels > threshold) {
        _scrollToBottom();
      }
    }
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      // Haptic feedback
      HapticFeedback.lightImpact();

      final chatProvider = context.read<ChatProvider>();
      chatProvider.sendMessage(text);
      _messageController.clear();

      // Scroll to bottom after a short delay to allow for message to be added
      Future.delayed(Duration(milliseconds: 100), () {
        _scrollToBottom();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();
    final theme = Theme.of(context);
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      appBar: CustomAppBar(
        title: 'Serenity',
        leadingIcon: Icons.chat_rounded,
        trailingWidget: Container(
          margin: EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.white),
            onPressed: chatProvider.messages.isEmpty
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
                          chatProvider.clearChat();
                          Navigator.of(context).pop();
                        },
                      ),
                    );
                  },
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: chatProvider.messages.isEmpty
                ? _EmptyStateWidget()
                : ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    itemCount: chatProvider.messages.length,
                    itemBuilder: (context, index) {
                      final message = chatProvider.messages[index];
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
                                index == chatProvider.messages.length - 1,
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (chatProvider.isLoading && chatProvider.messages.isNotEmpty)
            _TypingIndicator(),
          AnimatedContainer(
            duration: Duration(milliseconds: 200),
            padding: EdgeInsets.fromLTRB(
              16,
              12,
              16,
              16 + keyboardHeight * 0.05,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
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
                isEnabled: !chatProvider.isLoading,
              ),
            ),
          ),
        ],
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

  const _MessageInputWidget({
    required this.controller,
    required this.focusNode,
    required this.isComposing,
    required this.onSend,
    required this.sendButtonAnimation,
    required this.isEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            enabled: isEnabled,
            decoration: InputDecoration(
              hintText: isEnabled ? 'Type your message...' : 'Please wait...',
              hintStyle: TextStyle(
                color: AppColors.textLight.withOpacity(isEnabled ? 1.0 : 0.5),
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
              color: isEnabled ? AppColors.textPrimary : AppColors.textLight,
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
                  gradient: isComposing && isEnabled
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
                    color: isComposing && isEnabled
                        ? AppColors.surface
                        : AppColors.textLight.withOpacity(0.7),
                  ),
                  onPressed: (isComposing && isEnabled) ? onSend : null,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _ChatBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isLastMessage;

  const _ChatBubble({required this.message, this.isLastMessage = false});

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
              ),
              child: Image.asset("assets/images/chatbotimage.png", height: 30),
            ),
            SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? AppColors.primary : AppColors.surface,
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
              child: Text(
                message.text,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isUser ? AppColors.surface : AppColors.textPrimary,
                  height: 1.4,
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
                color: AppColors.surfaceVariant,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.person, color: AppColors.textLight, size: 20),
            ),
          ],
        ],
      ),
    );
  }
}
