import 'package:flutter/material.dart';
import '../shared/widgets/chat_box.dart';
import '../shared/widgets/message_bubble.dart';
import '../features/chat/domain/entities/message.dart';

class ChatBoxDemoPage extends StatefulWidget {
  const ChatBoxDemoPage({super.key});

  @override
  State<ChatBoxDemoPage> createState() => _ChatBoxDemoPageState();
}

class _ChatBoxDemoPageState extends State<ChatBoxDemoPage>
    with TickerProviderStateMixin {
  final List<Message> _demoMessages = [];
  late AnimationController _animationController;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _loadDemoMessages();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadDemoMessages() {
    final demoMessages = [
      Message(
        id: '1',
        content: 'Welcome to the ChatBox demo! 🎉',
        authorId: 'demo',
        authorUsername: 'Demo Bot',
        channelId: 'demo',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
      Message(
        id: '2',
        content: 'This chat box supports:\n• Multi-line text input\n• File attachments\n• Emoji picker\n• Voice messages\n• Character counter',
        authorId: 'demo',
        authorUsername: 'Demo Bot',
        channelId: 'demo',
        timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
      ),
      Message(
        id: '3',
        content: 'Try typing a message below! The send button will appear when you start typing. 📝',
        authorId: 'demo',
        authorUsername: 'Demo Bot',
        channelId: 'demo',
        timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
      ),
    ];

    setState(() {
      _demoMessages.addAll(demoMessages);
    });
  }

  void _handleSendMessage(String message, List<String>? attachments) {
    if (message.trim().isEmpty && (attachments == null || attachments.isEmpty)) {
      return;
    }

    final newMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: message,
      authorId: 'user',
      authorUsername: 'You',
      channelId: 'demo',
      timestamp: DateTime.now(),
      attachments: attachments ?? [],
    );

    setState(() {
      _demoMessages.add(newMessage);
    });

    // Animate and scroll to bottom
    _animationController.forward().then((_) {
      _animationController.reset();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    // Auto-reply from demo bot
    if (message.toLowerCase().contains('hello') || message.toLowerCase().contains('hi')) {
      _addBotReply('Hello there! 👋 Nice to meet you!');
    } else if (message.toLowerCase().contains('help')) {
      _addBotReply('Here are some things you can try:\n• Type "hello" for a greeting\n• Try attaching files\n• Use the emoji picker\n• Test multi-line messages');
    } else if (message.toLowerCase().contains('awesome') || message.toLowerCase().contains('great')) {
      _addBotReply('I\'m glad you like it! 😊 The ChatBox widget is fully customizable and Discord-inspired.');
    } else {
      _addBotReply('Thanks for your message! This is an auto-reply from the demo bot. 🤖');
    }
  }

  void _addBotReply(String reply) {
    Future.delayed(const Duration(milliseconds: 1000), () {
      if (mounted) {
        final botMessage = Message(
          id: 'bot_${DateTime.now().millisecondsSinceEpoch}',
          content: reply,
          authorId: 'demo',
          authorUsername: 'Demo Bot',
          authorAvatarUrl: null,
          channelId: 'demo',
          timestamp: DateTime.now(),
        );

        setState(() {
          _demoMessages.add(botMessage);
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    });
  }

  void _handleAttachFile() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('📎 File attachment demo - Feature works!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _handleEmojiPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        height: 350,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            
            // Title
            Text(
              '😊 Emoji Picker',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Emoji grid (demo)
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 8,
                  childAspectRatio: 1,
                ),
                itemCount: 64,
                itemBuilder: (context, index) {
                  final emojis = ['😀', '😃', '😄', '😁', '😅', '😂', '🤣', '😊', '😇', '🙂', '🙃', '😉', '😌', '😍', '🥰', '😘', '😗', '😙', '😚', '😋', '😛', '😝', '😜', '🤪', '🤨', '🧐', '🤓', '😎', '🤩', '🥳', '😏', '😒', '😞', '😔', '😟', '😕', '🙁', '☹️', '😣', '😖', '😫', '😩', '🥺', '😢', '😭', '😤', '😠', '😡', '🤬', '🤯', '😳', '🥵', '🥶', '😱', '😨', '😰', '😥', '😓', '🤗', '🤔', '🤭', '🤫', '🤥', '😶'];
                  final emoji = emojis[index % emojis.length];
                  
                  return GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Selected emoji: $emoji'),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Theme.of(context).colorScheme.surface,
                      ),
                      child: Center(
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ChatBox Demo'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('ChatBox Features'),
                  content: const Text(
                    '• Discord-inspired design\n'
                    '• Multi-line text input\n'
                    '• File attachment support\n'
                    '• Emoji picker integration\n'
                    '• Voice message button\n'
                    '• Character counter\n'
                    '• Send button animation\n'
                    '• Typing indicator support\n'
                    '• Responsive design\n'
                    '• Theme-aware styling',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Got it!'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages area
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.background,
              ),
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _demoMessages.length,
                itemBuilder: (context, index) {
                  final message = _demoMessages[index];
                  final isCurrentUser = message.authorId == 'user';
                  
                  return AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      if (index == _demoMessages.length - 1 && isCurrentUser) {
                        return SlideTransition(
                          position: Tween<Offset>(
                            begin: const Offset(0, 0.3),
                            end: Offset.zero,
                          ).animate(CurvedAnimation(
                            parent: _animationController,
                            curve: Curves.easeOut,
                          )),
                          child: FadeTransition(
                            opacity: _animationController,
                            child: child,
                          ),
                        );
                      }
                      return child!;
                    },
                    child: MessageBubble(
                      message: message,
                      isCurrentUser: isCurrentUser,
                    ),
                  );
                },
              ),
            ),
          ),
          
          // Chat input
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                ),
              ),
            ),
            child: ChatBox(
              channelName: 'demo',
              placeholder: 'Try typing a message...',
              onSendMessage: _handleSendMessage,
              onAttachFile: _handleAttachFile,
              onEmojiPicker: _handleEmojiPicker,
            ),
          ),
        ],
      ),
    );
  }
}