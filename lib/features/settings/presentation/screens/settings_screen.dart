import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod_clean_architecture/core/constants/app_constants.dart';
import 'package:flutter_riverpod_clean_architecture/l10n/l10n.dart';

/// Settings screen with various app configuration options
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('settings'))),
      body: ListView(
        children: [
          // Language settings
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(context.tr('language')),
            subtitle: Text(context.tr('change_language')),
            onTap: () => context.go(AppConstants.languageSettingsRoute),
          ),

          const Divider(),

          // Theme settings
          ListTile(
            leading: const Icon(Icons.brightness_6),
            title: Text(context.tr('theme')),
            subtitle: Text(context.tr('change_theme')),
            onTap: () {
              // Theme settings (to be implemented)
            },
          ),

          const Divider(),

          // Other settings...
          ListTile(
            leading: const Icon(Icons.notifications),
            title: Text(context.tr('notifications')),
            subtitle: Text(context.tr('notification_settings')),
            onTap: () {
              // Notification settings (to be implemented)
            },
          ),

          const Divider(),

          // Localization demos
          ListTile(
            leading: const Icon(Icons.language),
            title: Text(context.tr('localization_demo')),
            subtitle: Text(context.tr('localization_demo_description')),
            onTap: () => context.go(AppConstants.localizationAssetsDemoRoute),
          ),
        ],
      ),
    );
  }
}
