import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/posts/data/datasources/post_cache_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/posts/data/datasources/post_remote_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/posts/data/repositories/post_repository_impl.dart';
import 'package:flutter_riverpod_clean_architecture/features/posts/domain/repositories/post_repository.dart';
import 'package:flutter_riverpod_clean_architecture/features/posts/domain/usecases/get_posts_use_case.dart';

/// Data layer dependency injection providers
/// These providers are responsible for creating and managing data layer instances

// --- Repository ---
final postRepositoryProvider = Provider<PostRepository>((ref) {
  return PostRepositoryImpl(
    ref.watch(postRemoteDataSourceProvider),
    ref.watch(postCacheDataSourceProvider),
  );
});

// --- Use Cases ---
final getPostsUseCaseProvider = Provider<GetPostsUseCase>((ref) {
  return GetPostsUseCase(ref.watch(postRepositoryProvider));
});
