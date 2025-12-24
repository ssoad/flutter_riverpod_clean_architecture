import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/constants/app_constants.dart';
import 'package:flutter_riverpod_clean_architecture/core/providers/localization_providers.dart';
import 'package:flutter_riverpod_clean_architecture/core/router/locale_aware_router.dart';
import 'package:flutter_riverpod_clean_architecture/examples/localization_assets_demo.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/presentation/screens/login_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/presentation/screens/register_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/home/presentation/screens/home_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/auth/presentation/providers/auth_provider.dart';
import 'package:flutter_riverpod_clean_architecture/features/settings/presentation/screens/settings_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/settings/presentation/screens/language_settings_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod_clean_architecture/features/chat/presentation/screens/chat_screen.dart';
import 'package:flutter_riverpod_clean_architecture/features/survey/presentation/screens/survey_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  // Watch for locale changes - this rebuilds the router when locale changes
  ref.watch(persistentLocaleProvider);

  // Create a router with locale awareness
  return GoRouter(
    initialLocation: AppConstants.initialRoute,
    debugLogDiagnostics: true,
    // Add the observer for locale awareness
    observers: [ref.read(localizationRouterObserverProvider)],
    redirect: (context, state) {
      // Get the authentication status
      final isLoggedIn = authState.isAuthenticated;

      // Check if the user is going to the login page
      final isGoingToLogin = state.matchedLocation == AppConstants.loginRoute;

      // Check if the user is going to the register page
      final isGoingToRegister =
          state.matchedLocation == AppConstants.registerRoute;

      // If not logged in and not going to login or register, redirect to login
      if (!isLoggedIn && !isGoingToLogin && !isGoingToRegister) {
        return AppConstants.loginRoute;
      }

      // If logged in and going to login, redirect to home
      if (isLoggedIn && (isGoingToLogin || isGoingToRegister)) {
        return AppConstants.homeRoute;
      }

      // No redirect needed
      return null;
    },
    routes: [
      // Home route
      GoRoute(
        path: AppConstants.homeRoute,
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),

      // Login route
      GoRoute(
        path: AppConstants.loginRoute,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),

      // Register route
      GoRoute(
        path: AppConstants.registerRoute,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // Settings route
      GoRoute(
        path: AppConstants.settingsRoute,
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
      ),

      // Language settings route
      GoRoute(
        path: AppConstants.languageSettingsRoute,
        name: 'language_settings',
        builder: (context, state) => const LanguageSettingsScreen(),
      ),

      // Localization Assets Demo route
      GoRoute(
        path: AppConstants.localizationAssetsDemoRoute,
        name: 'localization_assets_demo',
        builder: (context, state) => const LocalizationAssetsDemo(),
      ),

      // Chat route
      GoRoute(
        path: AppConstants.chatRoute,
        name: 'chat',
        builder: (context, state) => const ChatScreen(),
      ),

      // Survey route
      GoRoute(
        path: AppConstants.surveyRoute,
        name: 'survey',
        builder: (context, state) => const SurveyScreen(),
      ),

      // Initial route - redirects based on auth state
      GoRoute(
        path: AppConstants.initialRoute,
        name: 'initial',
        redirect: (context, state) => authState.isAuthenticated
            ? AppConstants.homeRoute
            : AppConstants.loginRoute,
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '404',
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Page ${state.uri.path} not found'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(AppConstants.homeRoute),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});
