import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/domain/usecases/login_use_case.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/domain/usecases/logout_use_case.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/domain/usecases/register_use_case.dart';

// Auth state
class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final UserEntity? user;
  final String? errorMessage;

  const AuthState({
    this.isAuthenticated = false,
    this.isLoading = false,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    UserEntity? user,
    String? errorMessage,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      errorMessage: errorMessage,
    );
  }
}

// Auth notifier
// Auth notifier
class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    return const AuthState();
  }

  // Check auth status
  Future<void> checkAuthStatus() async {
    // Here you would typically check if there's a valid token stored
    // and validate it with your API if necessary

    // For now, we'll just return false
    state = state.copyWith(isAuthenticated: false, user: null);
  }

  // Login
  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final loginUseCase = ref.read(loginUseCaseProvider);
    final result = await loginUseCase.execute(email: email, password: password);

    if (!ref.exists(authProvider)) return;

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        errorMessage: failure.message,
      ),
      (user) => state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: user,
        errorMessage: null,
      ),
    );
  }

  // Register
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final registerUseCase = ref.read(registerUseCaseProvider);
    final result = await registerUseCase.execute(
      name: name,
      email: email,
      password: password,
    );

    if (!ref.exists(authProvider)) return;

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        errorMessage: failure.message,
      ),
      (user) => state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: user,
        errorMessage: null,
      ),
    );
  }

  // Logout
  Future<void> logout() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    final logoutUseCase = ref.read(logoutUseCaseProvider);
    final result = await logoutUseCase.execute();

    if (!ref.exists(authProvider)) return;

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        errorMessage: failure.message,
      ),
      (_) => state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        user: null,
        errorMessage: null,
      ),
    );
  }
}

// Auth provider
final authProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
