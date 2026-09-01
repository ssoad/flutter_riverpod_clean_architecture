import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

/// Key under which the background isolate records when a task last ran, so
/// the foreground UI (which cannot directly observe the background isolate)
/// can poll for evidence a task executed.
const String lastBackgroundTaskRunKey = 'background_task_last_run';

/// The entry point WorkManager spawns in a separate background isolate to
/// run a task. It has no access to the app's widget tree, providers, or any
/// state from the isolate that scheduled it - only what you explicitly
/// persist (here, via SharedPreferences) survives the round trip.
///
/// Must be a top-level or static function, and must carry this pragma so
/// the Dart compiler doesn't tree-shake it out of release builds (nothing
/// in `lib/` appears to call it directly - WorkManager invokes it from
/// native code).
@pragma('vm:entry-point')
void backgroundTaskCallbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    debugPrint('BackgroundTask running: $taskName, input: $inputData');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      lastBackgroundTaskRunKey,
      '$taskName @ ${DateTime.now().toIso8601String()}',
    );
    // Return true to report success; WorkManager retries the task if you
    // return false or throw.
    return Future.value(true);
  });
}

/// Thin wrapper over the `workmanager` plugin for scheduling deferrable,
/// guaranteed background work (sync, cleanup, periodic refresh, ...) that
/// should keep running even if the app is closed - the plugin hands it to
/// Android's WorkManager / iOS's BGTaskScheduler under the hood.
class BackgroundTaskService {
  bool _initialized = false;

  /// Must be called once (e.g. in `main()`) before scheduling any task.
  Future<void> initialize() async {
    if (_initialized) return;
    await Workmanager().initialize(backgroundTaskCallbackDispatcher);
    _initialized = true;
  }

  /// Schedules a single task to run once, after at least [initialDelay].
  Future<void> registerOneOffTask({
    required String uniqueName,
    required String taskName,
    Duration initialDelay = Duration.zero,
  }) {
    return Workmanager().registerOneOffTask(
      uniqueName,
      taskName,
      initialDelay: initialDelay,
      existingWorkPolicy: ExistingWorkPolicy.replace,
    );
  }

  /// Schedules a recurring task. Android enforces a 15-minute minimum
  /// frequency; shorter values are silently clamped up to it by the OS.
  Future<void> registerPeriodicTask({
    required String uniqueName,
    required String taskName,
    Duration frequency = const Duration(minutes: 15),
  }) {
    return Workmanager().registerPeriodicTask(
      uniqueName,
      taskName,
      frequency: frequency,
      existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
    );
  }

  Future<void> cancelByUniqueName(String uniqueName) =>
      Workmanager().cancelByUniqueName(uniqueName);

  Future<void> cancelAll() => Workmanager().cancelAll();

  /// Reads the marker the background isolate last wrote, so the UI can show
  /// evidence a scheduled task actually ran.
  Future<String?> readLastRunMarker() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(lastBackgroundTaskRunKey);
  }
}

final backgroundTaskServiceProvider = Provider<BackgroundTaskService>(
  (ref) => BackgroundTaskService(),
);
