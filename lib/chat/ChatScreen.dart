import 'package:flutter/material.dart';
import 'package:flutter_projects/chat/websocket_service.dart';
import '../auth_helper.dart';
import 'dart:convert';
import 'MessageBubble.dart';
import '../AppColors.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String receiverType;
  final String receiverName;

  const ChatScreen({
    super.key,
    required this.receiverId,
    required this.receiverType,
    required this.receiverName,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}
class _ChatScreenState extends State<ChatScreen> {
  late WebSocketService _webSocketService;
  final TextEditingController _messageController = TextEditingController();
  final List<Map<String, dynamic>> _messages = <Map<String, dynamic>>[];
  bool _isConnected = false;
  String? _currentUserId;
  String? _currentUserType;
  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    _currentUserId = (await getUserId())?.toString();
    _currentUserType = await getToken() != null
        ? (await getUserType() == 'JobSeeker' ? 'user' : 'company')
        : null;
    await _initWebSocket();
    await _loadPreviousMessages();
  }
  Future<void> _initWebSocket() async {
    final token = await getToken();
    if (token == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Authentication required')),
        );
      }
      return;
    }

    _webSocketService = WebSocketService(
      authToken: token,
      onConnected: () {
        if (mounted) {
          setState(() => _isConnected = true);
        }
      },
      onDisconnected: () {
        if (mounted) {
          setState(() => _isConnected = false);
        }
      },
      onMessage: (data) {
        if (mounted) {
          debugPrint('📩 Received WebSocket data: $data');
          try {
            final messageData = jsonDecode(data);
            debugPrint('Received WebSocket data: $messageData');

            // Handle both message types from backend
            if (messageData['type'] == 'chat.message') {
              setState(() {
                // Check if this is a response to our temp message
                final tempId = messageData['message']['temp_id'];
                if (tempId != null) {
                  _messages.removeWhere((msg) => msg['temp_id'] == tempId);
                }

                // Add the new message
                _messages.insert(0, {
                  ...messageData['message'],
                  'isMe': messageData['message']['sender_id'] == _currentUserId,
                  'status': 'delivered',
                });
              });
            }
          } catch (e) {
            debugPrint('Error handling message: $e');
          }
        }
      },
      onError: (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Connection error: $error')),
          );
        }
      },
    );

    await _webSocketService.connect();
  }
  void _sendMessage() async {
    if (_messageController.text.isEmpty || !_isConnected) return;

    final tempId = 'temp-${DateTime.now().millisecondsSinceEpoch}';
    final timestamp = DateTime.now().toIso8601String();

    // Create message with proper structure
    final message = {
      'type': 'chat_message',
      'receiver_id': widget.receiverId,
      'receiver_type': widget.receiverType,
      'content': _messageController.text,
      'timestamp': timestamp,
      'temp_id': tempId,
    };
    debugPrint('📤 Sending message: ${jsonEncode(message)}');

    // Add to local list immediately
    setState(() {
      _messages.insert(0, {
        'id': tempId,
        'content': _messageController.text,
        'timestamp': timestamp,
        'sender_id': _currentUserId,
        'sender_type': _currentUserType,
        'receiver_id': widget.receiverId,
        'receiver_type': widget.receiverType,
        'temp_id': tempId,
        'status': 'sending',
        'isMe': true,
      });
    });

    _webSocketService.send(jsonEncode(message));
    _messageController.clear();
  }
  Future<void> _loadPreviousMessages() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:8000/chat/conversation/?other_id=${widget.receiverId}&other_type=${widget.receiverType}'),
        headers: {'Authorization': 'Token ${await getToken()}'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final messages = (data['messages'] as List).cast<Map<String, dynamic>>();

        debugPrint('Loaded ${messages.length} conversation messages');

        if (mounted) {
          setState(() {
            _messages.clear();
            _messages.addAll(messages.map((message) {
              // Debug print each message
              debugPrint('Processing message: ${message['id']} '
                  'from ${message['sender']?['id']} '
                  '(isMe: ${message['isMe']})');

              return {
                ...message,
                // Ensure sender_id exists
                'sender_id': message['sender']?['id']?.toString(),
                // Ensure isMe is properly set
                'isMe': message['isMe'] ?? false,
              };
            }));
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading conversation: $e');
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverName),
        actions: [
          IconButton(
            icon: Icon(_isConnected ? Icons.circle : Icons.circle_outlined),
            color: _isConnected ? AppColors.background : AppColors.errorBackground,
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isMe = message['sender_id'] == _currentUserId;

                return MessageBubble(
                  message: message,
                  isMe: isMe,
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    enabled: _isConnected,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _isConnected ? _sendMessage : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _webSocketService.disconnect();
    _messageController.dispose();
    super.dispose();
  }
}


