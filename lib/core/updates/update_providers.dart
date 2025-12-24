import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/constants/app_constants.dart';
import 'package:flutter_riverpod_clean_architecture/core/updates/update_service.dart';

/// Provider for the update service
final updateServiceProvider = Provider<UpdateService>((ref) {
  return BasicUpdateService(
    androidPackageName: AppConstants.packageName,
    iOSAppId: AppConstants.iOSAppId,
  );
});

/// Provider for checking if an update is available
final updateCheckProvider = FutureProvider.autoDispose<UpdateCheckResult>((
  ref,
) async {
  final updateService = ref.watch(updateServiceProvider);
  await updateService.init();
  return await updateService.checkForUpdates();
});

/// Provider for the update information
final updateInfoProvider = FutureProvider.autoDispose<UpdateInfo?>((ref) async {
  final updateService = ref.watch(updateServiceProvider);
  return await updateService.getUpdateInfo();
});

/// Controller for the update flow
/// Controller for the update flow
class UpdateController extends AsyncNotifier<UpdateCheckResult> {
  @override
  Future<UpdateCheckResult> build() async {
    final updateService = ref.watch(updateServiceProvider);
    await updateService.init();
    return await updateService.checkForUpdates();
  }

  /// Check for updates
  Future<void> checkForUpdates() async {
    state = const AsyncValue.loading();

    try {
      final updateService = ref.read(updateServiceProvider);
      final result = await updateService.checkForUpdates();
      state = AsyncValue.data(result);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Prompt the user to update the app
  Future<bool> promptForUpdate({bool force = false}) async {
    final updateService = ref.read(updateServiceProvider);
    return await updateService.promptUpdate(force: force);
  }

  /// Open the update URL
  Future<bool> openUpdateUrl() async {
    final updateService = ref.read(updateServiceProvider);
    return await updateService.openUpdateUrl();
  }

  /// Get information about the available update
  Future<UpdateInfo?> getUpdateInfo() async {
    final updateService = ref.read(updateServiceProvider);
    return await updateService.getUpdateInfo();
  }
}

/// Provider for the update controller
final updateControllerProvider =
    AsyncNotifierProvider<UpdateController, UpdateCheckResult>(
      UpdateController.new,
    );

/// Widget that shows an update dialog when an update is available
class UpdateChecker extends ConsumerWidget {
  /// The child widget to display
  final Widget child;

  /// Whether to automatically prompt for updates
  final bool autoPrompt;

  /// Whether to force updates (prevent dismissal of critical updates)
  final bool enforceCriticalUpdates;

  /// Create an update checker
  const UpdateChecker({
    super.key,
    required this.child,
    this.autoPrompt = true,
    this.enforceCriticalUpdates = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue<UpdateCheckResult>>(updateControllerProvider, (
      _,
      state,
    ) {
      state.whenData((result) {
        if (autoPrompt &&
            (result == UpdateCheckResult.updateAvailable ||
                result == UpdateCheckResult.criticalUpdateRequired)) {
          _showUpdateDialog(context, ref, result);
        }
      });
    });

    return child;
  }

  void _showUpdateDialog(
    BuildContext context,
    WidgetRef ref,
    UpdateCheckResult result,
  ) async {
    final updateController = ref.read(updateControllerProvider.notifier);
    final updateInfo = await updateController.getUpdateInfo();

    if (updateInfo == null || !context.mounted) return;

    final isCritical = result == UpdateCheckResult.criticalUpdateRequired;

    showDialog(
      context: context,
      barrierDismissible: !isCritical,
      builder: (context) =>
          UpdateDialog(updateInfo: updateInfo, isCritical: isCritical),
    );
  }
}

/// Dialog that shows information about an available update
class UpdateDialog extends ConsumerWidget {
  /// Information about the update
  final UpdateInfo updateInfo;

  /// Whether the update is critical
  final bool isCritical;

  /// Create an update dialog
  const UpdateDialog({
    super.key,
    required this.updateInfo,
    this.isCritical = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return PopScope(
      canPop: !isCritical,
      child: AlertDialog(
        title: Text(isCritical ? 'Required Update' : 'Update Available'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isCritical
                    ? 'A critical update (version ${updateInfo.latestVersion}) is required to continue using this app.'
                    : 'A new version (${updateInfo.latestVersion}) is available.',
                style: theme.textTheme.bodyLarge,
              ),
              if (updateInfo.releaseNotes != null) ...[
                const SizedBox(height: 16),
                Text('What\'s new:', style: theme.textTheme.titleSmall),
                const SizedBox(height: 4),
                Text(updateInfo.releaseNotes!),
              ],
            ],
          ),
        ),
        actions: [
          if (!isCritical)
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Later'),
            ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(updateControllerProvider.notifier).openUpdateUrl();
            },
            child: Text(isCritical ? 'Update Now' : 'Update'),
          ),
        ],
      ),
    );
  }
}
