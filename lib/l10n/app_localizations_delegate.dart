import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'l10n.dart';

/// Delegate for loading and switching AppLocalizations
class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => AppLocalizations.isSupported(locale);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}

// We need to import this conditionally or from a provider
// that will be initialized at app startup
final defaultLocaleProvider = Provider<Locale>((ref) => const Locale('en'));

/// Provider for accessing translations based on current locale
/// This should be overridden with the persistentLocaleProvider during app initialization
final translationsProvider = Provider<Map<String, String>>((ref) {
  // Get locale from provider that will be overridden at app startup
  final locale = ref.watch(defaultLocaleProvider);
  return localizedValues[locale.languageCode] ?? localizedValues['en'] ?? {};
});

/// Utility functions for localization
class LocalizationUtils {
  /// Get device locale
  static Locale getDeviceLocale(BuildContext context) {
    return Localizations.localeOf(context);
  }

  /// Get best matching supported locale
  static Locale findSupportedLocale(Locale deviceLocale) {
    // First check for exact match
    for (final locale in AppLocalizations.supportedLocales) {
      if (locale.languageCode == deviceLocale.languageCode) {
        return locale;
      }
    }

    // Default to English
    return const Locale('en');
  }

  /// Get the locale name in its own language
  static String getLocaleName(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        return 'English';
      case 'es':
        return 'Español';
      case 'fr':
        return 'Français';
      case 'de':
        return 'Deutsch';
      case 'ja':
        return '日本語';
      case 'bn':
        return 'বাংলা';
      default:
        return locale.languageCode;
    }
  }
}
