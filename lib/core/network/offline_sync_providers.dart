import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod_clean_architecture/core/constants/app_constants.dart';
import 'package:flutter_riverpod_clean_architecture/core/network/offline_sync_service.dart';
import 'package:hive/hive.dart';

/// Provider for connectivity service
final connectivityProvider = Provider<Connectivity>((ref) {
  return Connectivity();
});

/// Provider for offline sync Hive box
final offlineSyncBoxProvider = FutureProvider<Box<String>>((ref) async {
  // Open the box
  return await Hive.openBox<String>(AppConstants.offlineSyncBox);
});

/// Provider for conflict resolution strategy
final conflictResolutionStrategyProvider = Provider<ConflictResolutionStrategy>(
  (ref) {
    // Use smart merge strategy with field priorities
    return SmartMergeStrategy({
      'id': false, // Server wins for IDs
      'createdAt': false, // Server wins for creation timestamps
      'updatedAt': true, // Client wins for update timestamps
      // Add more field priorities as needed
    });
  },
);

/// Provider for offline sync service
final offlineSyncServiceProvider = Provider<OfflineSyncService>((ref) {
  // Wait for the box to be ready
  final boxAsync = ref.watch(offlineSyncBoxProvider);

  return boxAsync.when(
    data: (box) {
      final connectivity = ref.watch(connectivityProvider);
      final conflictStrategy = ref.watch(conflictResolutionStrategyProvider);

      final service = HiveOfflineSyncService(
        box: box,
        connectivity: connectivity,
        conflictStrategy: conflictStrategy,
      );

      // Initialize the service
      service.init();

      // Dispose the service when the provider is destroyed
      ref.onDispose(() {
        box.close();
      });

      return service;
    },
    loading: () => _LoadingOfflineSyncService(),
    error: (error, stack) => _ErrorOfflineSyncService(error.toString()),
  );
});

/// Provider for pending changes
final pendingChangesProvider = StreamProvider<List<OfflineChange>>((ref) {
  final offlineSyncService = ref.watch(offlineSyncServiceProvider);

  if (offlineSyncService is _LoadingOfflineSyncService) {
    return const Stream.empty();
  }

  if (offlineSyncService is _ErrorOfflineSyncService) {
    // Return empty list for now, but could handle error state differently
    return const Stream.empty();
  }

  return offlineSyncService.syncStatusStream;
});

/// Provider for online status
final isOnlineProvider = FutureProvider.autoDispose<bool>((ref) async {
  final connectivity = ref.watch(connectivityProvider);
  final connectivityResult = await connectivity.checkConnectivity();
  return connectivityResult != ConnectivityResult.none;
});

/// Loading placeholder for offline sync service
class _LoadingOfflineSyncService implements OfflineSyncService {
  @override
  Future<OfflineChange> queueChange({
    required String entityType,
    String? entityId,
    required OfflineOperationType operationType,
    Map<String, dynamic>? data,
  }) async {
    throw UnimplementedError('Offline sync service not yet initialized');
  }

  @override
  Future<void> syncChanges() async {
    // Do nothing while loading
  }

  @override
  Future<SyncStatus?> getSyncStatus(String entityType, String entityId) async {
    return null;
  }

  @override
  Future<List<OfflineChange>> getPendingChanges() async {
    return [];
  }

  @override
  Future<void> resolveConflict(
    String changeId,
    Map<String, dynamic> resolvedData,
  ) async {
    // Do nothing while loading
  }

  @override
  Stream<List<OfflineChange>> get syncStatusStream => const Stream.empty();

  @override
  Future<bool> isOnline() async {
    return false;
  }

  @override
  Future<void> init() async {
    // Do nothing while loading
  }
}

/// Error placeholder for offline sync service
class _ErrorOfflineSyncService implements OfflineSyncService {
  final String errorMessage;

  _ErrorOfflineSyncService(this.errorMessage);

  @override
  Future<OfflineChange> queueChange({
    required String entityType,
    String? entityId,
    required OfflineOperationType operationType,
    Map<String, dynamic>? data,
  }) async {
    throw Exception('Failed to initialize offline sync service: $errorMessage');
  }

  @override
  Future<void> syncChanges() async {
    // Do nothing in error state
  }

  @override
  Future<SyncStatus?> getSyncStatus(String entityType, String entityId) async {
    return null;
  }

  @override
  Future<List<OfflineChange>> getPendingChanges() async {
    return [];
  }

  @override
  Future<void> resolveConflict(
    String changeId,
    Map<String, dynamic> resolvedData,
  ) async {
    // Do nothing in error state
  }

  @override
  Stream<List<OfflineChange>> get syncStatusStream => const Stream.empty();

  @override
  Future<bool> isOnline() async {
    return false;
  }

  @override
  Future<void> init() async {
    // Do nothing in error state
  }
}

/// Widget that shows offline status and syncing status
class OfflineStatusIndicator extends ConsumerWidget {
  /// Create an offline status indicator
  const OfflineStatusIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnlineAsync = ref.watch(isOnlineProvider);
    final pendingChangesAsync = ref.watch(pendingChangesProvider);

    return isOnlineAsync.when(
      data: (isOnline) {
        return pendingChangesAsync.when(
          data: (pendingChanges) {
            final hasPending = pendingChanges.any(
              (c) => c.status == SyncStatus.pending,
            );
            final hasSyncing = pendingChanges.any(
              (c) => c.status == SyncStatus.syncing,
            );
            final hasFailed = pendingChanges.any(
              (c) => c.status == SyncStatus.failed,
            );

            if (!isOnline) {
              return _buildIndicator(Icons.cloud_off, 'Offline', Colors.orange);
            } else if (hasSyncing) {
              return _buildIndicator(
                Icons.sync,
                'Syncing',
                Colors.blue,
                isAnimated: true,
              );
            } else if (hasFailed) {
              return _buildIndicator(
                Icons.error_outline,
                'Sync errors',
                Colors.red,
              );
            } else if (hasPending) {
              return _buildIndicator(
                Icons.pending_outlined,
                'Changes pending',
                Colors.orange,
              );
            } else {
              return _buildIndicator(
                Icons.cloud_done,
                'All synced',
                Colors.green,
              );
            }
          },
          loading:
              () => _buildIndicator(
                Icons.sync,
                'Checking sync',
                Colors.blue,
                isAnimated: true,
              ),
          error:
              (_, __) =>
                  _buildIndicator(Icons.cloud_off, 'Sync error', Colors.red),
        );
      },
      loading:
          () => _buildIndicator(
            Icons.cloud_queue,
            'Checking connection',
            Colors.grey,
          ),
      error:
          (_, __) =>
              _buildIndicator(Icons.cloud_off, 'Connection error', Colors.red),
    );
  }

  Widget _buildIndicator(
    IconData icon,
    String message,
    Color color, {
    bool isAnimated = false,
  }) {
    return Tooltip(
      message: message,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isAnimated)
            RotatingIcon(icon: icon, color: color)
          else
            Icon(icon, color: color, size: 16),
          const SizedBox(width: 4),
          Text(message, style: TextStyle(color: color, fontSize: 12)),
        ],
      ),
    );
  }
}

/// An icon that rotates continuously
class RotatingIcon extends StatefulWidget {
  /// The icon to display
  final IconData icon;

  /// The color of the icon
  final Color color;

  /// Create a rotating icon
  const RotatingIcon({super.key, required this.icon, required this.color});

  @override
  _RotatingIconState createState() => _RotatingIconState();
}

class _RotatingIconState extends State<RotatingIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: Icon(widget.icon, color: widget.color, size: 16),
    );
  }
}
