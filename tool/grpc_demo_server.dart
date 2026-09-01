// A local reference server for the gRPC integration example
// (lib/examples/integrations/grpc_example_screen.dart).
//
// The demo's unary `SayHello` call works out of the box against the public
// `grpcb.in:9000` test server, but no public server implements this
// project's `SayHelloStream` extension. Run this script to get a real
// server for both RPCs:
//
//   dart run tool/grpc_demo_server.dart
//
// Then point the demo screen at `localhost:50051` (the default it offers).
//
// This is a dev tool, not part of the shipped app - it's excluded from the
// `lib/` build and only depends on packages already in pubspec.yaml.

import 'dart:async';

import 'package:grpc/grpc.dart';
import 'package:flutter_riverpod_clean_architecture/core/network/integrations/grpc/greeter.pbgrpc.dart';

class GreeterService extends GreeterServiceBase {
  @override
  Future<HelloReply> sayHello(ServiceCall call, HelloRequest request) async {
    return HelloReply(message: 'Hello, ${request.name}!');
  }

  @override
  Stream<HelloReply> sayHelloStream(
    ServiceCall call,
    HelloRequest request,
  ) async* {
    for (var i = 1; i <= 5; i++) {
      await Future<void>.delayed(const Duration(seconds: 1));
      yield HelloReply(message: 'Hello, ${request.name}! (update $i/5)');
    }
  }
}

Future<void> main(List<String> args) async {
  final port = args.isNotEmpty ? int.parse(args.first) : 50051;
  final server = Server.create(services: [GreeterService()]);
  await server.serve(port: port);
  // ignore: avoid_print
  print('gRPC demo server listening on localhost:${server.port}');
}
