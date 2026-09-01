import 'package:fpdart/fpdart.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/features/posts/domain/entities/post_entity.dart';

abstract class PostRepository {
  /// Fetches posts from the remote source, falling back to the last
  /// successfully cached list when offline or on error.
  ///
  /// Pass [forceRefresh] to bypass any short-lived caching in the data
  /// source and hit the network again.
  Future<Either<Failure, List<PostEntity>>> getPosts({
    bool forceRefresh = false,
  });
}
