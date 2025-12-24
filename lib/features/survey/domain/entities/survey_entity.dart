import 'package:equatable/equatable.dart';

class SurveyEntity extends Equatable {
  final String username;
  final String role;
  final bool isFreelancer;
  final double? hourlyRate;
  final List<String> feedback;
  final DateTime submissionDate;

  const SurveyEntity({
    required this.username,
    required this.role,
    required this.isFreelancer,
    this.hourlyRate,
    required this.feedback,
    required this.submissionDate,
  });

  @override
  List<Object?> get props => [
    username,
    role,
    isFreelancer,
    hourlyRate,
    feedback,
    submissionDate,
  ];
}
