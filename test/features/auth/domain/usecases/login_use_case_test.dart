import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/domain/usecases/login_use_case.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LoginUseCase useCase;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    useCase = LoginUseCase(mockAuthRepository);
  });

  const tEmail = 'test@example.com';
  const tPassword = 'password123';
  const tUser = UserEntity(id: '1', email: tEmail, name: 'Test User');

  test('should return UserEntity when login is successful', () async {
    // Arrange
    when(
      () => mockAuthRepository.login(email: tEmail, password: tPassword),
    ).thenAnswer((_) async => const Right(tUser));

    // Act
    final result = await useCase.execute(email: tEmail, password: tPassword);

    // Assert
    expect(result, const Right(tUser));
    verify(
      () => mockAuthRepository.login(email: tEmail, password: tPassword),
    ).called(1);
  });

  test('should return ServerFailure when login fails', () async {
    // Arrange
    const tFailure = ServerFailure(message: 'Login failed');
    when(
      () => mockAuthRepository.login(email: tEmail, password: tPassword),
    ).thenAnswer((_) async => const Left(tFailure));

    // Act
    final result = await useCase.execute(email: tEmail, password: tPassword);

    // Assert
    expect(result, const Left(tFailure));
    verify(
      () => mockAuthRepository.login(email: tEmail, password: tPassword),
    ).called(1);
  });

  test('should return InputFailure when email is empty', () async {
    // Act
    final result = await useCase.execute(email: '', password: tPassword);

    // Assert
    // We need to match based on type because instances might differ if equality not implemented for InputFailure
    // Assuming failures extend Equatable, otherwise matching might be tricky.
    // Ideally code: return Left(InputFailure(...))
    result.fold(
      (failure) => expect(failure, isA<InputFailure>()),
      (_) => fail('Should have returned failure'),
    );

    verifyZeroInteractions(mockAuthRepository);
  });
}
