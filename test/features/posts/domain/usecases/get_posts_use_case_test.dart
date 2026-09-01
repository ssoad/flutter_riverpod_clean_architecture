import 'package:fpdart/fpdart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/features/posts/domain/entities/post_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/posts/domain/repositories/post_repository.dart';
import 'package:flutter_riverpod_clean_architecture/features/posts/domain/usecases/get_posts_use_case.dart';

class MockPostRepository extends Mock implements PostRepository {}

void main() {
  late MockPostRepository mockRepository;
  late GetPostsUseCase useCase;

  setUp(() {
    mockRepository = MockPostRepository();
    useCase = GetPostsUseCase(mockRepository);
  });

  final tPosts = [
    PostEntity(
      id: '1',
      authorName: 'Author 1',
      title: 'Title',
      body: 'Body',
      publishedAt: DateTime(2024, 1, 1),
    ),
  ];

  test('returns posts from the repository', () async {
    when(
      () => mockRepository.getPosts(forceRefresh: false),
    ).thenAnswer((_) async => Right(tPosts));

    final result = await useCase.call();

    result.fold(
      (_) => fail('Should have returned posts'),
      (posts) => expect(posts, tPosts),
    );
    verify(() => mockRepository.getPosts(forceRefresh: false)).called(1);
  });

  test('forwards forceRefresh to the repository', () async {
    when(
      () => mockRepository.getPosts(forceRefresh: true),
    ).thenAnswer((_) async => Right(tPosts));

    await useCase.call(forceRefresh: true);

    verify(() => mockRepository.getPosts(forceRefresh: true)).called(1);
  });

  test('returns a Failure when the repository fails', () async {
    const tFailure = NetworkFailure(message: 'No internet connection');
    when(
      () => mockRepository.getPosts(forceRefresh: false),
    ).thenAnswer((_) async => const Left(tFailure));

    final result = await useCase.call();

    expect(result, const Left(tFailure));
  });
}
