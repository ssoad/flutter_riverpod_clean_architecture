import 'local_webhook_receiver.dart';

/// Web fallback: `dart:io`'s `HttpServer` doesn't exist in a browser, so the
/// local receiver simply isn't offered there.
class LocalWebhookReceiverImpl implements LocalWebhookReceiver {
  @override
  Stream<ReceivedWebhook> get events => const Stream.empty();

  @override
  bool get isRunning => false;

  @override
  Future<Uri> start({int port = 0, String? secret}) {
    throw UnsupportedError(
      'The local webhook receiver uses dart:io HttpServer and is not '
      'available on web. Run this demo on a desktop or mobile debug build.',
    );
  }

  @override
  Future<void> stop() async {}
}
