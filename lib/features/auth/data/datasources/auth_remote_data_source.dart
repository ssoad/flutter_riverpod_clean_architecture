import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/exceptions.dart';
import 'package:flutter_riverpod_clean_architecture/core/network/api_client.dart';
import 'package:flutter_riverpod_clean_architecture/core/utils/app_utils.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/data/models/user_model.dart';

abstract class AuthRemoteDataSource {
  /// Login a user with email and password
  Future<UserModel> login({required String email, required String password});
  
  /// Register a new user
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;
  
  AuthRemoteDataSourceImpl(this._apiClient);

  @override
  Future<UserModel> login({required String email, required String password}) async {
    try {
      // Check network connection
      final hasNetwork = await AppUtils.hasNetworkConnection();
      if (!hasNetwork) {
        throw NetworkException();
      }
      
      // In a real app, you would make an API call here
      // For this template, we'll simulate a successful login
      
      // Simulating a backend call with delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Create a mock user for demonstration
      return UserModel(
        id: 'user-123',
        name: 'John Doe',
        email: email,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // In real implementation:
      // final response = await _apiClient.post('/auth/login', data: {
      //   'email': email,
      //   'password': password,
      // });
      // return UserModel.fromJson(response['user']);
    } on Exception catch (e) {
      throw _handleException(e);
    }
  }

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // Check network connection
      final hasNetwork = await AppUtils.hasNetworkConnection();
      if (!hasNetwork) {
        throw NetworkException();
      }
      
      // In a real app, you would make an API call here
      // For this template, we'll simulate a successful registration
      
      // Simulating a backend call with delay
      await Future.delayed(const Duration(seconds: 1));
      
      // Create a mock user for demonstration
      return UserModel(
        id: 'user-${DateTime.now().millisecondsSinceEpoch}',
        name: name,
        email: email,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      // In real implementation:
      // final response = await _apiClient.post('/auth/register', data: {
      //   'name': name,
      //   'email': email,
      //   'password': password,
      // });
      // return UserModel.fromJson(response['user']);
    } on Exception catch (e) {
      throw _handleException(e);
    }
  }
  
  // Helper method to handle exceptions
  Exception _handleException(Exception e) {
    if (e is NetworkException || 
        e is ServerException || 
        e is UnauthorizedException || 
        e is BadRequestException) {
      return e;
    }
    return ServerException(message: e.toString());
  }
}

// Provider
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AuthRemoteDataSourceImpl(apiClient);
});

// ApiClient provider
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());
