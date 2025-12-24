import 'package:flutter_riverpod_clean_architecture/features/survey/data/models/survey_model.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/exceptions.dart';

abstract class SurveyRemoteDataSource {
  Future<void> submitSurvey(SurveyModel survey);
  Future<bool> isUsernameAvailable(String username);
}

class SurveyRemoteDataSourceImpl implements SurveyRemoteDataSource {
  // Simulating a database of taken usernames
  final List<String> _takenUsernames = ['admin', 'root', 'superuser', 'test'];

  @override
  Future<void> submitSurvey(SurveyModel survey) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    // Simulate potential failure
    if (survey.username == 'error_trigger') {
      throw ServerException(message: 'Simulated server error');
    }

    // Success
    return;
  }

  @override
  Future<bool> isUsernameAvailable(String username) async {
    // Simulate network delay for async validation
    await Future.delayed(const Duration(milliseconds: 500));

    return !_takenUsernames.contains(username.toLowerCase());
  }
}
