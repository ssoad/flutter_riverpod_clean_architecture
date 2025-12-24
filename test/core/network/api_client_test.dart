import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod_clean_architecture/core/network/api_client.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/exceptions.dart';

class MockDio extends Mock implements Dio {}

class MockResponse extends Mock implements Response {}

void main() {
  late ApiClient apiClient;
  late MockDio mockDio;

  setUp(() {
    mockDio = MockDio();
    apiClient = ApiClient(mockDio);
  });

  group('ApiClient', () {
    const tPath = '/test';
    final tResponseData = {'success': true};

    test('get should perform a GET request and return data', () async {
      // Arrange
      final response = MockResponse();
      when(() => response.data).thenReturn(tResponseData);
      when(() => response.statusCode).thenReturn(200);
      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenAnswer((_) async => response);

      // Act
      final result = await apiClient.get(tPath);

      // Assert
      verify(() => mockDio.get(tPath));
      expect(result, tResponseData);
    });

    test('get should throw ServerException when DioException occurs', () async {
      // Arrange
      when(
        () =>
            mockDio.get(any(), queryParameters: any(named: 'queryParameters')),
      ).thenThrow(
        DioException(
          requestOptions: RequestOptions(path: tPath),
          type: DioExceptionType.badResponse,
          response: Response(
            requestOptions: RequestOptions(path: tPath),
            statusCode: 500,
            data: {'message': 'Server Error'},
          ),
        ),
      );

      // Act & Assert
      expect(() => apiClient.get(tPath), throwsA(isA<ServerException>()));
    });
  });
}
