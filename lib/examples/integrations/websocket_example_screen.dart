import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/integrations/websocket_client.dart';

/// Demonstrates the reusable [WebSocketClient]: connect, send, receive and
/// automatic reconnection, against a public echo server.
///
/// Copy `core/network/integrations/websocket_client.dart` into your feature
/// and point it at your own server to reuse this pattern (live chat,
/// presence, notifications, price tickers, collaborative editing, ...).
class WebSocketExampleScreen extends ConsumerStatefulWidget {
  const WebSocketExampleScreen({super.key});

  static const _echoServerUrl = 'wss://echo.websocket.events/.ws';

  @override
  ConsumerState<WebSocketExampleScreen> createState() =>
      _WebSocketExampleScreenState();
}

class _WebSocketExampleScreenState
    extends ConsumerState<WebSocketExampleScreen> {
  final _controller = TextEditingController();
  final _log = <_LogEntry>[];
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _appendLog(String text, {required bool outgoing}) {
    setState(() => _log.add(_LogEntry(text, outgoing: outgoing)));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final client = ref.watch(webSocketClientProvider);

    ref.listen<AsyncValue<dynamic>>(_incomingMessageProvider(client), (
      previous,
      next,
    ) {
      next.whenData((message) => _appendLog('$message', outgoing: false));
    });

    return Scaffold(
      appBar: AppBar(title: const Text('WebSocket example')),
      body: Column(
        children: [
          _ConnectionBar(client: client),
          const Divider(height: 1),
          Expanded(
            child: _log.isEmpty
                ? const Center(child: Text('No messages yet'))
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(12),
                    itemCount: _log.length,
                    itemBuilder: (context, index) {
                      final entry = _log[index];
                      return Align(
                        alignment: entry.outgoing
                            ? Alignment.centerRight
                            : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: entry.outgoing
                                ? Theme.of(context).colorScheme.primaryContainer
                                : Theme.of(
                                    context,
                                  ).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(entry.text),
                        ),
                      );
                    },
                  ),
          ),
          const Divider(height: 1),
          Padding(
            padding: EdgeInsets.only(
              left: 12,
              right: 12,
              top: 8,
              bottom: 8 + MediaQuery.of(context).padding.bottom,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Message to send',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onSubmitted: (_) => _send(client),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: client.state == WebSocketConnectionState.connected
                      ? () => _send(client)
                      : null,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _send(WebSocketClient client) {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    client.send(text);
    _appendLog(text, outgoing: true);
    _controller.clear();
  }
}

/// Bridges the client's connection-state stream into a small status bar with
/// connect/disconnect controls.
class _ConnectionBar extends StatelessWidget {
  const _ConnectionBar({required this.client});

  final WebSocketClient client;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<WebSocketConnectionState>(
      stream: client.connectionState,
      initialData: client.state,
      builder: (context, snapshot) {
        final state = snapshot.data ?? WebSocketConnectionState.disconnected;
        final isConnected = state == WebSocketConnectionState.connected;
        final isConnecting = state == WebSocketConnectionState.connecting;

        return Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _StatusChip(state: state),
              const Spacer(),
              if (isConnecting)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                FilledButton.tonal(
                  onPressed: () {
                    if (isConnected) {
                      client.disconnect();
                    } else {
                      client.connect(
                        Uri.parse(WebSocketExampleScreen._echoServerUrl),
                      );
                    }
                  },
                  child: Text(isConnected ? 'Disconnect' : 'Connect'),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.state});

  final WebSocketConnectionState state;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (state) {
      WebSocketConnectionState.connected => ('Connected', Colors.green),
      WebSocketConnectionState.connecting => ('Connecting…', Colors.orange),
      WebSocketConnectionState.error => ('Error', Colors.red),
      WebSocketConnectionState.disconnected => ('Disconnected', Colors.grey),
    };
    return Chip(
      label: Text(label),
      avatar: CircleAvatar(backgroundColor: color),
    );
  }
}

class _LogEntry {
  _LogEntry(this.text, {required this.outgoing});
  final String text;
  final bool outgoing;
}

/// Adapts the client's broadcast [WebSocketClient.messages] stream into a
/// per-widget provider so `ref.listen` can drive the log without the screen
/// managing its own StreamSubscription.
final _incomingMessageProvider = StreamProvider.autoDispose
    .family<dynamic, WebSocketClient>((ref, client) => client.messages);
