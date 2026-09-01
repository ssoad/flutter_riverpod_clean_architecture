import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod_clean_architecture/core/network/integrations/graphql_client.dart';

class MockDio extends Mock implements Dio {}

class MockResponse extends Mock implements Response<Map<String, dynamic>> {}

void main() {
  late GraphQLClient client;
  late MockDio mockDio;

  const endpoint = 'https://example.com/graphql';

  setUp(() {
    mockDio = MockDio();
    client = GraphQLClient(mockDio, endpoint: endpoint);
    registerFallbackValue(Options());
  });

  group('GraphQLClient', () {
    test('query returns the data map on success', () async {
      final response = MockResponse();
      when(() => response.data).thenReturn({
        'data': {
          'post': {'id': '1', 'title': 'Hello'},
        },
      });
      when(
        () => mockDio.post<Map<String, dynamic>>(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenAnswer((_) async => response);

      final data = await client.query('query { post(id: 1) { id title } }');

      expect(data, {
        'post': {'id': '1', 'title': 'Hello'},
      });
    });

    test('throws GraphQLException when the response carries errors', () async {
      final response = MockResponse();
      when(() => response.data).thenReturn({
        'errors': [
          {'message': 'Post not found'},
        ],
      });
      when(
        () => mockDio.post<Map<String, dynamic>>(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenAnswer((_) async => response);

      expect(
        () => client.query('query { post(id: 999) { id } }'),
        throwsA(
          isA<GraphQLException>().having(
            (e) => e.errors,
            'errors',
            contains('Post not found'),
          ),
        ),
      );
    });

    test('throws GraphQLException when the transport fails', () async {
      when(
        () => mockDio.post<Map<String, dynamic>>(
          any(),
          data: any(named: 'data'),
          options: any(named: 'options'),
        ),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: endpoint),
          message: 'Connection failed',
        ),
      );

      expect(
        () => client.mutate('mutation { createPost { id } }'),
        throwsA(isA<GraphQLException>()),
      );
    });
  });
}
