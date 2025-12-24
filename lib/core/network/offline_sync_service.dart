import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:synchronized/synchronized.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Status of a sync operation
enum SyncStatus {
  /// Waiting to be synced
  pending,

  /// Currently syncing
  syncing,

  /// Successfully synced
  synced,

  /// Failed to sync
  failed,

  /// Sync conflict detected
  conflict,

  /// Canceled sync
  canceled,
}

/// Operation type for offline changes
enum OfflineOperationType {
  /// Create operation
  create,

  /// Update operation
  update,

  /// Delete operation
  delete,

  /// Custom operation
  custom,
}

/// Represents an offline change that needs to be synced
class OfflineChange {
  /// Unique identifier for this change
  final String id;

  /// Entity type (e.g., "user", "post", "comment")
  final String entityType;

  /// Entity ID (can be null for create operations)
  final String? entityId;

  /// Type of operation
  final OfflineOperationType operationType;

  /// Data to sync (can be null for delete operations)
  final Map<String, dynamic>? data;

  /// Status of the sync operation
  final SyncStatus status;

  /// Timestamp when the change was created
  final DateTime timestamp;

  /// Number of retry attempts
  final int retryCount;

  /// Time of the last retry attempt
  final DateTime? lastRetryTime;

  /// Error message if sync failed
  final String? errorMessage;

  /// Create an offline change
  const OfflineChange({
    required this.id,
    required this.entityType,
    this.entityId,
    required this.operationType,
    this.data,
    required this.status,
    required this.timestamp,
    this.retryCount = 0,
    this.lastRetryTime,
    this.errorMessage,
  });

  /// Convert to a JSON object
  Map<String, dynamic> toJson() => {
    'id': id,
    'entityType': entityType,
    'entityId': entityId,
    'operationType': operationType.toString().split('.').last,
    'data': data,
    'status': status.toString().split('.').last,
    'timestamp': timestamp.toIso8601String(),
    'retryCount': retryCount,
    'lastRetryTime': lastRetryTime?.toIso8601String(),
    'errorMessage': errorMessage,
  };

  /// Create from a JSON object
  factory OfflineChange.fromJson(Map<String, dynamic> json) {
    return OfflineChange(
      id: json['id'],
      entityType: json['entityType'],
      entityId: json['entityId'],
      operationType: _parseOperationType(json['operationType']),
      data: json['data'] != null
          ? Map<String, dynamic>.from(json['data'])
          : null,
      status: _parseSyncStatus(json['status']),
      timestamp: DateTime.parse(json['timestamp']),
      retryCount: json['retryCount'] ?? 0,
      lastRetryTime: json['lastRetryTime'] != null
          ? DateTime.parse(json['lastRetryTime'])
          : null,
      errorMessage: json['errorMessage'],
    );
  }

  /// Create a copy with updated fields
  OfflineChange copyWith({
    String? id,
    String? entityType,
    String? entityId,
    OfflineOperationType? operationType,
    Map<String, dynamic>? data,
    SyncStatus? status,
    DateTime? timestamp,
    int? retryCount,
    DateTime? lastRetryTime,
    String? errorMessage,
  }) {
    return OfflineChange(
      id: id ?? this.id,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      operationType: operationType ?? this.operationType,
      data: data ?? this.data,
      status: status ?? this.status,
      timestamp: timestamp ?? this.timestamp,
      retryCount: retryCount ?? this.retryCount,
      lastRetryTime: lastRetryTime ?? this.lastRetryTime,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  static OfflineOperationType _parseOperationType(String value) {
    switch (value) {
      case 'create':
        return OfflineOperationType.create;
      case 'update':
        return OfflineOperationType.update;
      case 'delete':
        return OfflineOperationType.delete;
      default:
        return OfflineOperationType.custom;
    }
  }

  static SyncStatus _parseSyncStatus(String value) {
    switch (value) {
      case 'pending':
        return SyncStatus.pending;
      case 'syncing':
        return SyncStatus.syncing;
      case 'synced':
        return SyncStatus.synced;
      case 'failed':
        return SyncStatus.failed;
      case 'conflict':
        return SyncStatus.conflict;
      case 'canceled':
        return SyncStatus.canceled;
      default:
        return SyncStatus.pending;
    }
  }
}

/// Interface for conflict resolution strategies
abstract class ConflictResolutionStrategy {
  /// Resolve conflict between local and remote changes
  Future<Map<String, dynamic>> resolveConflict({
    required String entityType,
    required String entityId,
    required Map<String, dynamic>? localData,
    required Map<String, dynamic>? remoteData,
    required OfflineOperationType operationType,
  });
}

/// Client wins conflict resolution strategy (client data overrides server)
class ClientWinsStrategy implements ConflictResolutionStrategy {
  @override
  Future<Map<String, dynamic>> resolveConflict({
    required String entityType,
    required String entityId,
    required Map<String, dynamic>? localData,
    required Map<String, dynamic>? remoteData,
    required OfflineOperationType operationType,
  }) async {
    // Always use local data
    return localData ?? {};
  }
}

/// Server wins conflict resolution strategy (server data overrides client)
class ServerWinsStrategy implements ConflictResolutionStrategy {
  @override
  Future<Map<String, dynamic>> resolveConflict({
    required String entityType,
    required String entityId,
    required Map<String, dynamic>? localData,
    required Map<String, dynamic>? remoteData,
    required OfflineOperationType operationType,
  }) async {
    // Always use remote data
    return remoteData ?? {};
  }
}

/// Smart merge conflict resolution strategy (merge fields intelligently)
class SmartMergeStrategy implements ConflictResolutionStrategy {
  final Map<String, bool> _fieldPriorities;

  /// Create a smart merge strategy with field priorities
  /// (true means client wins for that field, false means server wins)
  SmartMergeStrategy(this._fieldPriorities);

  @override
  Future<Map<String, dynamic>> resolveConflict({
    required String entityType,
    required String entityId,
    required Map<String, dynamic>? localData,
    required Map<String, dynamic>? remoteData,
    required OfflineOperationType operationType,
  }) async {
    // If either data is null, return the non-null one
    if (localData == null) return remoteData ?? {};
    if (remoteData == null) return localData;

    // Start with remote data as base
    final result = Map<String, dynamic>.from(remoteData);

    // Apply local changes based on field priorities
    localData.forEach((key, value) {
      final clientWins = _fieldPriorities[key] ?? false;
      if (clientWins) {
        result[key] = value;
      }
    });

    return result;
  }
}

/// Interface for syncing offline changes
abstract class OfflineSyncService {
  /// Queue an offline change
  Future<OfflineChange> queueChange({
    required String entityType,
    String? entityId,
    required OfflineOperationType operationType,
    Map<String, dynamic>? data,
  });

  /// Start syncing pending changes
  Future<void> syncChanges();

  /// Get the sync status for an entity
  Future<SyncStatus?> getSyncStatus(String entityType, String entityId);

  /// Get all pending changes
  Future<List<OfflineChange>> getPendingChanges();

  /// Handle sync conflicts
  Future<void> resolveConflict(
    String changeId,
    Map<String, dynamic> resolvedData,
  );

  /// Listen to sync status changes
  Stream<List<OfflineChange>> get syncStatusStream;

  /// Check if the device is online
  Future<bool> isOnline();

  /// Initialize the sync service
  Future<void> init();
}

/// Implementation of the offline sync service
class HiveOfflineSyncService implements OfflineSyncService {
  final Box<String> _box;
  final Connectivity _connectivity;
  final Lock _syncLock = Lock();

  final _uuid = const Uuid();
  final _syncController = StreamController<List<OfflineChange>>.broadcast();
  bool _isSyncing = false;

  /// Create a Hive-based offline sync service
  HiveOfflineSyncService({
    required Box<String> box,
    required Connectivity connectivity,
    ConflictResolutionStrategy? conflictStrategy,
  }) : _box = box,
       _connectivity = connectivity;

  @override
  Future<void> init() async {
    // Set up connectivity listener for auto-sync
    _connectivity.onConnectivityChanged.listen((result) {
      if (!result.contains(ConnectivityResult.none)) {
        syncChanges();
      }
    });

    debugPrint('🔄 Offline sync service initialized');
  }

  @override
  Future<OfflineChange> queueChange({
    required String entityType,
    String? entityId,
    required OfflineOperationType operationType,
    Map<String, dynamic>? data,
  }) async {
    final id = _uuid.v4();
    final change = OfflineChange(
      id: id,
      entityType: entityType,
      entityId: entityId,
      operationType: operationType,
      data: data,
      status: SyncStatus.pending,
      timestamp: DateTime.now(),
    );

    // Store the change
    await _box.put(id, jsonEncode(change.toJson()));

    // Notify listeners
    _notifyListeners();

    // Try to sync immediately if online
    if (await isOnline()) {
      syncChanges();
    }

    return change;
  }

  @override
  Future<void> syncChanges() async {
    // Prevent multiple simultaneous sync attempts
    if (_isSyncing) return;

    // Check connectivity
    if (!await isOnline()) return;

    // Use a lock to prevent concurrent sync operations
    await _syncLock.synchronized(() async {
      _isSyncing = true;

      // Notify listeners that sync is starting
      _notifyListeners();

      try {
        // Get all pending changes
        final pendingChanges = await getPendingChanges().then(
          (changes) =>
              changes.where((c) => c.status == SyncStatus.pending).toList(),
        );

        // Sort changes by timestamp (oldest first)
        pendingChanges.sort((a, b) => a.timestamp.compareTo(b.timestamp));

        // Process each change
        for (final change in pendingChanges) {
          await _processChange(change);
        }
      } finally {
        _isSyncing = false;

        // Notify listeners that sync is complete
        _notifyListeners();
      }
    });
  }

  Future<void> _processChange(OfflineChange change) async {
    // Mark as syncing
    final syncingChange = change.copyWith(status: SyncStatus.syncing);
    await _box.put(change.id, jsonEncode(syncingChange.toJson()));
    _notifyListeners();

    try {
      // In a real app, this would call your API
      // For now, we'll simulate successful sync after a delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Mark as synced
      final syncedChange = syncingChange.copyWith(status: SyncStatus.synced);
      await _box.put(change.id, jsonEncode(syncedChange.toJson()));
    } catch (e) {
      // Handle failure
      final failedChange = syncingChange.copyWith(
        status: SyncStatus.failed,
        retryCount: change.retryCount + 1,
        lastRetryTime: DateTime.now(),
        errorMessage: e.toString(),
      );
      await _box.put(change.id, jsonEncode(failedChange.toJson()));
    }

    // Notify listeners
    _notifyListeners();
  }

  @override
  Future<SyncStatus?> getSyncStatus(String entityType, String entityId) async {
    // Find the latest change for this entity
    final changes = await getPendingChanges();
    final entityChanges = changes
        .where((c) => c.entityType == entityType && c.entityId == entityId)
        .toList();

    if (entityChanges.isEmpty) return null;

    // Sort by timestamp (most recent first)
    entityChanges.sort((a, b) => b.timestamp.compareTo(a.timestamp));

    return entityChanges.first.status;
  }

  @override
  Future<List<OfflineChange>> getPendingChanges() async {
    final changes = <OfflineChange>[];

    for (final key in _box.keys) {
      final json = _box.get(key);
      if (json != null) {
        try {
          final change = OfflineChange.fromJson(jsonDecode(json));
          changes.add(change);
        } catch (e) {
          debugPrint('🔄 Error parsing change: $e');
        }
      }
    }

    return changes;
  }

  @override
  Future<void> resolveConflict(
    String changeId,
    Map<String, dynamic> resolvedData,
  ) async {
    // Get the original change
    final json = _box.get(changeId);
    if (json == null) return;

    final change = OfflineChange.fromJson(jsonDecode(json));

    // Update with resolved data
    final resolvedChange = change.copyWith(
      data: resolvedData,
      status: SyncStatus.pending, // Reset to pending to try sync again
    );

    await _box.put(changeId, jsonEncode(resolvedChange.toJson()));

    // Notify listeners
    _notifyListeners();

    // Try to sync again
    syncChanges();
  }

  @override
  Stream<List<OfflineChange>> get syncStatusStream => _syncController.stream;

  void _notifyListeners() async {
    final changes = await getPendingChanges();
    _syncController.add(changes);
  }

  @override
  Future<bool> isOnline() async {
    final connectivityResult = await _connectivity.checkConnectivity();
    return !connectivityResult.contains(ConnectivityResult.none);
  }
}

/// A StreamController for tracking sync status
class StreamController<T> {
  final List<void Function(T)> _listeners = [];

  /// Create a broadcast stream controller
  StreamController.broadcast();

  /// Add a value to the stream
  void add(T value) {
    for (final listener in _listeners) {
      listener(value);
    }
  }

  /// Get the stream
  Stream<T> get stream =>
      Stream<T>.periodic(const Duration(days: 365), (_) {
          throw UnimplementedError('This is a mock stream for demo purposes');
        }).asBroadcastStream()
        ..listen((event) {}, onDone: () {}, onError: (error, stack) {});
}
