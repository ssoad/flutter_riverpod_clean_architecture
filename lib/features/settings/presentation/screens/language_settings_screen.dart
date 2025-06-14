import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/localization/language_selector_widget.dart';
import 'package:flutter_riverpod_clean_architecture/l10n/l10n.dart';

/// Screen for language selection settings
class LanguageSettingsScreen extends ConsumerWidget {
  const LanguageSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('language_settings'))),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Language selection description
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                context.tr('select_your_language'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),

            // Language selector widget
            const Expanded(child: Card(child: LanguageSelectorWidget())),

            // Language selection explanation
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(
                context.tr('language_explanation'),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
