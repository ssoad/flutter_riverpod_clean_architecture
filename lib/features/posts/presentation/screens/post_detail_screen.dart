import 'package:flutter/material.dart';
import 'package:flutter_riverpod_clean_architecture/features/posts/domain/entities/post_entity.dart';
import 'package:intl/intl.dart';

class PostDetailScreen extends StatelessWidget {
  final PostEntity post;

  const PostDetailScreen({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Post')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(post.title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              '${post.authorName} • ${DateFormat.yMMMd().add_jm().format(post.publishedAt)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 20),
            Text(post.body, style: Theme.of(context).textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}
