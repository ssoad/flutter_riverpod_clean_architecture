
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/providers/localization_providers.dart';
import 'package:flutter_riverpod_clean_architecture/l10n/app_localizations_delegate.dart';
import 'package:flutter_riverpod_clean_architecture/l10n/l10n.dart';
import 'package:intl/intl.dart';

/// Service class for handling localization-related functionality
class LocalizationService {
  const LocalizationService(this.ref);

  final Ref ref;

  /// Get the current locale
  Locale get currentLocale => ref.read(persistentLocaleProvider);

  /// Set a new locale
  Future<void> setLocale(Locale locale) async {
    await ref.read(persistentLocaleProvider.notifier).setLocale(locale);
  }

  /// Reset to the system locale
  Future<void> resetToSystemLocale() async {
    await ref.read(persistentLocaleProvider.notifier).resetToSystemLocale();
  }

  /// Get the name of a locale in its native language
  String getLocaleName(Locale locale) {
    return LocalizationUtils.getLocaleName(locale);
  }

  /// Get all supported locales
  List<Locale> get supportedLocales => AppLocalizations.supportedLocales;

  /// Check if a locale is supported
  bool isSupported(Locale locale) => AppLocalizations.isSupported(locale);

  /// Format a date according to the current locale
  String formatDate(DateTime date, {String? pattern}) {
    final locale = currentLocale.toString();
    if (pattern != null) {
      return DateFormat(pattern, locale).format(date);
    }
    return DateFormat.yMMMd(locale).format(date);
  }

  /// Format a time according to the current locale
  String formatTime(DateTime time, {String? pattern}) {
    final locale = currentLocale.toString();
    if (pattern != null) {
      return DateFormat(pattern, locale).format(time);
    }
    return DateFormat.Hm(locale).format(time);
  }

  /// Format a date and time according to the current locale
  String formatDateTime(DateTime dateTime, {String? pattern}) {
    final locale = currentLocale.toString();
    if (pattern != null) {
      return DateFormat(pattern, locale).format(dateTime);
    }
    return DateFormat.yMMMd(locale).add_Hm().format(dateTime);
  }

  /// Format currency according to the current locale
  String formatCurrency(double amount, {String? symbol}) {
    final locale = currentLocale.toString();
    return NumberFormat.currency(
      locale: locale,
      symbol: symbol ?? getCurrencySymbol(),
    ).format(amount);
  }

  /// Get the appropriate currency symbol for the current locale
  String getCurrencySymbol() {
    switch (currentLocale.languageCode) {
      case 'es':
      case 'fr':
      case 'de':
        return '€';
      case 'ja':
        return '¥';
      case 'bn':
        return '৳';
      default:
        return '\$';
    }
  }
}

/// Provider for the localization service
final localizationServiceProvider = Provider<LocalizationService>((ref) {
  return LocalizationService(ref);
});

/// Extension methods for BuildContext to easily access localization functions
extension LocalizationServiceExtension on BuildContext {
  /// Get the localization service
  LocalizationService get localization =>
      ProviderScope.containerOf(this).read(localizationServiceProvider);

  /// Set a new locale
  Future<void> setLocale(Locale locale) => localization.setLocale(locale);

  /// Reset to the system locale
  Future<void> resetToSystemLocale() => localization.resetToSystemLocale();

  /// Get the current locale
  Locale get currentLocale => localization.currentLocale;

  /// Format a date
  String formatDate(DateTime date, {String? pattern}) =>
      localization.formatDate(date, pattern: pattern);

  /// Format a time
  String formatTime(DateTime time, {String? pattern}) =>
      localization.formatTime(time, pattern: pattern);

  /// Format a date and time
  String formatDateTime(DateTime dateTime, {String? pattern}) =>
      localization.formatDateTime(dateTime, pattern: pattern);

  /// Format currency
  String formatCurrency(double amount, {String? symbol}) =>
      localization.formatCurrency(amount, symbol: symbol);
}
