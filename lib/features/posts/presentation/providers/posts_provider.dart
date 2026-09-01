import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/posts/domain/entities/post_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/posts/providers/post_providers.dart';

/// Presentation layer state management
/// This file contains only UI-related state providers

enum PostsStatus { initial, loading, loaded, error }

class PostsState {
  final PostsStatus status;
  final List<PostEntity> posts;
  final String? errorMessage;

  const PostsState({
    this.status = PostsStatus.initial,
    this.posts = const [],
    this.errorMessage,
  });

  PostsState copyWith({
    PostsStatus? status,
    List<PostEntity>? posts,
    String? errorMessage,
  }) {
    return PostsState(
      status: status ?? this.status,
      posts: posts ?? this.posts,
      errorMessage: errorMessage,
    );
  }
}

class PostsNotifier extends Notifier<PostsState> {
  @override
  PostsState build() {
    return const PostsState();
  }

  Future<void> loadPosts({bool forceRefresh = false}) async {
    state = state.copyWith(status: PostsStatus.loading, errorMessage: null);

    final result = await ref
        .read(getPostsUseCaseProvider)
        .call(forceRefresh: forceRefresh);

    result.fold(
      (failure) => state = state.copyWith(
        status: PostsStatus.error,
        errorMessage: failure.message,
      ),
      (posts) =>
          state = state.copyWith(status: PostsStatus.loaded, posts: posts),
    );
  }
}

final postsProvider = NotifierProvider<PostsNotifier, PostsState>(
  PostsNotifier.new,
);
