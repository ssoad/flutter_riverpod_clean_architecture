import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'local_webhook_receiver.dart';
import 'webhook_signature.dart';

/// `dart:io` `HttpServer`-backed implementation, used on every platform
/// except web.
class LocalWebhookReceiverImpl implements LocalWebhookReceiver {
  HttpServer? _server;
  String? _secret;
  final _controller = StreamController<ReceivedWebhook>.broadcast();

  @override
  Stream<ReceivedWebhook> get events => _controller.stream;

  @override
  bool get isRunning => _server != null;

  @override
  Future<Uri> start({int port = 0, String? secret}) async {
    _secret = secret;
    final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
    _server = server;
    server.listen(_handleRequest);
    return Uri(
      scheme: 'http',
      host: server.address.address,
      port: server.port,
      path: '/webhook',
    );
  }

  Future<void> _handleRequest(HttpRequest request) async {
    final body = await utf8.decoder.bind(request).join();
    final headers = <String, String>{};
    request.headers.forEach((name, values) {
      headers[name] = values.join(', ');
    });

    bool? verified;
    final secret = _secret;
    if (secret != null) {
      final signature = headers['x-webhook-signature'];
      verified =
          signature != null &&
          WebhookSignature.verify(
            secret: secret,
            payload: body,
            signature: signature,
          );
    }

    _controller.add(
      ReceivedWebhook(
        receivedAt: DateTime.now(),
        method: request.method,
        headers: headers,
        body: body,
        signatureVerified: verified,
      ),
    );

    request.response
      ..statusCode = HttpStatus.ok
      ..headers.contentType = ContentType.json
      ..write(jsonEncode({'received': true}));
    await request.response.close();
  }

  @override
  Future<void> stop() async {
    await _server?.close(force: true);
    _server = null;
  }
}
