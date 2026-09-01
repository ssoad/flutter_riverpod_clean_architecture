import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'greeter_client_stub.dart'
    if (dart.library.io) 'greeter_client_io.dart'
    as platform;

/// A small wrapper around the generated `GreeterClient` gRPC stub
/// (`greeter.pbgrpc.dart`), demonstrating both an RPC style:
/// - [sayHello]: unary, one request, one response.
/// - [sayHelloStream]: server-streaming, one request, many responses.
///
/// `helloworld.Greeter/SayHello` is the canonical gRPC "hello world"
/// contract, so [connect] defaults to the public `grpcb.in:9000` test
/// server and the unary call works with no setup. `SayHelloStream` is a
/// template-specific extension; run `tool/grpc_demo_server.dart` locally
/// (see its header comment) and connect to `localhost:50051` to exercise it
/// end-to-end.
///
/// Unavailable on web: real gRPC needs an HTTP/2 socket (`dart:io`), and
/// grpc-web needs a translating proxy in front of the server, which this
/// demo's target servers don't provide.
abstract class GrpcGreeterClient {
  factory GrpcGreeterClient() = platform.GrpcGreeterClientImpl;

  bool get isConnected;

  void connect({required String host, required int port, bool useTls = false});

  Future<String> sayHello(String name);

  Stream<String> sayHelloStream(String name);

  Future<void> disconnect();
}

/// A fresh client per subscriber, disconnected automatically when no longer
/// watched.
final grpcGreeterClientProvider = Provider.autoDispose<GrpcGreeterClient>((
  ref,
) {
  final client = GrpcGreeterClient();
  ref.onDispose(client.disconnect);
  return client;
});
