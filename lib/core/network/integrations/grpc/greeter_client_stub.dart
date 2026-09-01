import 'greeter_client.dart';

/// Web fallback: a real gRPC HTTP/2 connection needs `dart:io` sockets, and
/// grpc-web (the browser-compatible variant) needs a translating proxy in
/// front of the server, so this demo simply isn't offered on web.
class GrpcGreeterClientImpl implements GrpcGreeterClient {
  @override
  bool get isConnected => false;

  @override
  void connect({required String host, required int port, bool useTls = false}) {
    throw UnsupportedError(
      'gRPC over a raw HTTP/2 socket is not available on web. Use '
      'package:grpc/grpc_web.dart with a grpc-web-compatible proxy '
      '(e.g. Envoy) in front of your server instead.',
    );
  }

  @override
  Future<String> sayHello(String name) => throw UnsupportedError(
    'gRPC over a raw HTTP/2 socket is not available on web.',
  );

  @override
  Stream<String> sayHelloStream(String name) => throw UnsupportedError(
    'gRPC over a raw HTTP/2 socket is not available on web.',
  );

  @override
  Future<void> disconnect() async {}
}
