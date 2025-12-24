import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_riverpod_clean_architecture/features/chat/data/models/message_model.dart';
import 'package:flutter_riverpod_clean_architecture/core/utils/logger.dart';

abstract class ChatRemoteDataSource {
  Stream<MessageModel> get messages;
  Future<void> connect();
  Future<void> sendMessage(String message);
  void disconnect();
}

class ChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  WebSocketChannel? _channel;
  final StreamController<MessageModel> _messageController =
      StreamController<MessageModel>.broadcast();

  // Using postman-echo or similar if echo.websocket.org is down
  // wss://echo.websocket.org is often unstable.
  // Using wss://echo.websocket.events/.ws
  static const String _socketUrl = 'wss://echo.websocket.events/.ws';

  @override
  Stream<MessageModel> get messages => _messageController.stream;

  @override
  Future<void> connect() async {
    try {
      if (_channel != null) return;

      final uri = Uri.parse(_socketUrl);
      _channel = WebSocketChannel.connect(uri);

      _channel!.stream.listen(
        (data) {
          Logger.debug('WebSocket received: $data');
          // Expecting simple text echo from this server
          if (data is String) {
            _messageController.add(MessageModel.fromText(data));
          }
        },
        onError: (error) {
          Logger.error('WebSocket error', error);
          // Reconnection logic could go here
        },
        onDone: () {
          Logger.info('WebSocket closed');
          _channel = null;
        },
      );
    } catch (e) {
      Logger.error('WebSocket Connection Failed', e);
      rethrow;
    }
  }

  @override
  Future<void> sendMessage(String message) async {
    if (_channel == null) {
      await connect();
    }
    _channel?.sink.add(message);
  }

  @override
  void disconnect() {
    _channel?.sink.close();
    _channel = null;
    _messageController.close();
  }
}
