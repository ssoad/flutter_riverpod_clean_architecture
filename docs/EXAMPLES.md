# Code Examples

This document provides practical code examples showing how to use the key features of the Flutter Riverpod Clean Architecture template.

## Using Extensions

### DateTime Extensions

```dart
import 'package:flutter_riverpod_clean_architecture/core/utils/extensions/datetime_extensions.dart';

void exampleDateTimeExtensions() {
  final now = DateTime.now();
  
  // Format the date
  print(now.formatAs('MMMM d, yyyy')); // June 15, 2025
  
  // Get relative time
  print(now.subtract(Duration(minutes: 5)).timeAgo); // 5 minutes ago
  
  // Add time
  final tomorrow = now.addDays(1);
  
  // Check if date is today/tomorrow/yesterday
  print(now.isToday); // true
  print(tomorrow.isTomorrow); // true
  
  // Start/end of period
  final startOfMonth = now.startOfMonth;
  final endOfDay = now.endOfDay;
  
  // Custom week
  final weekStart = now.startOfWeek(firstDayOfWeek: DateTime.monday);
}
```

### BuildContext Extensions

```dart
import 'package:flutter_riverpod_clean_architecture/core/utils/extensions/context_extensions.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Screen properties
    final width = context.screenWidth;
    final height = context.screenHeight;
    final isTablet = context.isTablet;
    final isDarkMode = context.isDarkMode;
    
    // Theme shortcuts
    final primaryColor = context.colorScheme.primary;
    final bodyTextStyle = context.textTheme.bodyMedium;
    
    // Localization
    final welcomeMessage = context.tr('welcome_message');
    final formattedDate = context.formatDate(DateTime.now(), 'short');
    final formattedCurrency = context.formatCurrency(19.99);
    
    // Navigation
    context.pop();
    context.pushNamed('/details', params: {'id': '123'});
    
    // UI helpers
    context.showSnackBar('Operation successful');
    
    return Container();
  }
}
```

## Feature Implementation

### Authentication Feature

#### Domain Layer (entities)

```dart
// lib/features/auth/domain/entities/user_entity.dart
class UserEntity {
  final String id;
  final String email;
  final String name;
  final String? photoUrl;
  
  UserEntity({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
  });
}
```

#### Domain Layer (repositories)

```dart
// lib/features/auth/domain/repositories/auth_repository.dart
abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> signIn(String email, String password);
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, UserEntity>> getCurrentUser();
}
```

#### Domain Layer (usecases)

```dart
// lib/features/auth/domain/usecases/sign_in_usecase.dart
class SignInUseCase {
  final AuthRepository repository;
  
  SignInUseCase(this.repository);
  
  Future<Either<Failure, UserEntity>> call(SignInParams params) {
    return repository.signIn(params.email, params.password);
  }
}

class SignInParams {
  final String email;
  final String password;
  
  SignInParams({required this.email, required this.password});
}
```

#### Data Layer (models)

```dart
// lib/features/auth/data/models/user_model.dart
class UserModel {
  final String id;
  final String email;
  final String name;
  final String? photoUrl;
  
  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.photoUrl,
  });
  
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      photoUrl: json['photoUrl'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'photoUrl': photoUrl,
    };
  }
  
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      name: name,
      photoUrl: photoUrl,
    );
  }
}
```

#### Data Layer (datasources)

```dart
// lib/features/auth/data/datasources/auth_remote_datasource.dart
abstract class AuthRemoteDataSource {
  Future<UserModel> signIn(String email, String password);
  Future<void> signOut();
  Future<UserModel?> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;
  
  AuthRemoteDataSourceImpl(this.apiClient);
  
  @override
  Future<UserModel> signIn(String email, String password) async {
    final response = await apiClient.post('/auth/login', {
      'email': email,
      'password': password,
    });
    
    return UserModel.fromJson(response.data['user']);
  }
  
  @override
  Future<void> signOut() async {
    await apiClient.post('/auth/logout', {});
  }
  
  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final response = await apiClient.get('/auth/user');
      return UserModel.fromJson(response.data['user']);
    } catch (e) {
      return null;
    }
  }
}
```

#### Data Layer (repositories)

```dart
// lib/features/auth/data/repositories/auth_repository_impl.dart
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  
  AuthRepositoryImpl(this.remoteDataSource, this.localDataSource);
  
  @override
  Future<Either<Failure, UserEntity>> signIn(String email, String password) async {
    try {
      final userModel = await remoteDataSource.signIn(email, password);
      await localDataSource.saveUser(userModel);
      return Right(userModel.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to sign in: ${e.toString()}'));
    }
  }
  
  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await remoteDataSource.signOut();
      await localDataSource.clearUser();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to sign out: ${e.toString()}'));
    }
  }
  
  @override
  Future<Either<Failure, UserEntity>> getCurrentUser() async {
    try {
      // Try to get user from local storage first
      final localUser = await localDataSource.getUser();
      if (localUser != null) {
        return Right(localUser.toEntity());
      }
      
      // If not available locally, try to get from remote
      final remoteUser = await remoteDataSource.getCurrentUser();
      if (remoteUser != null) {
        await localDataSource.saveUser(remoteUser);
        return Right(remoteUser.toEntity());
      }
      
      return Left(AuthFailure(message: 'User not authenticated'));
    } catch (e) {
      return Left(ServerFailure(message: 'Failed to get current user: ${e.toString()}'));
    }
  }
}
```

#### Presentation Layer (providers)

```dart
// lib/features/auth/presentation/providers/auth_provider.dart
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remoteDataSource = ref.watch(authRemoteDataSourceProvider);
  final localDataSource = ref.watch(authLocalDataSourceProvider);
  return AuthRepositoryImpl(remoteDataSource, localDataSource);
});

final signInUseCaseProvider = Provider<SignInUseCase>((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignInUseCase(repository);
});

final authStateProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final signInUseCase = ref.watch(signInUseCaseProvider);
  final signOutUseCase = ref.watch(signOutUseCaseProvider);
  final getCurrentUserUseCase = ref.watch(getCurrentUserUseCaseProvider);
  
  return AuthNotifier(
    signInUseCase: signInUseCase,
    signOutUseCase: signOutUseCase,
    getCurrentUserUseCase: getCurrentUserUseCase,
  );
});

class AuthNotifier extends StateNotifier<AuthState> {
  final SignInUseCase signInUseCase;
  final SignOutUseCase signOutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  
  AuthNotifier({
    required this.signInUseCase,
    required this.signOutUseCase,
    required this.getCurrentUserUseCase,
  }) : super(const AuthState.initial()) {
    checkCurrentUser();
  }
  
  Future<void> checkCurrentUser() async {
    state = const AuthState.loading();
    
    final result = await getCurrentUserUseCase(NoParams());
    
    state = result.fold(
      (failure) => const AuthState.unauthenticated(),
      (user) => AuthState.authenticated(user),
    );
  }
  
  Future<void> signIn(String email, String password) async {
    state = const AuthState.loading();
    
    final params = SignInParams(email: email, password: password);
    final result = await signInUseCase(params);
    
    state = result.fold(
      (failure) => AuthState.error(failure.message),
      (user) => AuthState.authenticated(user),
    );
  }
  
  Future<void> signOut() async {
    state = const AuthState.loading();
    
    final result = await signOutUseCase(NoParams());
    
    state = result.fold(
      (failure) => AuthState.error(failure.message),
      (_) => const AuthState.unauthenticated(),
    );
  }
}
```

#### Presentation Layer (state)

```dart
// lib/features/auth/presentation/providers/auth_state.dart
@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = _Initial;
  const factory AuthState.loading() = _Loading;
  const factory AuthState.authenticated(UserEntity user) = _Authenticated;
  const factory AuthState.unauthenticated() = _Unauthenticated;
  const factory AuthState.error(String message) = _Error;
}
```

#### Presentation Layer (screen)

```dart
// lib/features/auth/presentation/screens/login_screen.dart
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  
  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(authStateProvider.notifier).signIn(
        _emailController.text,
        _passwordController.text,
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('login.title')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: context.tr('login.email_label'),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return context.tr('login.email_required');
                  }
                  if (!value!.contains('@')) {
                    return context.tr('login.email_invalid');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: context.tr('login.password_label'),
                ),
                obscureText: true,
                validator: (value) {
                  if (value?.isEmpty ?? true) {
                    return context.tr('login.password_required');
                  }
                  if ((value?.length ?? 0) < 6) {
                    return context.tr('login.password_too_short');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              authState.maybeWhen(
                loading: () => const CircularProgressIndicator(),
                error: (message) => Text(message, style: TextStyle(color: Colors.red)),
                orElse: () => ElevatedButton(
                  onPressed: _handleLogin,
                  child: Text(context.tr('login.button')),
                ),
              ),
              if (authState.maybeWhen(
                error: (_) => true,
                orElse: () => false,
              ))
                const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
```

For more code examples, see the `lib/examples` directory in the project.
