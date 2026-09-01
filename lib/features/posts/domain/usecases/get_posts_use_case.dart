import 'package:fpdart/fpdart.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/features/posts/domain/entities/post_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/posts/domain/repositories/post_repository.dart';

class GetPostsUseCase {
  final PostRepository _repository;

  GetPostsUseCase(this._repository);

  Future<Either<Failure, List<PostEntity>>> call({bool forceRefresh = false}) {
    return _repository.getPosts(forceRefresh: forceRefresh);
  }
}
