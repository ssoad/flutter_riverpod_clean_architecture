import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/background/background_task_service.dart';

/// Demonstrates scheduling deferrable background work with the
/// `workmanager` plugin: a one-off task and a recurring periodic task, both
/// of which keep running even if the app is fully closed.
///
/// Note: this runs on Android/iOS only (WorkManager / BGTaskScheduler are
/// mobile OS schedulers); there is nothing to demo on desktop/web, where
/// [BackgroundTaskService.initialize] is still safe to call but scheduled
/// tasks are simply never fired by the platform.
class BackgroundTasksExampleScreen extends ConsumerStatefulWidget {
  const BackgroundTasksExampleScreen({super.key});

  static const _oneOffTaskName = 'template-one-off-task';
  static const _periodicTaskName = 'template-periodic-task';

  @override
  ConsumerState<BackgroundTasksExampleScreen> createState() =>
      _BackgroundTasksExampleScreenState();
}

class _BackgroundTasksExampleScreenState
    extends ConsumerState<BackgroundTasksExampleScreen> {
  String? _lastRun;
  bool _initialized = false;
  String? _status;

  Future<void> _refreshLastRun() async {
    final marker = await ref
        .read(backgroundTaskServiceProvider)
        .readLastRunMarker();
    if (mounted) setState(() => _lastRun = marker);
  }

  Future<void> _initialize() async {
    await ref.read(backgroundTaskServiceProvider).initialize();
    setState(() {
      _initialized = true;
      _status = 'Initialized';
    });
  }

  @override
  Widget build(BuildContext context) {
    final service = ref.watch(backgroundTaskServiceProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Background tasks (WorkManager)')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'The OS decides exactly when a task runs (subject to battery, '
            'network and OS-defined minimum intervals), so results may take '
            'a while to appear - check back or tap "Check last run".',
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: _initialize,
            icon: const Icon(Icons.power_settings_new),
            label: Text(_initialized ? 'Re-initialize' : 'Initialize'),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              FilledButton.tonal(
                onPressed: () async {
                  await service.registerOneOffTask(
                    uniqueName: BackgroundTasksExampleScreen._oneOffTaskName,
                    taskName: BackgroundTasksExampleScreen._oneOffTaskName,
                    initialDelay: const Duration(seconds: 5),
                  );
                  setState(() => _status = 'One-off task scheduled (~5s)');
                },
                child: const Text('Schedule one-off task'),
              ),
              FilledButton.tonal(
                onPressed: () async {
                  await service.registerPeriodicTask(
                    uniqueName: BackgroundTasksExampleScreen._periodicTaskName,
                    taskName: BackgroundTasksExampleScreen._periodicTaskName,
                  );
                  setState(
                    () => _status =
                        'Periodic task scheduled (every 15 min, OS-clamped)',
                  );
                },
                child: const Text('Schedule periodic task'),
              ),
              OutlinedButton(
                onPressed: () async {
                  await service.cancelAll();
                  setState(() => _status = 'All tasks cancelled');
                },
                child: const Text('Cancel all'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_status != null) Text(_status!),
          const Divider(height: 32),
          Row(
            children: [
              Expanded(
                child: Text(
                  _lastRun == null
                      ? 'No recorded run yet'
                      : 'Last run: $_lastRun',
                ),
              ),
              TextButton(
                onPressed: _refreshLastRun,
                child: const Text('Check last run'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
