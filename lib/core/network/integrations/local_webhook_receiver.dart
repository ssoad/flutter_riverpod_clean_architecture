import 'local_webhook_receiver_stub.dart'
    if (dart.library.io) 'local_webhook_receiver_io.dart'
    as platform;

/// A single request the [LocalWebhookReceiver] accepted.
class ReceivedWebhook {
  const ReceivedWebhook({
    required this.receivedAt,
    required this.method,
    required this.headers,
    required this.body,
    required this.signatureVerified,
  });

  final DateTime receivedAt;
  final String method;
  final Map<String, String> headers;
  final String body;

  /// Null when no secret was configured for verification; otherwise whether
  /// the `X-Webhook-Signature` header matched the body.
  final bool? signatureVerified;
}

/// A tiny local HTTP listener for exercising the sender/signature-verify
/// half of the webhook pattern during development.
///
/// IMPORTANT: this binds to `127.0.0.1` only. It is a development/testing
/// aid - e.g. pointing your own [WebhookSender] at it, or forwarding a real
/// provider's webhooks to it with a tool like `ngrok` or `stripe listen`
/// while developing on desktop/mobile. A mobile app cannot be a public
/// webhook endpoint; production webhook receivers run on a server you
/// control, not inside the client app. Unavailable on web - [start] throws
/// there, since it needs `dart:io`'s `HttpServer`.
abstract class LocalWebhookReceiver {
  factory LocalWebhookReceiver() = platform.LocalWebhookReceiverImpl;

  /// Emits each accepted request as it arrives.
  Stream<ReceivedWebhook> get events;

  bool get isRunning;

  /// Starts listening on loopback and returns the bound URL
  /// (e.g. `http://127.0.0.1:54231/webhook`). If [secret] is provided,
  /// incoming requests are verified against it (see [ReceivedWebhook.signatureVerified]).
  Future<Uri> start({int port = 0, String? secret});

  Future<void> stop();
}
