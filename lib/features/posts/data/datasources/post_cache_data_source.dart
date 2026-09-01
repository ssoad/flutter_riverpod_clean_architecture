import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/constants/app_constants.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/exceptions.dart';
import 'package:flutter_riverpod_clean_architecture/core/providers/storage_providers.dart';
import 'package:flutter_riverpod_clean_architecture/core/storage/local_storage_service.dart';
import 'package:flutter_riverpod_clean_architecture/features/posts/data/models/post_model.dart';

/// Caches the most recently fetched posts on-device so the feed can still be
/// shown while offline.
abstract class PostCacheDataSource {
  Future<List<PostModel>> getCachedPosts();
  Future<void> cachePosts(List<PostModel> posts);
}

class PostCacheDataSourceImpl implements PostCacheDataSource {
  final LocalStorageService _localStorageService;

  PostCacheDataSourceImpl(this._localStorageService);

  @override
  Future<List<PostModel>> getCachedPosts() async {
    try {
      final data = _localStorageService.getObject(AppConstants.postsCacheKey);
      if (data == null) return [];
      return (data as List)
          .map((e) => PostModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } on CacheException {
      rethrow;
    } catch (e) {
      throw CacheException(message: 'Failed to parse cached posts: $e');
    }
  }

  @override
  Future<void> cachePosts(List<PostModel> posts) async {
    await _localStorageService.setObject(
      AppConstants.postsCacheKey,
      posts.map((p) => p.toJson()).toList(),
    );
  }
}

final postCacheDataSourceProvider = Provider<PostCacheDataSource>((ref) {
  return PostCacheDataSourceImpl(ref.watch(localStorageServiceProvider));
});
