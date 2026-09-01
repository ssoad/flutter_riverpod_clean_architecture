import 'package:grpc/grpc.dart';

import 'greeter.pbgrpc.dart';
import 'greeter_client.dart';

/// `dart:io`-backed implementation using a real HTTP/2 `ClientChannel`,
/// used on every platform except web.
class GrpcGreeterClientImpl implements GrpcGreeterClient {
  ClientChannel? _channel;
  GreeterClient? _stub;

  @override
  bool get isConnected => _channel != null;

  @override
  void connect({required String host, required int port, bool useTls = false}) {
    disconnect();
    final channel = ClientChannel(
      host,
      port: port,
      options: ChannelOptions(
        credentials: useTls
            ? const ChannelCredentials.secure()
            : const ChannelCredentials.insecure(),
      ),
    );
    _channel = channel;
    _stub = GreeterClient(channel);
  }

  @override
  Future<String> sayHello(String name) async {
    final stub = _requireStub();
    final reply = await stub.sayHello(HelloRequest(name: name));
    return reply.message;
  }

  @override
  Stream<String> sayHelloStream(String name) {
    final stub = _requireStub();
    return stub
        .sayHelloStream(HelloRequest(name: name))
        .map((reply) => reply.message);
  }

  GreeterClient _requireStub() {
    final stub = _stub;
    if (stub == null) {
      throw StateError('Not connected. Call connect() first.');
    }
    return stub;
  }

  @override
  Future<void> disconnect() async {
    await _channel?.shutdown();
    _channel = null;
    _stub = null;
  }
}
