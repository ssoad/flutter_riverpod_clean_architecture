import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/constants/app_constants.dart';
import 'package:flutter_riverpod_clean_architecture/core/utils/app_utils.dart';
import 'package:flutter_riverpod_clean_architecture/features/posts/presentation/providers/posts_provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class PostsScreen extends ConsumerStatefulWidget {
  const PostsScreen({super.key});

  @override
  ConsumerState<PostsScreen> createState() => _PostsScreenState();
}

class _PostsScreenState extends ConsumerState<PostsScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(postsProvider.notifier).loadPosts());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(postsProvider);
    final notifier = ref.read(postsProvider.notifier);

    ref.listen(postsProvider, (previous, next) {
      if (next.errorMessage != null &&
          next.errorMessage != previous?.errorMessage) {
        AppUtils.showSnackBar(
          context,
          message: next.posts.isEmpty
              ? next.errorMessage!
              : '${next.errorMessage!} — showing cached posts',
          backgroundColor: Theme.of(context).colorScheme.error,
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Posts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => notifier.loadPosts(forceRefresh: true),
          ),
        ],
      ),
      body: _buildBody(context, state, notifier),
    );
  }

  Widget _buildBody(
    BuildContext context,
    PostsState state,
    PostsNotifier notifier,
  ) {
    if (state.status == PostsStatus.loading && state.posts.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(state.errorMessage ?? 'No posts available'),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => notifier.loadPosts(forceRefresh: true),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => notifier.loadPosts(forceRefresh: true),
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: state.posts.length,
        itemBuilder: (context, index) {
          final post = state.posts[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: ListTile(
              contentPadding: const EdgeInsets.all(12),
              title: Text(
                post.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  '${post.authorName} • ${DateFormat.yMMMd().add_jm().format(post.publishedAt)}',
                ),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () =>
                  context.push(AppConstants.postDetailRoute, extra: post),
            ),
          );
        },
      ),
    );
  }
}
