import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/providers/storage_providers.dart';
import 'package:flutter_riverpod_clean_architecture/l10n/l10n.dart';

/// Key for storing selected language code in SharedPreferences
const _languageCodeKey = 'selected_language_code';

/// Provider for persisting and retrieving the user's locale preference
final savedLocaleProvider = Provider<Locale>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final savedLanguageCode = prefs.getString(_languageCodeKey);

  if (savedLanguageCode != null &&
      AppLocalizations.supportedLocales.any(
        (l) => l.languageCode == savedLanguageCode,
      )) {
    return Locale(savedLanguageCode);
  }

  // Default to system locale or English if system locale is not supported
  final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;
  if (AppLocalizations.isSupported(systemLocale)) {
    return systemLocale;
  }

  return const Locale('en');
});

/// Provider for initializing and persisting the locale notifier
/// Provider for initializing and persisting the locale notifier
final persistentLocaleProvider =
    NotifierProvider<PersistentLocaleNotifier, Locale>(
      PersistentLocaleNotifier.new,
    );

/// Notifier for managing the locale state with persistence
class PersistentLocaleNotifier extends Notifier<Locale> {
  static const _languageCodeKey = 'selected_language_code';

  @override
  Locale build() {
    return ref.watch(savedLocaleProvider);
  }

  /// Set a new locale and persist the choice
  Future<void> setLocale(Locale locale) async {
    if (AppLocalizations.isSupported(locale)) {
      final prefs = ref.read(sharedPreferencesProvider);
      await prefs.setString(_languageCodeKey, locale.languageCode);
      state = locale;
    }
  }

  /// Reset to the system locale
  Future<void> resetToSystemLocale() async {
    final prefs = ref.read(sharedPreferencesProvider);
    await prefs.remove(_languageCodeKey);
    final systemLocale = WidgetsBinding.instance.platformDispatcher.locale;

    if (AppLocalizations.isSupported(systemLocale)) {
      state = systemLocale;
    } else {
      state = const Locale('en');
    }
  }
}
