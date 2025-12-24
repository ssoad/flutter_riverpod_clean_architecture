import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/survey/data/datasources/survey_remote_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/survey/data/repositories/survey_repository_impl.dart';
import 'package:flutter_riverpod_clean_architecture/features/survey/domain/repositories/survey_repository.dart';
import 'package:flutter_riverpod_clean_architecture/features/survey/domain/usecases/check_username_use_case.dart';
import 'package:flutter_riverpod_clean_architecture/features/survey/domain/usecases/submit_survey_use_case.dart';

/// Data layer dependency injection providers
/// These providers are responsible for creating and managing data layer instances

// --- Data Source ---
final surveyRemoteDataSourceProvider = Provider<SurveyRemoteDataSource>((ref) {
  return SurveyRemoteDataSourceImpl();
});

// --- Repository ---
final surveyRepositoryProvider = Provider<SurveyRepository>((ref) {
  return SurveyRepositoryImpl(ref.watch(surveyRemoteDataSourceProvider));
});

// --- Use Cases ---
final submitSurveyUseCaseProvider = Provider<SubmitSurveyUseCase>((ref) {
  return SubmitSurveyUseCase(ref.watch(surveyRepositoryProvider));
});

final checkUsernameUseCaseProvider = Provider<CheckUsernameUseCase>((ref) {
  return CheckUsernameUseCase(ref.watch(surveyRepositoryProvider));
});
