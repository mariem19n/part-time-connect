/*import 'package:flutter/material.dart';

class MessagerieScreen extends StatelessWidget {
  const MessagerieScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messagerie'),
      ),
      body: const Center(
        child: Text('Messagerie Screen - To be implemented'),
      ),
    );
  }
}*/


/*import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'websocket_service.dart';
import '../auth_helper.dart';

class MessagerieScreen extends StatefulWidget {
  const MessagerieScreen({super.key});

  @override
  State<MessagerieScreen> createState() => _MessagerieScreenState();
}

class _MessagerieScreenState extends State<MessagerieScreen> {
  late WebSocketService _webSocketService;
  bool _isConnected = false;
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initWebSocket();
  }

  Future<void> _initWebSocket() async {
    final token = await getToken();
    if (token == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vous devez être connecté')),
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
      onMessage: (message) {
        if (mounted) {
          setState(() {
            _messages.add(jsonDecode(message));
          });
        }
      },
      onError: (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: $error')),
          );
        }
      },
    );

    await _webSocketService.connect();
  }

  void _sendMessage() {
    if (_messageController.text.isEmpty) return;

    final message = {
      'content': _messageController.text,
      'timestamp': DateTime.now().toIso8601String(),
    };

    _webSocketService.send(jsonEncode(message));
    _messageController.clear();
  }

  @override
  void dispose() {
    _webSocketService.disconnect();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messagerie'),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isConnected
                ? ListView.builder(
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return ListTile(
                  title: Text(message['content']),
                  subtitle: Text(message['timestamp']),
                );
              },
            )
                : const Center(child: CircularProgressIndicator()),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Tapez votre message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    enabled: _isConnected,
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
}*/