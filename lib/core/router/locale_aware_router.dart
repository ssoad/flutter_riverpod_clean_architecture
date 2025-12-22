import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A router observer that handles locale changes
class LocalizationRouterObserver extends NavigatorObserver {
  LocalizationRouterObserver(this.ref);
  final WidgetRef ref;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _refreshRouteWithCurrentLocale(route);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    if (newRoute != null) {
      _refreshRouteWithCurrentLocale(newRoute);
    }
  }

  /// Helper method to refresh the route with the current locale
  void _refreshRouteWithCurrentLocale(Route<dynamic> route) {
    // This method can be used to update route-specific locale data
    // such as route parameters or query parameters based on locale
  }

  /// Method to be called when a locale changes
  void onLocaleChanged(Locale locale) {
    // If needed, refresh the current route with the new locale
    // For more complex cases, you might need to refresh certain routes
  }
}

/// Provider for the LocalizationRouterObserver
final localizationRouterObserverProvider = Provider<NavigatorObserver>((ref) {
  return _LocalizationRouterObserverWithRef(ref);
});

/// Internal implementation that provides ref to LocalizationRouterObserver
class _LocalizationRouterObserverWithRef extends NavigatorObserver {
  _LocalizationRouterObserverWithRef(this.ref);
  final Ref ref;


}

/// Extension for locale-aware navigation
extension LocaleAwareNavigation on BuildContext {
  /// Navigate to a route, preserving the current locale
  void goWithLocale(String location) {
    GoRouter.of(this).go(location);
  }

  /// Navigate to a named route, preserving the current locale
  void goNamedWithLocale(
    String name, {
    Map<String, String> pathParameters = const {},
  }) {
    GoRouter.of(this).goNamed(name, pathParameters: pathParameters);
  }
}
