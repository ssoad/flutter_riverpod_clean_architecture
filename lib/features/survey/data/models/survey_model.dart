import 'package:flutter_riverpod_clean_architecture/features/survey/domain/entities/survey_entity.dart';

class SurveyModel extends SurveyEntity {
  const SurveyModel({
    required super.username,
    required super.role,
    required super.isFreelancer,
    super.hourlyRate,
    required super.feedback,
    required super.submissionDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'role': role,
      'isFreelancer': isFreelancer,
      'hourlyRate': hourlyRate,
      'feedback': feedback,
      'submissionDate': submissionDate.toIso8601String(),
    };
  }
}
