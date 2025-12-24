import 'package:fpdart/fpdart.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/exceptions.dart';
import 'package:flutter_riverpod_clean_architecture/core/error/failures.dart';
import 'package:flutter_riverpod_clean_architecture/features/survey/data/datasources/survey_remote_data_source.dart';
import 'package:flutter_riverpod_clean_architecture/features/survey/data/models/survey_model.dart';
import 'package:flutter_riverpod_clean_architecture/features/survey/domain/entities/survey_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/survey/domain/repositories/survey_repository.dart';

class SurveyRepositoryImpl implements SurveyRepository {
  final SurveyRemoteDataSource _remoteDataSource;

  SurveyRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<Failure, void>> submitSurvey(SurveyEntity survey) async {
    try {
      final model = SurveyModel(
        username: survey.username,
        role: survey.role,
        isFreelancer: survey.isFreelancer,
        hourlyRate: survey.hourlyRate,
        feedback: survey.feedback,
        submissionDate: survey.submissionDate,
      );
      await _remoteDataSource.submitSurvey(model);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isUsernameAvailable(String username) async {
    try {
      final isAvailable = await _remoteDataSource.isUsernameAvailable(username);
      return Right(isAvailable);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
