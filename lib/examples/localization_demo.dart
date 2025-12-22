import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/localization/language_selector_widget.dart';
import 'package:flutter_riverpod_clean_architecture/core/providers/localization_providers.dart';
import 'package:flutter_riverpod_clean_architecture/l10n/l10n.dart';
import 'package:intl/intl.dart';

class LocalizationDemo extends ConsumerWidget {
  const LocalizationDemo({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(persistentLocaleProvider);
    final now = DateTime.now();
    final orderDate = DateTime.now().subtract(const Duration(days: 3));

    // Create AppLocalizations instance for formatting
    final l10n = AppLocalizations(currentLocale);

    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('language')),
        actions: const [LanguagePopupMenuButton()],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Current language info
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.tr('welcomeMessage'),
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Current Language: ${_getLocaleName(currentLocale)}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        'Locale: ${currentLocale.languageCode}',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () async {
                          await ref
                              .read(persistentLocaleProvider.notifier)
                              .resetToSystemLocale();
                        },
                        icon: const Icon(Icons.sync),
                        label: const Text('Reset to System Locale'),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Basic translations
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Basic Translations',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      _buildTranslationItem(context, 'appTitle'),
                      _buildTranslationItem(context, 'home'),
                      _buildTranslationItem(context, 'settings'),
                      _buildTranslationItem(context, 'profile'),
                      _buildTranslationItem(context, 'darkMode'),
                      _buildTranslationItem(context, 'lightMode'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Parameter substitution
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Parameters & Pluralization',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        context.trParams('greeting', {'name': 'John Doe'}),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context.tr('itemCount').replaceAll('{count}', '0'),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Text(
                        context.tr('itemCount').replaceAll('{count}', '1'),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      Text(
                        context.tr('itemCount').replaceAll('{count}', '5'),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        context
                            .tr('lastUpdated')
                            .replaceAll('{date}', l10n.formatDate(now)),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Formatting
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Date & Currency Formatting',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      _buildFormattingExample(
                        context,
                        'Date:',
                        l10n.formatDate(now),
                      ),
                      _buildFormattingExample(
                        context,
                        'Short Date:',
                        DateFormat.yMd(currentLocale.toString()).format(now),
                      ),
                      _buildFormattingExample(
                        context,
                        'Time:',
                        l10n.formatTime(now),
                      ),
                      _buildFormattingExample(
                        context,
                        'DateTime:',
                        '${l10n.formatDate(now)} ${l10n.formatTime(now)}',
                      ),
                      _buildFormattingExample(
                        context,
                        'Full DateTime:',
                        DateFormat(
                          'EEEE, MMMM d, yyyy HH:mm',
                          currentLocale.toString(),
                        ).format(now),
                      ),
                      _buildFormattingExample(
                        context,
                        'Currency:',
                        l10n.formatCurrency(1234.56),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Mock order details example
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Order Details Example',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Order #12345',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Order Date:'),
                          Text(l10n.formatDate(orderDate)),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Product 1'),
                          Text(l10n.formatCurrency(59.99)),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Product 2'),
                          Text(l10n.formatCurrency(149.99)),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Subtotal:'),
                          Text(l10n.formatCurrency(209.98)),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Tax:'),
                          Text(l10n.formatCurrency(16.80)),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total:',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            l10n.formatCurrency(226.78),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Language selector
              const Card(child: LanguageSelectorWidget()),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTranslationItem(BuildContext context, String key) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              key,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(context.tr(key))),
        ],
      ),
    );
  }

  Widget _buildFormattingExample(
    BuildContext context,
    String label,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  /// Get the name of a language from its code
  String _getLocaleName(Locale locale) {
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
