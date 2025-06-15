---
title: Architecture Guide
description: Detailed explanation of the project structure and principles
---

<!-- Heading defined in front matter, no need for duplicate -->

This guide explains the architectural principles and patterns used in the Flutter Riverpod Clean Architecture template.

## Table of Contents

- [Overview](#overview)
- [Clean Architecture](#clean-architecture)
- [Folder Structure](#folder-structure)
- [Dependency Injection with Riverpod](#riverpod)
- [State Management](#state-management)
- [Error Handling](#error-handling)
- [Testing Strategy](#testing-strategy)

## Overview

The architecture of this template is designed to create maintainable, testable, and scalable Flutter applications. It follows Clean Architecture principles while adapting them to Flutter's ecosystem using Riverpod for dependency injection and state management.

## Clean Architecture

This template implements Clean Architecture with the following layers:

### Domain Layer

The innermost layer containing business logic and models:

```dart
// Entity - Business object
class User {
  final String id;
  final String name;
  final String email;
  
  User({required this.id, required this.name, required this.email});
}

// Repository interface - Defines how data is accessed
abstract class UserRepository {
  Future<List<User>> getUsers();
  Future<User> getUserById(String id);
  Future<void> saveUser(User user);
}

// Use case - Business logic
class GetUserUseCase {
  final UserRepository repository;
  
  GetUserUseCase(this.repository);
  
  Future<User> execute(String id) async {
    return await repository.getUserById(id);
  }
}
```

### Data Layer

Contains repository implementations and data sources:

```dart
// Repository implementation
class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;
  final UserLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  
  UserRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });
  
  @override
  Future<User> getUserById(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteUser = await remoteDataSource.getUserById(id);
        await localDataSource.cacheUser(remoteUser);
        return remoteUser;
      } catch (e) {
        return await localDataSource.getLastCachedUser(id);
      }
    } else {
      return await localDataSource.getLastCachedUser(id);
    }
  }
  
  // Other methods...
}
```

### Presentation Layer

Contains UI components and view models:

```dart
// UI components using Riverpod providers
class UserProfileScreen extends ConsumerWidget {
  final String userId;
  
  const UserProfileScreen({required this.userId, Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userState = ref.watch(userProvider(userId));
    
    return Scaffold(
      appBar: AppBar(title: const Text('User Profile')),
      body: userState.when(
        data: (user) => UserProfileContent(user: user),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: ${error.toString()}'),
        ),
      ),
    );
  }
}
```

## Folder Structure

The project uses a feature-first structure:

```plaintext
lib/
├── core/                  # Core functionality used across features
│   ├── constants/         # App-wide constants
│   ├── error/             # Error handling
│   ├── network/           # Network utilities
│   ├── theme/             # App theming
│   └── utils/             # Utility functions
├── features/              # Feature modules
│   ├── auth/              # Authentication feature
│   │   ├── data/          # Data layer
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/        # Domain layer
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/  # Presentation layer
│   │       ├── providers/
│   │       ├── pages/
│   │       └── widgets/
│   └── profile/           # Another feature with the same structure
└── main.dart              # Application entry point
```

## Dependency Injection with Riverpod {#riverpod}

Riverpod provides an elegant way to handle dependency injection:

```dart
// Repository providers
final userRepositoryProvider = Provider<UserRepository>((ref) {
  final remoteDataSource = ref.watch(userRemoteDataSourceProvider);
  final localDataSource = ref.watch(userLocalDataSourceProvider);
  final networkInfo = ref.watch(networkInfoProvider);
  
  return UserRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
    networkInfo: networkInfo,
  );
});

// Use case providers
final getUserUseCaseProvider = Provider<GetUserUseCase>((ref) {
  final repository = ref.watch(userRepositoryProvider);
  return GetUserUseCase(repository);
});

// State providers
final userProvider = FutureProvider.family<User, String>((ref, id) async {
  final useCase = ref.watch(getUserUseCaseProvider);
  return await useCase.execute(id);
});
```

## State Management

The template uses Riverpod's state management capabilities:

- `StateProvider` - For simple state
- `StateNotifierProvider` - For complex state with multiple operations
- `FutureProvider` - For asynchronous data
- `StreamProvider` - For reactive streams

### Example: StateNotifier with Freezed

```dart
// State class using Freezed
@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated(User user) = _Authenticated;
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.error(String message) = _Error;
}

// StateNotifier class
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  
  AuthNotifier(this._repository) : super(const AuthState.initial());
  
  Future<void> checkAuthStatus() async {
    state = const AuthState.loading();
    try {
      final user = await _repository.getCurrentUser();
      if (user != null) {
        state = AuthState.authenticated(user);
      } else {
        state = const AuthState.unauthenticated();
      }
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }
  
  Future<void> signIn(String email, String password) async {
    state = const AuthState.loading();
    try {
      final user = await _repository.signIn(email, password);
      state = AuthState.authenticated(user);
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }
  
  Future<void> signOut() async {
    state = const AuthState.loading();
    try {
      await _repository.signOut();
      state = const AuthState.unauthenticated();
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }
}

// Provider definition
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return AuthNotifier(repository);
});
```

## Error Handling

The template provides a unified error handling system:

```dart
// App-specific exceptions
abstract class AppException implements Exception {
  String get message;
}

class NetworkException extends AppException {
  @override
  final String message;
  
  NetworkException([this.message = 'A network error occurred']);
}

class ServerException extends AppException {
  @override
  final String message;
  final int? statusCode;
  
  ServerException({this.statusCode, this.message = 'Server error occurred'});
}

// Error handler
class ErrorHandler {
  static String handleError(Object error) {
    if (error is AppException) {
      return error.message;
    } else if (error is SocketException) {
      return 'No internet connection';
    } else if (error is HttpException) {
      return 'HTTP error occurred';
    } else if (error is FormatException) {
      return 'Invalid format';
    } else {
      return 'An unexpected error occurred';
    }
  }
}

// Usage in repositories
try {
  // API call
} on DioError catch (e) {
  if (e.type == DioErrorType.connectTimeout) {
    throw NetworkException('Connection timeout');
  } else if (e.response != null) {
    throw ServerException(
      statusCode: e.response?.statusCode,
      message: e.response?.data?['message'] ?? 'Server error',
    );
  } else {
    throw NetworkException(e.message);
  }
}
```

## Testing Strategy

The template supports all types of testing:

### Unit Tests

```dart
void main() {
  late UserRepositoryImpl repository;
  late MockUserRemoteDataSource mockRemoteDataSource;
  late MockUserLocalDataSource mockLocalDataSource;
  late MockNetworkInfo mockNetworkInfo;

  setUp(() {
    mockRemoteDataSource = MockUserRemoteDataSource();
    mockLocalDataSource = MockUserLocalDataSource();
    mockNetworkInfo = MockNetworkInfo();
    repository = UserRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
      networkInfo: mockNetworkInfo,
    );
  });

  group('getUserById', () {
    test('should return remote data when the device is online', () async {
      // arrange
      when(mockNetworkInfo.isConnected).thenAnswer((_) async => true);
      when(mockRemoteDataSource.getUserById(any))
          .thenAnswer((_) async => tUser);
      // act
      final result = await repository.getUserById('1');
      // assert
      verify(mockRemoteDataSource.getUserById('1'));
      expect(result, equals(tUser));
    });
  });
}
```

### Widget Tests

```dart
void main() {
  testWidgets('UserProfileScreen shows user data when loaded', 
      (WidgetTester tester) async {
    // Build the widget with test providers
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userProvider('1').overrideWithValue(
            AsyncValue.data(User(id: '1', name: 'John Doe', email: 'john@example.com')),
          ),
        ],
        child: MaterialApp(
          home: UserProfileScreen(userId: '1'),
        ),
      ),
    );

    // Verify UI elements
    expect(find.text('John Doe'), findsOneWidget);
    expect(find.text('john@example.com'), findsOneWidget);
  });
}
```

### Integration Tests

```dart
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-end test', () {
    testWidgets('Full authentication flow', (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Navigate to login screen
      await tester.tap(find.byKey(Key('login_button')));
      await tester.pumpAndSettle();

      // Enter credentials
      await tester.enterText(find.byKey(Key('email_field')), 'test@example.com');
      await tester.enterText(find.byKey(Key('password_field')), 'password');
      await tester.tap(find.byKey(Key('submit_button')));
      await tester.pumpAndSettle();

      // Verify successful login
      expect(find.text('Welcome, Test User'), findsOneWidget);
    });
  });
}
```
