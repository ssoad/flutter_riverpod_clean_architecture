import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/exceptions.dart';
import 'package:flutter_riverpod_clean_architecture/core/utils/app_utils.dart';
import 'package:flutter_riverpod_clean_architecture/features/posts/data/models/post_model.dart';

abstract class PostRemoteDataSource {
  Future<List<PostModel>> getPosts();
}

class PostRemoteDataSourceImpl implements PostRemoteDataSource {
  // final ApiClient _apiClient;

  PostRemoteDataSourceImpl(/*this._apiClient*/);

  @override
  Future<List<PostModel>> getPosts() async {
    final hasNetwork = await AppUtils.hasNetworkConnection();
    if (!hasNetwork) {
      throw NetworkException();
    }

    // In a real app, you would make an API call here, e.g.:
    // final response = await _apiClient.get('/posts');
    // return (response as List)
    //     .map((json) => PostModel.fromJson(json as Map<String, dynamic>))
    //     .toList();

    // Simulating a backend call with delay, as the rest of this template
    // does for auth/survey, so the feature works out of the box with no
    // backend configured.
    await Future.delayed(const Duration(milliseconds: 600));

    return List.generate(12, (index) {
      final id = index + 1;
      return PostModel(
        id: '$id',
        authorName: 'Author ${(id % 4) + 1}',
        title: 'Post #$id: Building with Clean Architecture',
        body:
            'This is a sample post body demonstrating the posts feed feature, '
            'backed by a repository that caches results locally for offline '
            'viewing. Post index: $id.',
        publishedAt: DateTime.now().subtract(Duration(hours: id * 3)),
      );
    });
  }
}

final postRemoteDataSourceProvider = Provider<PostRemoteDataSource>((ref) {
  return PostRemoteDataSourceImpl();
});
