import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/features/survey/domain/entities/survey_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/survey/providers/survey_providers.dart';

/// Presentation layer state management
/// This file contains only UI-related state providers

// --- State Management ---
enum SurveyStatus { initial, invalid, submitting, success, failure }

class SurveyState {
  final SurveyStatus status;
  final String? errorMessage;

  const SurveyState({this.status = SurveyStatus.initial, this.errorMessage});

  SurveyState copyWith({SurveyStatus? status, String? errorMessage}) {
    return SurveyState(
      status: status ?? this.status,
      errorMessage: errorMessage,
    );
  }
}

class SurveyNotifier extends Notifier<SurveyState> {
  @override
  SurveyState build() {
    return const SurveyState();
  }

  Future<void> submit(Map<String, dynamic> formData) async {
    state = state.copyWith(status: SurveyStatus.submitting, errorMessage: null);

    // Map form data to Entity
    try {
      final survey = SurveyEntity(
        username: formData['username'] as String,
        role: formData['role'] as String,
        isFreelancer: formData['isFreelancer'] as bool,
        hourlyRate: formData['hourlyRate'] as double?,
        feedback:
            (formData['feedback'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        submissionDate: DateTime.now(),
      );

      final submitSurvey = ref.read(submitSurveyUseCaseProvider);
      final result = await submitSurvey(survey);

      result.fold(
        (failure) => state = state.copyWith(
          status: SurveyStatus.failure,
          errorMessage: failure.message,
        ),
        (_) => state = state.copyWith(status: SurveyStatus.success),
      );
    } catch (e) {
      state = state.copyWith(
        status: SurveyStatus.failure,
        errorMessage: 'Invalid form data: $e',
      );
    }
  }

  void reset() {
    state = const SurveyState();
  }
}

final surveyProvider = NotifierProvider<SurveyNotifier, SurveyState>(
  SurveyNotifier.new,
);
