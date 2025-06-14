import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/providers/localization_providers.dart';
import 'package:flutter_riverpod_clean_architecture/l10n/app_localizations_delegate.dart';
import 'package:flutter_riverpod_clean_architecture/l10n/l10n.dart';

/// A widget that allows the user to select a language from the supported locales
class LanguageSelectorWidget extends ConsumerWidget {
  const LanguageSelectorWidget({Key? key, this.onLanguageSelected})
    : super(key: key);

  /// Optional callback when a language is selected
  final void Function(Locale)? onLanguageSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(persistentLocaleProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            context.tr('language'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        const Divider(),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: AppLocalizations.supportedLocales.length,
          itemBuilder: (context, index) {
            final locale = AppLocalizations.supportedLocales[index];
            final isSelected =
                currentLocale.languageCode == locale.languageCode;

            return ListTile(
              title: Text(LocalizationUtils.getLocaleName(locale)),
              subtitle: Text(locale.languageCode.toUpperCase()),
              leading: CircleAvatar(
                child: Text(
                  locale.languageCode.toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              trailing:
                  isSelected
                      ? const Icon(Icons.check, color: Colors.green)
                      : null,
              selected: isSelected,
              onTap: () async {
                await ref
                    .read(persistentLocaleProvider.notifier)
                    .setLocale(locale);
                if (onLanguageSelected != null) {
                  onLanguageSelected!(locale);
                }
              },
            );
          },
        ),
      ],
    );
  }
}

/// A dialog that allows the user to select a language
class LanguageSelectorDialog extends StatelessWidget {
  const LanguageSelectorDialog({Key? key}) : super(key: key);

  /// Show the language selector dialog
  static Future<Locale?> show(BuildContext context) async {
    return showDialog<Locale>(
      context: context,
      builder: (context) => const LanguageSelectorDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LanguageSelectorWidget(
              onLanguageSelected: (locale) {
                Navigator.of(context).pop(locale);
              },
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(context.tr('cancel')),
            ),
          ],
        ),
      ),
    );
  }
}

/// A popup menu button for selecting a language
class LanguagePopupMenuButton extends ConsumerWidget {
  const LanguagePopupMenuButton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(persistentLocaleProvider);

    return PopupMenuButton<Locale>(
      tooltip: context.tr('language'),
      icon: const Icon(Icons.language),
      onSelected: (Locale locale) async {
        await ref.read(persistentLocaleProvider.notifier).setLocale(locale);
      },
      itemBuilder: (context) {
        return AppLocalizations.supportedLocales.map((Locale locale) {
          return PopupMenuItem<Locale>(
            value: locale,
            child: Row(
              children: [
                Text(LocalizationUtils.getLocaleName(locale)),
                const Spacer(),
                if (currentLocale.languageCode == locale.languageCode)
                  const Icon(Icons.check, size: 18, color: Colors.green),
              ],
            ),
          );
        }).toList();
      },
    );
  }
}
