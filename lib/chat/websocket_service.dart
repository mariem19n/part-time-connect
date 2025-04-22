
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:flutter/foundation.dart';

class WebSocketService {
  late final WebSocketChannel _channel;
  final String authToken;
  final String baseUrl;
  final VoidCallback? onConnected;
  final VoidCallback? onDisconnected;
  final Function(dynamic)? onMessage;
  final Function(dynamic)? onError;

  WebSocketService({
    required this.authToken,
    this.baseUrl = 'ws://10.0.2.2:8000',
    this.onConnected,
    this.onDisconnected,
    this.onMessage,
    this.onError,
  });

  bool get isConnected => _channel.closeCode == null;

  Future<void> connect() async {
    try {
      debugPrint('🟢 Tentative de connexion WebSocket...');
      final uri = Uri.parse('$baseUrl/ws/chat/?token=$authToken');
      _channel = IOWebSocketChannel.connect(
        uri,
        headers: {
          'Origin': 'http://localhost', // Required for CORS
        },
      );

      _channel.stream.listen(
            (data) {
          debugPrint('🔵 Message reçu: $data');
          onMessage?.call(data);
        },
        onDone: () {
          debugPrint('🟠 Connexion WebSocket fermée');
          onDisconnected?.call();
        },
        onError: (error) {
          debugPrint('🔴 Erreur WebSocket: $error');
          onError?.call(error);
        },
      );

      debugPrint('🟢 Connexion WebSocket établie avec succès!');
      onConnected?.call();
    } catch (e) {
      debugPrint('🔴 Erreur lors de la connexion: $e');
      onError?.call(e);
      rethrow;
    }
  }

  void send(dynamic message) {
    if (!isConnected) {
      debugPrint('⚠️ Tentative d\'envoi sans connexion active');
      throw Exception('WebSocket not connected');
    }

    debugPrint('✉️ Envoi du message: $message');
    _channel.sink.add(message);
  }

  Future<void> disconnect() async {
    debugPrint('🟠 Fermeture de la connexion WebSocket');
    try {
      await _channel.sink.close();
    } catch (e) {
      debugPrint('🔴 Erreur lors de la déconnexion: $e');
      rethrow;
    }
  }
}
