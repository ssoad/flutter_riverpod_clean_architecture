import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/integrations/local_webhook_receiver.dart';
import '../../core/network/integrations/webhook_sender.dart';

/// Demonstrates the outbound webhook pattern: signing a payload with
/// HMAC-SHA256, sending it, and (on non-web platforms) receiving + verifying
/// it locally so you can see both sides of the handshake at once.
///
/// Copy `core/network/integrations/webhook_sender.dart` and
/// `webhook_signature.dart` into a real feature (e.g. "notify our backend
/// when an order ships") and point `send()` at your own endpoint.
class WebhookExampleScreen extends ConsumerStatefulWidget {
  const WebhookExampleScreen({super.key});

  @override
  ConsumerState<WebhookExampleScreen> createState() =>
      _WebhookExampleScreenState();
}

class _WebhookExampleScreenState extends ConsumerState<WebhookExampleScreen> {
  final _secretController = TextEditingController(text: 'demo-shared-secret');
  final _payloadController = TextEditingController(
    text: '{\n  "event": "order.shipped",\n  "orderId": "1234"\n}',
  );
  final _urlController = TextEditingController();

  LocalWebhookReceiver? _receiver;
  Uri? _receiverUrl;
  final _received = <ReceivedWebhook>[];

  String? _lastResultMessage;
  bool _lastResultWasError = false;
  bool _sending = false;

  @override
  void dispose() {
    _secretController.dispose();
    _payloadController.dispose();
    _urlController.dispose();
    _receiver?.stop();
    super.dispose();
  }

  Future<void> _toggleReceiver() async {
    if (_receiver != null) {
      await _receiver!.stop();
      setState(() {
        _receiver = null;
        _receiverUrl = null;
      });
      return;
    }

    final receiver = LocalWebhookReceiver();
    try {
      final url = await receiver.start(secret: _secretController.text);
      receiver.events.listen((event) {
        setState(() => _received.insert(0, event));
      });
      setState(() {
        _receiver = receiver;
        _receiverUrl = url;
        _urlController.text = '$url';
      });
    } on UnsupportedError catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? 'Unsupported')));
    }
  }

  Future<void> _send() async {
    final url = _urlController.text.trim();
    if (url.isEmpty) {
      setState(() {
        _lastResultWasError = true;
        _lastResultMessage = 'Enter a URL to send to first.';
      });
      return;
    }

    Map<String, dynamic> payload;
    try {
      payload = jsonDecode(_payloadController.text) as Map<String, dynamic>;
    } catch (_) {
      setState(() {
        _lastResultWasError = true;
        _lastResultMessage = 'Payload must be valid JSON.';
      });
      return;
    }

    setState(() => _sending = true);
    final result = await ref
        .read(webhookSenderProvider)
        .send(url: url, payload: payload, secret: _secretController.text);
    if (!mounted) return;
    setState(() {
      _sending = false;
      result.match(
        (failure) {
          _lastResultWasError = true;
          _lastResultMessage = failure.message;
        },
        (delivery) {
          _lastResultWasError = false;
          _lastResultMessage =
              'Delivered (${delivery.statusCode}). Signature: '
              '${delivery.signature}';
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Webhook example')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('1. Local receiver (dev only)', style: _sectionStyle(context)),
          const SizedBox(height: 4),
          Text(
            kIsWeb
                ? 'Not available on web - dart:io HttpServer is needed. Run '
                      'this demo on desktop or mobile.'
                : 'Starts a loopback HTTP server to receive and verify '
                      'webhooks, for local testing only.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _receiverUrl == null
                              ? 'Not running'
                              : 'Listening on $_receiverUrl',
                        ),
                      ),
                      FilledButton.tonal(
                        onPressed: kIsWeb ? null : _toggleReceiver,
                        child: Text(_receiver == null ? 'Start' : 'Stop'),
                      ),
                    ],
                  ),
                  if (_received.isNotEmpty) ...[
                    const Divider(),
                    ..._received.take(5).map(_buildReceivedTile),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('2. Send a signed webhook', style: _sectionStyle(context)),
          const SizedBox(height: 12),
          TextField(
            controller: _urlController,
            decoration: const InputDecoration(
              labelText: 'Destination URL',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _secretController,
            decoration: const InputDecoration(
              labelText: 'Shared secret',
              border: OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _payloadController,
            maxLines: 5,
            style: const TextStyle(fontFamily: 'monospace'),
            decoration: const InputDecoration(
              labelText: 'JSON payload',
              border: OutlineInputBorder(),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _sending ? null : _send,
            icon: _sending
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send),
            label: const Text('Send webhook'),
          ),
          if (_lastResultMessage != null) ...[
            const SizedBox(height: 12),
            Text(
              _lastResultMessage!,
              style: TextStyle(
                color: _lastResultWasError ? Colors.red : Colors.green,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildReceivedTile(ReceivedWebhook event) {
    final verified = event.signatureVerified;
    return ListTile(
      dense: true,
      leading: Icon(
        verified == null
            ? Icons.remove_circle_outline
            : (verified ? Icons.verified : Icons.error_outline),
        color: verified == null
            ? Colors.grey
            : (verified ? Colors.green : Colors.red),
      ),
      title: Text('${event.method} ${event.receivedAt.toIso8601String()}'),
      subtitle: Text(event.body, maxLines: 2, overflow: TextOverflow.ellipsis),
    );
  }

  TextStyle? _sectionStyle(BuildContext context) =>
      Theme.of(context).textTheme.titleMedium;
}
