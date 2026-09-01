import 'package:fpdart/fpdart.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/exceptions.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/features/posts/data/datasources/post_cache_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/posts/data/datasources/post_remote_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/posts/domain/entities/post_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/posts/domain/repositories/post_repository.dart';

class PostRepositoryImpl implements PostRepository {
  final PostRemoteDataSource _remoteDataSource;
  final PostCacheDataSource _cacheDataSource;

  PostRepositoryImpl(this._remoteDataSource, this._cacheDataSource);

  @override
  Future<Either<Failure, List<PostEntity>>> getPosts({
    bool forceRefresh = false,
  }) async {
    try {
      final posts = await _remoteDataSource.getPosts();
      await _cacheDataSource.cachePosts(posts);
      return Right(posts);
    } on NetworkException catch (e) {
      return _fallbackToCache(e.message);
    } on ServerException catch (e) {
      return _fallbackToCache(e.message);
    } catch (e) {
      return _fallbackToCache(e.toString());
    }
  }

  /// When the remote fetch fails, serve the last cached page instead of
  /// surfacing an empty feed - falling back to the failure only if there is
  /// nothing cached either.
  Future<Either<Failure, List<PostEntity>>> _fallbackToCache(
    String reason,
  ) async {
    try {
      final cached = await _cacheDataSource.getCachedPosts();
      if (cached.isNotEmpty) {
        return Right(cached);
      }
      return Left(NetworkFailure(message: reason));
    } catch (_) {
      return Left(NetworkFailure(message: reason));
    }
  }
}
