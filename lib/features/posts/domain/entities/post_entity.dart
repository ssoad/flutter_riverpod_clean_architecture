import 'package:equatable/equatable.dart';

/// Domain entity representing a single post in the feed.
class PostEntity extends Equatable {
  final String id;
  final String authorName;
  final String title;
  final String body;
  final DateTime publishedAt;

  const PostEntity({
    required this.id,
    required this.authorName,
    required this.title,
    required this.body,
    required this.publishedAt,
  });

  @override
  List<Object?> get props => [id, authorName, title, body, publishedAt];
}
