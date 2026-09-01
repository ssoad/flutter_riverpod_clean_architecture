import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/domain/usecases/update_profile_use_case.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/domain/entities/user_entity.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late UpdateProfileUseCase useCase;
  late MockAuthRepository mockAuthRepository;

  setUpAll(() {
    registerFallbackValue(UserEntity.empty());
  });

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    useCase = UpdateProfileUseCase(mockAuthRepository);
  });

  const tUser = UserEntity(
    id: '1',
    name: 'Jane Doe',
    email: 'jane@example.com',
  );

  test('should return updated UserEntity when the update succeeds', () async {
    when(
      () => mockAuthRepository.updateProfile(tUser),
    ).thenAnswer((_) async => const Right(tUser));

    final result = await useCase.execute(tUser);

    expect(result, const Right(tUser));
    verify(() => mockAuthRepository.updateProfile(tUser)).called(1);
  });

  test('should return InputFailure when name is empty', () async {
    final result = await useCase.execute(tUser.copyWith(name: ''));

    result.fold(
      (failure) => expect(failure, isA<InputFailure>()),
      (_) => fail('Should have returned a failure'),
    );
    verifyZeroInteractions(mockAuthRepository);
  });

  test('should return InputFailure when email is invalid', () async {
    final result = await useCase.execute(tUser.copyWith(email: 'not-an-email'));

    result.fold(
      (failure) => expect(failure, isA<InputFailure>()),
      (_) => fail('Should have returned a failure'),
    );
    verifyZeroInteractions(mockAuthRepository);
  });

  test('should propagate a Failure from the repository', () async {
    const tFailure = ServerFailure(message: 'Update failed');
    when(
      () => mockAuthRepository.updateProfile(tUser),
    ).thenAnswer((_) async => const Left(tFailure));

    final result = await useCase.execute(tUser);

    expect(result, const Left(tFailure));
  });
}
