// This is a generated file - do not edit.
//
// Generated from greeter.proto.

// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names
// ignore_for_file: curly_braces_in_flow_control_structures
// ignore_for_file: deprecated_member_use_from_same_package, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_relative_imports

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'greeter.pb.dart' as $0;

export 'greeter.pb.dart';

@$pb.GrpcServiceName('helloworld.Greeter')
class GreeterClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  GreeterClient(super.channel, {super.options, super.interceptors});

  /// Unary RPC: one request, one response.
  $grpc.ResponseFuture<$0.HelloReply> sayHello(
    $0.HelloRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createUnaryCall(_$sayHello, request, options: options);
  }

  /// Server-streaming RPC: one request, a stream of responses.
  $grpc.ResponseStream<$0.HelloReply> sayHelloStream(
    $0.HelloRequest request, {
    $grpc.CallOptions? options,
  }) {
    return $createStreamingCall(
        _$sayHelloStream, $async.Stream.fromIterable([request]),
        options: options);
  }

  // method descriptors

  static final _$sayHello = $grpc.ClientMethod<$0.HelloRequest, $0.HelloReply>(
      '/helloworld.Greeter/SayHello',
      ($0.HelloRequest value) => value.writeToBuffer(),
      $0.HelloReply.fromBuffer);
  static final _$sayHelloStream =
      $grpc.ClientMethod<$0.HelloRequest, $0.HelloReply>(
          '/helloworld.Greeter/SayHelloStream',
          ($0.HelloRequest value) => value.writeToBuffer(),
          $0.HelloReply.fromBuffer);
}

@$pb.GrpcServiceName('helloworld.Greeter')
abstract class GreeterServiceBase extends $grpc.Service {
  $core.String get $name => 'helloworld.Greeter';

  GreeterServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.HelloRequest, $0.HelloReply>(
        'SayHello',
        sayHello_Pre,
        false,
        false,
        ($core.List<$core.int> value) => $0.HelloRequest.fromBuffer(value),
        ($0.HelloReply value) => value.writeToBuffer()));
    $addMethod($grpc.ServiceMethod<$0.HelloRequest, $0.HelloReply>(
        'SayHelloStream',
        sayHelloStream_Pre,
        false,
        true,
        ($core.List<$core.int> value) => $0.HelloRequest.fromBuffer(value),
        ($0.HelloReply value) => value.writeToBuffer()));
  }

  $async.Future<$0.HelloReply> sayHello_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.HelloRequest> $request) async {
    return sayHello($call, await $request);
  }

  $async.Future<$0.HelloReply> sayHello(
      $grpc.ServiceCall call, $0.HelloRequest request);

  $async.Stream<$0.HelloReply> sayHelloStream_Pre(
      $grpc.ServiceCall $call, $async.Future<$0.HelloRequest> $request) async* {
    yield* sayHelloStream($call, await $request);
  }

  $async.Stream<$0.HelloReply> sayHelloStream(
      $grpc.ServiceCall call, $0.HelloRequest request);
}
