class AppConstants {
  // API constants
  static const String apiBaseUrl = 'https://api.yourdomain.com';

  // Storage constants
  static const String tokenKey = 'authToken';
  static const String userDataKey = 'userData';
  static const String refreshTokenKey = 'refreshToken';

  // App constants
  static const String appName = 'Flutter Riverpod Clean Architecture';
  static const String appVersion = '1.0.0';
  static const String packageName =
      'com.example.flutter_riverpod_clean_architecture';
  static const String iOSAppId = '123456789';
  static const String appcastUrl = 'https://your-appcast-url.com/appcast.xml';

  // Timeout durations
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;

  // Route constants
  static const String initialRoute = '/';
  static const String homeRoute = '/home';
  static const String chatRoute = '/chat';
  static const String surveyRoute = '/survey';
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String profileRoute = '/profile';
  static const String settingsRoute = '/settings';
  static const String languageSettingsRoute = '/settings/language';
  static const String localizationDemoRoute = '/demo/localization';
  static const String localizationAssetsDemoRoute = '/demo/localization/assets';
  static const String tasksRoute = '/tasks';
  static const String notificationsRoute = '/notifications';
  static const String postsRoute = '/posts';
  static const String postDetailRoute = '/posts/detail';

  // Examples hub & integration pattern demo routes
  static const String examplesHubRoute = '/examples';
  static const String advancedFeaturesRoute = '/examples/advanced';
  static const String localizationDemoScreenRoute = '/examples/localization';
  static const String languageSelectorDemoRoute =
      '/examples/localization/selector';
  static const String biometricDemoRoute = '/examples/biometric';
  static const String webSocketDemoRoute = '/examples/websocket';
  static const String webhookDemoRoute = '/examples/webhook';
  static const String graphqlDemoRoute = '/examples/graphql';
  static const String grpcDemoRoute = '/examples/grpc';
  static const String backgroundTasksDemoRoute = '/examples/background-tasks';
  static const String fileTransferDemoRoute = '/examples/file-transfer';

  // Hive box names
  static const String settingsBox = 'settings';
  static const String cacheBox = 'cache';
  static const String offlineSyncBox = 'offlineSync';

  // Local storage keys
  static const String tasksStorageKey = 'tasks_data';
  static const String notificationsStorageKey = 'notifications_data';
  static const String postsCacheKey = 'posts_cache_data';

  // Animation durations
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);

  // Accessibility
  static const Duration accessibilityTooltipDuration = Duration(seconds: 5);
  static const double accessibilityTouchTargetMinSize = 48.0;

  // App Review
  static const int minSessionsBeforeReview = 5;
  static const int minDaysBeforeReview = 7;
  static const int minActionsBeforeReview = 10;
}
