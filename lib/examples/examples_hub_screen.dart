import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_constants.dart';

/// A single, discoverable directory of every pattern this template
/// demonstrates - integrations (WebSocket, webhook, GraphQL, gRPC, REST),
/// platform capabilities (background tasks, biometrics, file transfer),
/// and the app's other feature/showcase screens.
///
/// The rest of the codebase implements a lot of real, working patterns that
/// have no obvious way to find from the running app; this hub exists so
/// picking this template up for a new project starts with "here is
/// everything available", not a source-code archaeology dig.
class ExamplesHubScreen extends StatelessWidget {
  const ExamplesHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Examples')),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          _Section(
            title: 'Networking & integrations',
            entries: [
              _Entry(
                icon: Icons.cable,
                title: 'REST (Dio)',
                subtitle:
                    'ApiClient + repository pattern - see the Posts feature',
                onTap: (context) => context.push(AppConstants.postsRoute),
              ),
              _Entry(
                icon: Icons.sync_alt,
                title: 'WebSocket',
                subtitle:
                    'Reusable client: connect, send, receive, auto-reconnect',
                onTap: (context) =>
                    context.push(AppConstants.webSocketDemoRoute),
              ),
              _Entry(
                icon: Icons.webhook,
                title: 'Webhook (send + receive)',
                subtitle:
                    'HMAC-signed outbound webhook and a local dev receiver',
                onTap: (context) => context.push(AppConstants.webhookDemoRoute),
              ),
              _Entry(
                icon: Icons.hub,
                title: 'GraphQL',
                subtitle: 'Thin Dio-based client - a query and a mutation',
                onTap: (context) => context.push(AppConstants.graphqlDemoRoute),
              ),
              _Entry(
                icon: Icons.grain,
                title: 'gRPC',
                subtitle:
                    'Unary + server-streaming calls, generated client stubs',
                onTap: (context) => context.push(AppConstants.grpcDemoRoute),
              ),
            ],
          ),
          _Section(
            title: 'Platform & background',
            entries: [
              _Entry(
                icon: Icons.schedule,
                title: 'Background tasks',
                subtitle: 'WorkManager: one-off and periodic scheduled work',
                onTap: (context) =>
                    context.push(AppConstants.backgroundTasksDemoRoute),
              ),
              _Entry(
                icon: Icons.fingerprint,
                title: 'Biometric authentication',
                subtitle:
                    'Fingerprint / Face ID gating app access & transactions',
                onTap: (context) =>
                    context.push(AppConstants.biometricDemoRoute),
              ),
              _Entry(
                icon: Icons.file_present,
                title: 'File upload / download',
                subtitle: 'Multipart upload and download, both with progress',
                onTap: (context) =>
                    context.push(AppConstants.fileTransferDemoRoute),
              ),
            ],
          ),
          _Section(
            title: 'App capabilities',
            entries: [
              _Entry(
                icon: Icons.tune,
                title: 'Advanced features showcase',
                subtitle:
                    'Feature flags, analytics, notifications, images, '
                    'logging, accessibility, updates, offline sync, reviews',
                onTap: (context) =>
                    context.push(AppConstants.advancedFeaturesRoute),
              ),
              _Entry(
                icon: Icons.language,
                title: 'Localization',
                subtitle: 'Locale-aware dates, numbers and currency formatting',
                onTap: (context) =>
                    context.push(AppConstants.localizationDemoScreenRoute),
              ),
              _Entry(
                icon: Icons.translate,
                title: 'Language selector',
                subtitle: 'Switching the active locale at runtime',
                onTap: (context) =>
                    context.push(AppConstants.languageSelectorDemoRoute),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.entries});

  final String title;
  final List<_Entry> entries;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...entries,
        const Divider(height: 1),
      ],
    );
  }
}

class _Entry extends StatelessWidget {
  const _Entry({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final void Function(BuildContext context) onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => onTap(context),
    );
  }
}
