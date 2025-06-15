# Offline-First Architecture Guide

This guide explains how to use the offline-first architecture in the Flutter Riverpod Clean Architecture template to create apps that work seamlessly with or without an internet connection.

## Table of Contents

- [Introduction](#introduction)
- [Key Components](#key-components)
- [Basic Usage](#basic-usage)
- [Conflict Resolution](#conflict-resolution)
- [UI Integration](#ui-integration)
- [Advanced Usage](#advanced-usage)
- [Best Practices](#best-practices)

## Introduction

An offline-first approach means designing your app to work without an internet connection by default, then syncing data when a connection becomes available. This provides several benefits:

- Better user experience in areas with poor connectivity
- Faster app performance (no waiting for network responses)
- Reduced data usage
- More resilient applications

## Key Components

The offline-first architecture consists of several key components:

- `OfflineSyncService`: Core service for managing offline data and synchronization
- `OfflineChange`: Represents a pending change that needs to be synced
- `ConflictResolutionStrategy`: Interface for resolving conflicts between local and remote data
- `OfflineStatusIndicator`: UI widget showing sync status

## Basic Usage

### Setting Up

The providers are already set up in the template. To use them, simply inject the service:

```dart
final offlineSyncService = ref.watch(offlineSyncServiceProvider);
```

### Queuing Changes

When making changes that need to be synced to the server:

```dart
// Create a new entity
await offlineSyncService.queueChange(
  entityType: 'task',
  operationType: OfflineOperationType.create,
  data: {
    'title': 'Buy groceries',
    'completed': false,
    'dueDate': DateTime.now().add(Duration(days: 1)).toIso8601String(),
  },
);

// Update an existing entity
await offlineSyncService.queueChange(
  entityType: 'task',
  entityId: '123',
  operationType: OfflineOperationType.update,
  data: {
    'completed': true,
  },
);

// Delete an entity
await offlineSyncService.queueChange(
  entityType: 'task',
  entityId: '123',
  operationType: OfflineOperationType.delete,
);
```

### Syncing Changes

Sync happens automatically when the device comes online. You can also trigger it manually:

```dart
await offlineSyncService.syncChanges();
```

### Checking Sync Status

Check the status of an entity:

```dart
final status = await offlineSyncService.getSyncStatus('task', '123');
if (status == SyncStatus.pending) {
  // This entity has pending changes
}
```

## Conflict Resolution

When the same entity is modified both locally and remotely, conflicts can occur. The template provides three strategies:

### Client Wins

Local changes override server changes:

```dart
final clientWinsStrategy = ClientWinsStrategy();
```

### Server Wins

Server changes override local changes:

```dart
final serverWinsStrategy = ServerWinsStrategy();
```

### Smart Merge

Intelligently merge changes based on field priorities:

```dart
final smartMergeStrategy = SmartMergeStrategy({
  'id': false, // Server wins for IDs
  'title': true, // Client wins for titles
  'updatedAt': true, // Client wins for update timestamps
});
```

### Custom Resolution

To manually resolve conflicts:

```dart
await offlineSyncService.resolveConflict(
  changeId, 
  mergedData, // Combined data after resolving conflicts
);
```

## UI Integration

### Showing Sync Status

Use the `OfflineStatusIndicator` widget to show the current sync status:

```dart
AppBar(
  title: Text('My App'),
  actions: [
    OfflineStatusIndicator(),
  ],
)
```

### Displaying Pending Changes

To show pending changes in your UI:

```dart
final pendingChanges = ref.watch(pendingChangesProvider);

return pendingChanges.when(
  data: (changes) {
    final entityChanges = changes.where(
      (c) => c.entityType == 'task'
    ).toList();
    
    return ListView.builder(
      itemCount: entityChanges.length,
      itemBuilder: (context, index) {
        final change = entityChanges[index];
        return ListTile(
          title: Text(change.data?['title'] ?? 'Untitled'),
          trailing: _buildSyncIndicator(change.status),
        );
      },
    );
  },
  loading: () => CircularProgressIndicator(),
  error: (_, __) => Text('Error loading changes'),
);
```

## Advanced Usage

### Combining with Repository Pattern

Integrate with your domain repositories:

```dart
class TaskRepository {
  final OfflineSyncService _offlineSyncService;
  final ApiService _apiService;
  
  // In-memory cache for quick access
  final Map<String, Task> _localCache = {};
  
  Future<Task> createTask(Task task) async {
    // Store locally
    final newTask = task.copyWith(id: const Uuid().v4());
    _localCache[newTask.id] = newTask;
    
    // Queue for sync
    await _offlineSyncService.queueChange(
      entityType: 'task',
      entityId: newTask.id,
      operationType: OfflineOperationType.create,
      data: newTask.toJson(),
    );
    
    return newTask;
  }
  
  Future<List<Task>> getAllTasks() async {
    // Try to get from API if online
    if (await _offlineSyncService.isOnline()) {
      try {
        final remoteTasks = await _apiService.getTasks();
        _localCache.clear();
        for (final task in remoteTasks) {
          _localCache[task.id] = task;
        }
      } catch (_) {
        // Fall back to cache if API fails
      }
    }
    
    // Return cached tasks
    return _localCache.values.toList();
  }
}
```

### Background Sync

To set up background sync with WorkManager:

```dart
import 'package:workmanager/workmanager.dart';

// Initialize in main.dart
Workmanager().initialize(callbackDispatcher);
Workmanager().registerPeriodicTask(
  'sync',
  'periodicSync',
  frequency: Duration(hours: 1),
  constraints: Constraints(
    networkType: NetworkType.connected,
  ),
);

// Define the callback
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == 'periodicSync') {
      final container = ProviderContainer();
      final syncService = container.read(offlineSyncServiceProvider);
      await syncService.syncChanges();
    }
    return true;
  });
}
```

## Best Practices

1. **Store minimal data**: Only cache what's needed for offline functionality
2. **Use optimistic updates**: Update the UI immediately, then sync in the background
3. **Show sync status**: Keep users informed about the status of their changes
4. **Handle conflicts gracefully**: Provide clear UI for resolving conflicts
5. **Add timestamps**: Include created/updated timestamps to help with conflict resolution
6. **Prioritize sync**: Sync critical operations first
7. **Throttle sync**: Don't sync on every change, batch operations
8. **Test offline scenarios**: Regularly test your app in airplane mode

By following these patterns, you can create a robust offline-first application that provides a seamless experience regardless of connectivity.
