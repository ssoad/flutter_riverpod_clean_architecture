# Coding Standards & Best Practices

To maintain the high quality of this codebase, strict adherence to the following standards is required.

---

## 1. Architecture Rules

### ❌ Never Import Flutter in Domain
The Domain layer must be pure Dart.
- **Bad**: `import 'package:flutter/material.dart';`
- **Good**: `import 'package:equatable/equatable.dart';`

### ❌ Never Import Flutter in Data (Except Models)
Keep Data sources framework-agnostic.
- **Bad**: `debugPrint('error')`
- **Good**: `Logger.error('error')` (from `core/utils`)

### ✅ Always Use `fpdart` for Errors
Do not throw exceptions in Use Cases or Repositories.
- **Bad**: `Future<User>` (throws exception)
- **Good**: `Future<Either<Failure, User>>`

---

## 2. Riverpod Patterns

### ✅ Use `Notifier` / `AsyncNotifier`
Avoid `StateProvider` or `ChangeNotifier` for complex state.
- **Why**: Better testability and lifecycle management.

### ✅ Separate Data DI from UI State
- **Data Providers**: Place in `features/[feature]/providers/`. Define Repositories/UseCases/DataSources.
- **UI Providers**: Place in `features/[feature]/presentation/providers/`. Define `Notifier`s for screens.

### ✅ Use `ref.watch` in build(), `ref.read` in callbacks
- **Watch**: For values that trigger rebuilds.
- **Read**: For one-time actions (button clicks).

---

## 3. Code Style

### ✅ Explicit Types
Always explicitly type return values and arguments.
```dart
// Bad
var x = 10;
getUser() { ... }

// Good
int x = 10;
Future<User> getUser() { ... }
```

### ✅ Trailing Commas
Always use trailing commas for better formatting.

### ✅ Relative Imports for Feature-Internal
Use relative imports for files inside the same feature.
```dart
import '../domain/entities/user.dart'; // Good
```
Use package imports for crossing feature boundaries or core.
```dart
import 'package:app/core/utils/logger.dart'; // Good
```

---

## 4. Testing

### ✅ Mock Everything External
Use `mocktail` to mock Repositories when testing Use Cases, and RemoteDataSources when testing Repositories.

### ✅ 100% Domain Coverage
Ideally, every Use Case should have unit tests covering Success and Failure paths.

### ✅ Goldens for UI
Use Golden tests for complex screens to prevent visual regression.
