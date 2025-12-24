# Architecture Guide

This project follows strict **Clean Architecture** principles, adapted for Flutter using **Riverpod** 2.0. The core goal is separation of concerns and testability.

---

## 1. The Dependency Rule

The most important rule in this architecture: **Source code dependencies can only point inwards.**

```mermaid
graph TD
    Presentation[Presentation Layer (Flutter)] --> Domain[Domain Layer (Pure Dart)]
    Data[Data Layer (Impl)] --> Domain
    Presentation --> Data -- DI only --> Domain
```

- **Domain Layer**: Knows NOTHING about Flutter, Data, or Presentation.
- **Data Layer**: Knows about Domain. Implements interfaces defined in Domain.
- **Presentation Layer**: Knows about Domain. Uses Data layer *only* for Dependency Injection.

---

## 2. Layer Breakdown

### 🟡 Domain Layer (The Core)
**Path:** `lib/features/[feature]/domain/`

This is the heart of your feature. It contains the business logic.
- **Dependencies**: Pure Dart only. (Exception: `fpdart`, `equatable`).
- **Entities**: Simple data classes extending `Equatable`.
- **Repositories (Interfaces)**: Abstract definitions of what data operations are possible.
- **Use Cases**: Encapsulate a single business action (e.g., `LoginUseCase`, `SendMessageUseCase`).

**Example Use Case:**
```dart
class LoginUseCase {
  final AuthRepository _repository; // Depends on interface, not implementation

  LoginUseCase(this._repository);

  Future<Either<Failure, UserEntity>> execute(String email, String password) {
    return _repository.login(email, password);
  }
}
```

### 🔵 Data Layer (The Infrastructure)
**Path:** `lib/features/[feature]/data/`

Handles data retrieval and storage.
- **Dependencies**: Domain Layer, External Packages (Dio, Hive, etc.).
- **Models**: Extensions of Entities with `fromJson`/`toJson` methods.
- **Data Sources**: Low-level data access (API calls, DB queries).
- **Repositories (Implementations)**: Implement Domain interfaces. Maps Exceptions to Failures.

**Example Repository Impl:**
```dart
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  // Error handling happens here!
  @override
  Future<Either<Failure, UserEntity>> login(String email, String password) async {
    try {
      final model = await _remoteDataSource.login(email, password);
      return Right(model.toEntity());
    } on NetworkException {
      return Left(NetworkFailure());
    }
  }
}
```

### 🟢 Presentation Layer (The UI)
**Path:** `lib/features/[feature]/presentation/`

Displays data and handles user events.
- **Dependencies**: Domain Layer, Flutter, Riverpod.
- **Providers**: Manage UI state (loading, success, error).
- **Screens**: Stupid widgets that watch providers.
- **Widgets**: Reusable components.

**Example Notifier:**
```dart
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState.initial();

  Future<void> login(String email, String password) async {
    state = const AuthState.loading();
    
    // Use Case injected via Riverpod
    final loginUseCase = ref.read(loginUseCaseProvider);
    final result = await loginUseCase.execute(email, password);

    state = result.fold(
      (failure) => AuthState.error(failure.message),
      (user) => AuthState.authenticated(user),
    );
  }
}
```

### 🟣 DI Layer (The Glue)
**Path:** `lib/features/[feature]/providers/`

Connects the layers using Riverpod.
- **Dependencies**: Data, Domain, Presentation.

```dart
// connect domain interface to data implementation
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(ref.watch(remoteDataSourceProvider));
});
```

---

## 3. Key Concepts & Patterns

### Functional Error Handling (`fpdart`)
We do NOT throw exceptions in the Domain layer. Instead, we return `Either<Failure, Success>`.

- **User**: "I want to login."
- **Use Case**: Returns `Either<Failure, User>`.
- **UI**: 
  ```dart
  result.fold(
    (failure) => showError(failure),
    (user) => navigateToHome(user),
  );
  ```

### Framework Independence
To keep the Data layer testable, we avoid `flutter` imports.
- **Logging**: Use `Logger` from `core/utils/logger.dart` instead of `debugPrint`.
- **Context**: Never pass `BuildContext` to Use Cases or Repositories.

### Provider Organization
We separate Data DI from UI State:
- **`[feature]_providers.dart`**: Provides Repositories, Use Cases, Data Sources.
- **`[feature]_provider.dart`**: Provides `NotifierProvider` for UI state.

---

## 4. Testing Strategy

### Unit Tests (Domain/Data)
Test logic in isolation. Mock dependencies using `mocktail`.
```dart
test('should return User when login is successful', () async {
  // Arrange
  when(() => mockRepo.login(any(), any()))
    .thenAnswer((_) async => Right(tUser));
  
  // Act
  final result = await useCase.execute('test@test.com', 'pass');
  
  // Assert
  expect(result, Right(tUser));
});
```

### Golden Tests (Presentation)
Verify UI rendering pixel-by-pixel.
```dart
testGoldens('LoginScreen renders correctly', (tester) async {
  await tester.pumpWidgetBuilder(LoginScreen());
  await screenMatchesGolden(tester, 'login_screen');
});
```
