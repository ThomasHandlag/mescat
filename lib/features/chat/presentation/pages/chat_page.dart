import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../../../shared/widgets/chat_box.dart';
import '../../../../shared/widgets/message_bubble.dart';
import '../../domain/entities/message.dart';

class ChatPage extends StatefulWidget {
  final String serverId;
  final String channelId;
  
  const ChatPage({
    super.key,
    required this.serverId,
    required this.channelId,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final List<Message> _messages = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadSampleMessages();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadSampleMessages() {
    // Sample messages for demonstration
    final sampleMessages = [
      Message(
        id: '1',
        content: 'Hey everyone! 👋',
        authorId: 'user1',
        authorUsername: 'Alice',
        channelId: widget.channelId,
        timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
      ),
      Message(
        id: '2',
        content: 'How\'s everyone doing today?',
        authorId: 'user2',
        authorUsername: 'Bob',
        channelId: widget.channelId,
        timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
      ),
      Message(
        id: '3',
        content: 'I just finished working on the new feature! It looks amazing 🚀',
        authorId: 'user3',
        authorUsername: 'Charlie',
        channelId: widget.channelId,
        timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
      ),
      Message(
        id: '4',
        content: 'That\'s awesome! Can\'t wait to see it in action.',
        authorId: 'user1',
        authorUsername: 'Alice',
        channelId: widget.channelId,
        timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      ),
      Message(
        id: '5',
        content: 'Check out this cool design I found: https://example.com/design.png',
        authorId: 'user4',
        authorUsername: 'David',
        channelId: widget.channelId,
        timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
        attachments: ['https://picsum.photos/300/200'],
      ),
    ];

    setState(() {
      _messages.addAll(sampleMessages);
    });
  }

  void _handleSendMessage(String message, List<String>? attachments) {
    if (message.trim().isEmpty && (attachments == null || attachments.isEmpty)) return;

    final newMessage = Message(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: message,
      authorId: 'current_user',
      authorUsername: 'You',
      channelId: widget.channelId,
      timestamp: DateTime.now(),
      attachments: attachments ?? [],
    );

    setState(() {
      _messages.add(newMessage);
    });

    // Auto scroll to bottom
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

  Future<void> _handleAttachFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        type: FileType.any,
      );

      if (result != null) {
        final files = result.files.map((file) => file.path ?? '').where((path) => path.isNotEmpty).toList();
        
        if (files.isNotEmpty) {
          // In a real app, you would upload these files and get URLs
          // For demo purposes, we'll just show file names
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Selected ${files.length} file(s)'),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking files: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    }
  }

  void _handleEmojiPicker() {
    // Show emoji picker modal
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: 300,
        padding: const EdgeInsets.all(16),
        child: const Center(
          child: Text('Emoji Picker - To be implemented'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '#general',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Server: ${widget.serverId}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implement search functionality
            },
            tooltip: 'Search messages',
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // Show channel options
            },
            tooltip: 'Channel options',
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      final isCurrentUser = message.authorId == 'current_user';
                      
                      return MessageBubble(
                        message: message,
                        isCurrentUser: isCurrentUser,
                        onReply: () {
                          // Implement reply functionality
                        },
                        onReact: () {
                          // Implement reaction functionality
                        },
                        onEdit: isCurrentUser ? () {
                          // Implement edit functionality
                        } : null,
                        onDelete: isCurrentUser ? () {
                          // Implement delete functionality
                        } : null,
                      );
                    },
                  ),
          ),
          
          // Chat input
          ChatBox(
            channelName: 'general',
            onSendMessage: _handleSendMessage,
            onAttachFile: _handleAttachFile,
            onEmojiPicker: _handleEmojiPicker,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No messages yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start the conversation!',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}