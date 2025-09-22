import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../services/mock_data_service.dart';
import '../../utils/app_theme.dart';

class SupportChatScreen extends StatefulWidget {
  const SupportChatScreen({super.key});

  @override
  State<SupportChatScreen> createState() => _SupportChatScreenState();
}

class _SupportChatScreenState extends State<SupportChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final ApiService _apiService = ApiService();
  final MockDataService _mockDataService = MockDataService();

  bool _isTyping = false;
  bool _isLoading = true;
  String? _error;
  List<Map<String, dynamic>> _messages = [];
  String? _ticketId;

  @override
  void initState() {
    super.initState();
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      await _apiService.initialize();

      // First, create or get existing support ticket
      if (_ticketId == null) {
        final ticketResponse = await _apiService.createSupportTicket({
          'subject': 'General Support Inquiry',
          'priority': 'medium',
          'category': 'general',
        });

        if (ticketResponse['success'] == true &&
            ticketResponse['data'] != null) {
          _ticketId = ticketResponse['data']['ticketId'];
        }
      }

      // Load messages for the ticket
      List<Map<String, dynamic>> messages = [];
      if (_ticketId != null) {
        messages = await _apiService.getSupportMessages(_ticketId!);
      } else {
        // Fallback to mock data if API fails
        messages = await _mockDataService.getSupportMessages();
      }

      setState(() {
        _messages = messages;
        _isLoading = false;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load messages: ${e.toString()}'),
            backgroundColor: AppTheme.errorRed,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _loadMessages,
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final messageText = _messageController.text.trim();
    final messageId = DateTime.now().millisecondsSinceEpoch.toString();

    // Add message to UI immediately
    setState(() {
      _messages.add({
        'id': messageId,
        'text': messageText,
        'isUser': true,
        'timestamp': DateTime.now(),
        'sender': 'You',
        'status': 'sending',
      });
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      await _apiService.initialize();

      // Send message via API if ticket exists
      if (_ticketId != null) {
        final messageData = {
          'message': messageText,
          'type': 'user_message',
          'timestamp': DateTime.now().toIso8601String(),
        };

        await _apiService.sendSupportMessage(_ticketId!, messageData);
      } else {
        // Fallback to mock data if no ticket
        final messageData = {
          'message': messageText,
          'type': 'user_message',
          'timestamp': DateTime.now().toIso8601String(),
        };

        await _mockDataService.sendSupportMessage(messageData);
      }

      // Update message status to sent
      setState(() {
        final messageIndex =
            _messages.indexWhere((msg) => msg['id'] == messageId);
        if (messageIndex != -1) {
          _messages[messageIndex]['status'] = 'sent';
        }
      });

      // Simulate agent response
      _simulateAgentResponse();
    } catch (e) {
      // Update message status to failed
      setState(() {
        final messageIndex =
            _messages.indexWhere((msg) => msg['id'] == messageId);
        if (messageIndex != -1) {
          _messages[messageIndex]['status'] = 'failed';
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send message: ${e.toString()}'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  void _simulateAgentResponse() {
    setState(() {
      _isTyping = true;
    });

    // List of possible agent responses
    final responses = [
      'Thank you for your message. I\'m looking into this for you. Please give me a moment to check the details.',
      'I understand your concern. Let me help you resolve this issue step by step.',
      'That\'s a great question! I\'ll need to check our system to give you the most accurate information.',
      'I\'m here to help! Can you provide me with more details about the specific problem you\'re experiencing?',
      'I\'ve received your message and I\'m working on finding the best solution for you.',
      'Thank you for contacting us. I\'ll do my best to assist you with this matter.',
      'I understand this can be frustrating. Let me help you get this sorted out quickly.',
      'I\'m currently reviewing your request and will get back to you with a solution shortly.',
    ];

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isTyping = false;
          _messages.add({
            'id': DateTime.now().millisecondsSinceEpoch.toString(),
            'text': responses[DateTime.now().millisecond % responses.length],
            'isUser': false,
            'timestamp': DateTime.now(),
            'sender': 'Support Agent',
          });
        });
        _scrollToBottom();
      }
    });
  }

  void _scrollToBottom() {
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

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Support Chat'),
            Text(
              'Online',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppTheme.successGreen,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () {
              // TODO: Implement call functionality
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              _showOptionsDialog(context);
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: $_error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadMessages,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Chat Messages
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _loadMessages,
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: _messages.length + (_isTyping ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == _messages.length && _isTyping) {
                              return _buildTypingIndicator(theme);
                            }
                            return _buildMessage(_messages[index], theme);
                          },
                        ),
                      ),
                    ),

                    // Typing Indicator
                    if (_isTyping) _buildTypingBar(theme),

                    // Message Input
                    _buildMessageInput(theme),
                  ],
                ),
    );
  }

  Widget _buildMessage(Map<String, dynamic> message, ThemeData theme) {
    final isUser = message['isUser'] ?? false;
    final status = message['status'];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            const CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.primaryGreen,
              child: Icon(
                Icons.support_agent,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color:
                    isUser ? AppTheme.primaryGreen : theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(16).copyWith(
                  bottomLeft: isUser
                      ? const Radius.circular(16)
                      : const Radius.circular(4),
                  bottomRight: isUser
                      ? const Radius.circular(4)
                      : const Radius.circular(16),
                ),
                border: Border.all(
                  color: isUser ? AppTheme.primaryGreen : Colors.grey[300]!,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isUser) ...[
                    Text(
                      message['sender'] ?? 'Support Agent',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGreen,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    message['text'] ??
                        message['message'] ??
                        'No message content',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color:
                          isUser ? Colors.white : theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        _formatTime(message['timestamp'] is String
                            ? DateTime.parse(message['timestamp'])
                            : message['timestamp'] ?? DateTime.now()),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isUser
                              ? Colors.white.withOpacity(0.7)
                              : theme.colorScheme.onSurface.withOpacity(0.5),
                          fontSize: 11,
                        ),
                      ),
                      if (isUser && status != null) ...[
                        const SizedBox(width: 8),
                        Icon(
                          status == 'sending'
                              ? Icons.schedule
                              : status == 'sent'
                                  ? Icons.check
                                  : Icons.error,
                          size: 12,
                          color: status == 'sending'
                              ? Colors.orange
                              : status == 'sent'
                                  ? Colors.white.withOpacity(0.7)
                                  : Colors.red,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            const CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.primaryGreen,
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTypingIndicator(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 16,
            backgroundColor: AppTheme.primaryGreen,
            child: Icon(
              Icons.support_agent,
              color: Colors.white,
              size: 16,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(16).copyWith(
                bottomLeft: const Radius.circular(4),
              ),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Support Agent',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGreen,
                  ),
                ),
                const SizedBox(width: 8),
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(AppTheme.primaryGreen),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const SizedBox(width: 24),
          Text(
            'Support Agent is typing...',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Type your message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: AppTheme.primaryGreen),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: const BoxDecoration(
              color: AppTheme.primaryGreen,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: _sendMessage,
              icon: const Icon(
                Icons.send,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showOptionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chat Options'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Chat History'),
              onTap: () {
                Navigator.of(context).pop();
                // TODO: Navigate to chat history
              },
            ),
            ListTile(
              leading: const Icon(Icons.file_copy),
              title: const Text('Export Chat'),
              onTap: () {
                Navigator.of(context).pop();
                // TODO: Export chat functionality
              },
            ),
            ListTile(
              leading: const Icon(Icons.block),
              title: const Text('End Chat'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}
