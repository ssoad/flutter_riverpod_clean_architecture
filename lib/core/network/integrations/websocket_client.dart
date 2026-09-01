import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../../utils/logger.dart';

/// Lifecycle state of a [WebSocketClient] connection.
enum WebSocketConnectionState { disconnected, connecting, connected, error }

/// A small, reusable WebSocket client.
///
/// This is intentionally generic (not tied to any single feature) so it can
/// be copied/adapted whenever a feature needs a live, bidirectional
/// connection - live chat, presence, price tickers, collaborative editing,
/// server push, etc. The chat feature (`features/chat`) shows one concrete
/// usage; this class shows the reusable primitive underneath it, with
/// reconnection and a typed connection-state stream.
class WebSocketClient {
  WebSocketClient({
    this.autoReconnect = true,
    this.reconnectDelay = const Duration(seconds: 2),
  });

  /// Whether to automatically try to reconnect after an unexpected close.
  final bool autoReconnect;

  /// Delay before each reconnect attempt.
  final Duration reconnectDelay;

  WebSocketChannel? _channel;
  Uri? _uri;
  StreamSubscription? _channelSubscription;
  Timer? _reconnectTimer;
  bool _manuallyClosed = false;

  final StreamController<dynamic> _messageController =
      StreamController<dynamic>.broadcast();
  final StreamController<WebSocketConnectionState> _stateController =
      StreamController<WebSocketConnectionState>.broadcast();

  WebSocketConnectionState _state = WebSocketConnectionState.disconnected;

  /// Every message received from the server, in the shape it arrived
  /// (`String` for text frames, `List&lt;int&gt;` for binary frames).
  Stream<dynamic> get messages => _messageController.stream;

  /// Connection lifecycle changes.
  Stream<WebSocketConnectionState> get connectionState =>
      _stateController.stream;

  WebSocketConnectionState get state => _state;

  /// Opens the connection to [uri]. Safe to call again after [disconnect];
  /// a no-op if already connected/connecting to the same uri.
  Future<void> connect(Uri uri) async {
    if (_channel != null && _uri == uri) return;

    _manuallyClosed = false;
    _uri = uri;
    _reconnectTimer?.cancel();
    _setState(WebSocketConnectionState.connecting);

    try {
      final channel = WebSocketChannel.connect(uri);
      await channel.ready;
      _channel = channel;
      _setState(WebSocketConnectionState.connected);

      _channelSubscription = channel.stream.listen(
        (data) {
          Logger.debug('WebSocket message: $data');
          _messageController.add(data);
        },
        onError: (Object error) {
          Logger.error('WebSocket stream error', error);
          _setState(WebSocketConnectionState.error);
          _scheduleReconnect();
        },
        onDone: () {
          Logger.info('WebSocket closed (code=${channel.closeCode})');
          _channel = null;
          if (!_manuallyClosed) {
            _setState(WebSocketConnectionState.disconnected);
            _scheduleReconnect();
          }
        },
      );
    } catch (e, st) {
      Logger.error('WebSocket connect failed', e, st);
      _setState(WebSocketConnectionState.error);
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (!autoReconnect || _manuallyClosed || _uri == null) return;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(reconnectDelay, () {
      if (!_manuallyClosed && _uri != null) connect(_uri!);
    });
  }

  /// Sends a raw text/binary frame.
  void send(Object data) {
    final channel = _channel;
    if (channel == null) {
      throw StateError('Cannot send: WebSocket is not connected.');
    }
    channel.sink.add(data);
  }

  /// Convenience for sending a JSON-encodable payload.
  void sendJson(Map<String, dynamic> data) => send(jsonEncode(data));

  /// Closes the connection and stops any pending reconnect attempts.
  Future<void> disconnect() async {
    _manuallyClosed = true;
    _reconnectTimer?.cancel();
    await _channelSubscription?.cancel();
    await _channel?.sink.close();
    _channel = null;
    _setState(WebSocketConnectionState.disconnected);
  }

  void _setState(WebSocketConnectionState newState) {
    _state = newState;
    _stateController.add(newState);
  }

  /// Releases all resources. The client cannot be reused after this.
  void dispose() {
    _manuallyClosed = true;
    _reconnectTimer?.cancel();
    _channelSubscription?.cancel();
    _channel?.sink.close();
    _messageController.close();
    _stateController.close();
  }
}

/// A fresh [WebSocketClient] per subscriber, disposed automatically when no
/// longer watched.
final webSocketClientProvider = Provider.autoDispose<WebSocketClient>((ref) {
  final client = WebSocketClient();
  ref.onDispose(client.dispose);
  return client;
});
