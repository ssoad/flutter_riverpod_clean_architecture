import 'package:flutter_riverpod_clean_architecture/features/posts/domain/entities/post_entity.dart';

class PostModel extends PostEntity {
  const PostModel({
    required super.id,
    required super.authorName,
    required super.title,
    required super.body,
    required super.publishedAt,
  });

  factory PostModel.fromEntity(PostEntity entity) {
    return PostModel(
      id: entity.id,
      authorName: entity.authorName,
      title: entity.title,
      body: entity.body,
      publishedAt: entity.publishedAt,
    );
  }

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] as String,
      authorName: json['authorName'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      publishedAt: DateTime.parse(json['publishedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorName': authorName,
      'title': title,
      'body': body,
      'publishedAt': publishedAt.toIso8601String(),
    };
  }

  PostEntity toEntity() => this;
}
