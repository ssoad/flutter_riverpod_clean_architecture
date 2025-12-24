import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Interface for the app review service
abstract class AppReviewService {
  /// Check if the app should request a review
  Future<bool> shouldRequestReview();

  /// Request a review immediately
  Future<void> requestReview();

  /// Record an app session
  Future<void> recordAppSession();

  /// Record a significant action that might trigger a review
  Future<void> recordSignificantAction();

  /// Show a custom feedback form before app review
  Future<bool> showFeedbackForm({
    required BuildContext context,
    required String title,
    required String message,
  });

  /// Initialize the service
  Future<void> init();
}

/// Implementation of the app review service using the in_app_review package
class AppReviewServiceImpl implements AppReviewService {
  final InAppReview _inAppReview;
  final SharedPreferences _preferences;

  // Keys for SharedPreferences
  static const String _keyFirstLaunchTime = 'app_review_first_launch_time';
  static const String _keySessionCount = 'app_review_session_count';
  static const String _keyActionCount = 'app_review_action_count';
  static const String _keyLastReviewRequestTime =
      'app_review_last_request_time';
  static const String _keyHasGivenReview = 'app_review_has_given';

  // Thresholds for requesting reviews
  final int _minSessionsBeforeReview;
  final int _minDaysBeforeReview;
  final int _minActionsBeforeReview;
  final int _daysBetweenReviewRequests;

  /// Create an app review service
  AppReviewServiceImpl({
    required InAppReview inAppReview,
    required SharedPreferences preferences,
    int minSessionsBeforeReview = 5,
    int minDaysBeforeReview = 7,
    int minActionsBeforeReview = 10,
    int daysBetweenReviewRequests = 60,
  }) : _inAppReview = inAppReview,
       _preferences = preferences,
       _minSessionsBeforeReview = minSessionsBeforeReview,
       _minDaysBeforeReview = minDaysBeforeReview,
       _minActionsBeforeReview = minActionsBeforeReview,
       _daysBetweenReviewRequests = daysBetweenReviewRequests;

  @override
  Future<void> init() async {
    // Record the first launch time if not already recorded
    if (!_preferences.containsKey(_keyFirstLaunchTime)) {
      await _preferences.setInt(
        _keyFirstLaunchTime,
        DateTime.now().millisecondsSinceEpoch,
      );
    }

    // Record this app session
    await recordAppSession();

    debugPrint('⭐️ App review service initialized');
  }

  @override
  Future<bool> shouldRequestReview() async {
    // Don't request if the user has already given a review
    if (_preferences.getBool(_keyHasGivenReview) ?? false) {
      return false;
    }

    // Get counts and times
    final sessionCount = _preferences.getInt(_keySessionCount) ?? 0;
    final actionCount = _preferences.getInt(_keyActionCount) ?? 0;
    final firstLaunchTime =
        _preferences.getInt(_keyFirstLaunchTime) ??
        DateTime.now().millisecondsSinceEpoch;
    final lastReviewRequestTime =
        _preferences.getInt(_keyLastReviewRequestTime) ?? 0;

    // Calculate days since first launch
    final daysSinceFirstLaunch = DateTime.now()
        .difference(DateTime.fromMillisecondsSinceEpoch(firstLaunchTime))
        .inDays;

    // Calculate days since last review request
    final daysSinceLastReviewRequest = DateTime.now()
        .difference(DateTime.fromMillisecondsSinceEpoch(lastReviewRequestTime))
        .inDays;

    // Check if we've waited long enough since the last request
    if (lastReviewRequestTime > 0 &&
        daysSinceLastReviewRequest < _daysBetweenReviewRequests) {
      return false;
    }

    // Check thresholds
    return sessionCount >= _minSessionsBeforeReview &&
        daysSinceFirstLaunch >= _minDaysBeforeReview &&
        actionCount >= _minActionsBeforeReview;
  }

  @override
  Future<void> requestReview() async {
    try {
      // Check if the functionality is available
      if (await _inAppReview.isAvailable()) {
        await _inAppReview.requestReview();

        // Record the request time
        await _preferences.setInt(
          _keyLastReviewRequestTime,
          DateTime.now().millisecondsSinceEpoch,
        );
      } else {
        // Fall back to opening the store page
        await _inAppReview.openStoreListing();

        // Mark as having given review
        await _preferences.setBool(_keyHasGivenReview, true);
      }
    } catch (e) {
      debugPrint('⭐️ Error requesting review: $e');
    }
  }

  @override
  Future<void> recordAppSession() async {
    final currentCount = _preferences.getInt(_keySessionCount) ?? 0;
    await _preferences.setInt(_keySessionCount, currentCount + 1);
  }

  @override
  Future<void> recordSignificantAction() async {
    final currentCount = _preferences.getInt(_keyActionCount) ?? 0;
    await _preferences.setInt(_keyActionCount, currentCount + 1);

    // Check if we should request a review after this action
    if (await shouldRequestReview()) {
      await requestReview();
    }
  }

  @override
  Future<bool> showFeedbackForm({
    required BuildContext context,
    required String title,
    required String message,
  }) async {
    final controller = TextEditingController();
    bool result = false;

    // Show a dialog to collect feedback
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Enter your feedback here',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              result = true;
              // In a real app, send this feedback to your server
              debugPrint('⭐️ User feedback: ${controller.text}');
              Navigator.of(context).pop();
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );

    return result;
  }
}
