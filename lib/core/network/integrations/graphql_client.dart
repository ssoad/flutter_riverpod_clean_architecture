import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Thrown when a GraphQL endpoint responds with an `errors` array (a
/// successful HTTP 200 can still carry GraphQL-level errors) or when the
/// transport itself fails.
class GraphQLException implements Exception {
  GraphQLException(this.errors);

  final List<String> errors;

  @override
  String toString() => errors.join('; ');
}

/// A thin GraphQL client built directly on Dio.
///
/// GraphQL over HTTP is just a POST with a JSON body of
/// `{query, variables, operationName}` and a JSON response of
/// `{data, errors}` - there's no need for a dedicated client library (and
/// its own state-management/widget-tree conventions) to use it from an app
/// that already has an HTTP client and Riverpod. `query` and `mutate` are
/// the same operation under the hood; they're split only for readability at
/// call sites.
class GraphQLClient {
  GraphQLClient(this._dio, {required this.endpoint});

  final Dio _dio;
  final String endpoint;

  Future<Map<String, dynamic>> query(
    String document, {
    Map<String, dynamic>? variables,
    String? operationName,
  }) => _execute(document, variables: variables, operationName: operationName);

  Future<Map<String, dynamic>> mutate(
    String document, {
    Map<String, dynamic>? variables,
    String? operationName,
  }) => _execute(document, variables: variables, operationName: operationName);

  Future<Map<String, dynamic>> _execute(
    String document, {
    Map<String, dynamic>? variables,
    String? operationName,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(
        endpoint,
        data: {
          'query': document,
          'variables': ?variables,
          'operationName': ?operationName,
        },
        options: Options(headers: {'Content-Type': 'application/json'}),
      );

      final body = response.data ?? const <String, dynamic>{};
      final errors = body['errors'] as List<dynamic>?;
      if (errors != null && errors.isNotEmpty) {
        throw GraphQLException(
          errors
              .map(
                (e) =>
                    (e as Map<String, dynamic>)['message']?.toString() ??
                    'Unknown GraphQL error',
              )
              .toList(),
        );
      }
      return (body['data'] as Map<String, dynamic>?) ?? const {};
    } on DioException catch (e) {
      throw GraphQLException([e.message ?? 'Network error']);
    }
  }
}

/// One client per [endpoint], so a screen can talk to multiple GraphQL APIs
/// without them sharing headers/interceptors.
final graphQLClientProvider = Provider.autoDispose
    .family<GraphQLClient, String>(
      (ref, endpoint) => GraphQLClient(Dio(), endpoint: endpoint),
    );
