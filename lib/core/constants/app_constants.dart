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
  
  // Timeout durations
  static const int connectTimeout = 30000;
  static const int receiveTimeout = 30000;
  
  // Route constants
  static const String initialRoute = '/';
  static const String homeRoute = '/home';
  static const String loginRoute = '/login';
  static const String registerRoute = '/register';
  static const String profileRoute = '/profile';
  
  // Hive box names
  static const String settingsBox = 'settings';
  static const String cacheBox = 'cache';
  
  // Animation durations
  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
}
