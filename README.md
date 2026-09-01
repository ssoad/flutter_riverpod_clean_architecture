# Flutter Riverpod Clean Architecture Template

[![Flutter CI/CD](https://github.com/ssoad/flutter_riverpod_clean_architecture/actions/workflows/flutter_ci_cd.yml/badge.svg)](https://github.com/ssoad/flutter_riverpod_clean_architecture/actions/workflows/flutter_ci_cd.yml)
![Flutter](https://img.shields.io/badge/Flutter-3.35+-02569B?style=flat&logo=flutter)
![Riverpod](https://img.shields.io/badge/Riverpod-3.x-0175C2?style=flat)
![Architecture](https://img.shields.io/badge/Architecture-Clean-success)
![License](https://img.shields.io/badge/License-MIT-purple)

A production-ready, highly scalable Flutter template designed for modern application development. It implements strictly typed **Clean Architecture** with **Riverpod** for state management and dependency injection, and ships with a working example of nearly every integration pattern a real app eventually needs — REST, WebSocket, webhooks, GraphQL, gRPC, background tasks, biometrics, offline sync, and more — so you can start from "already solved" instead of "figure it out."

---

## 🚀 Key Features

### Core Architecture
- **Strict Clean Architecture**: clear separation of Domain, Data, and Presentation layers, generated consistently for every feature.
- **Functional Error Handling**: uses `fpdart` for type-safe error handling (`Either<Failure, T>`) instead of throwing.
- **Riverpod 3.x**: modern provider patterns with `Notifier`, `AsyncNotifier`, and code-generated (`riverpod_generator`) providers.
- **Framework Independence**: Domain and Data layers are testable without any Flutter dependency.

### Developer Experience
- **Feature Generator**: create a complete feature — domain, data, presentation, tests — in seconds (`./generate_feature.sh`).
- **Strict Linting**: an opinionated `analysis_options.yaml` plus `riverpod_lint`/`custom_lint`, kept at zero issues.
- **CI/CD Ready**: GitHub Actions run `dart format`, `flutter analyze`, and `flutter test` on every push and PR.
- **Type Safety**: full null-safety and strict typing throughout, `freezed`/`json_serializable` for models.

### Advanced Capabilities
- **Auth, Tasks, Posts, Notifications, Survey, Chat**: complete, working features built on the architecture, not just docs describing it.
- **Offline First**: local storage and sync strategies with Hive/SharedPreferences/`flutter_secure_storage`.
- **Biometric Auth**: Face ID / fingerprint gating both app access and sensitive actions.
- **Localization**: multi-language support (`intl` + custom ARB tooling) with a runtime language switcher.
- **A full integration example gallery** — see below.

---

## 🧭 Examples Hub — start here for any requirement

This template ships small, copyable examples of the integration and platform patterns most apps need sooner or later, so you can pick the one your requirement matches and adapt it instead of researching it from scratch. Run the app, sign in, and tap **Examples** (home screen tile, or the compass icon in the bottom nav) to browse all of them — or jump straight to the source under `lib/examples/examples_hub_screen.dart`.

| Pattern | Where | Notes |
|---|---|---|
| REST | `features/posts/` (uses `core/network/api_client.dart`) | Repository pattern over Dio, with offline cache fallback |
| WebSocket | `core/network/integrations/websocket_client.dart` | Connect/send/receive/reconnect; demoed against a public echo server |
| Webhook (send) | `core/network/integrations/webhook_sender.dart` + `webhook_signature.dart` | HMAC-SHA256 signed outbound POST |
| Webhook (receive) | `core/network/integrations/local_webhook_receiver.dart` | Local-only `dart:io` `HttpServer` for dev/testing; not available on web |
| GraphQL | `core/network/integrations/graphql_client.dart` | Thin Dio wrapper — a query and a mutation, no extra state-management framework |
| gRPC | `core/network/integrations/grpc/` | Real `protoc`-generated client for a unary + a server-streaming call; not available on web. Run `dart run tool/grpc_demo_server.dart` locally to exercise the streaming call end-to-end |
| Background tasks | `core/background/background_task_service.dart` | `workmanager`: one-off and periodic scheduled work, survives the app being closed |
| Biometric auth | `core/auth/local_biometric_service.dart` + `examples/biometrics_demo.dart` | Fingerprint/Face ID gating app access and sensitive transactions |
| File upload/download | `core/network/integrations/file_transfer_service.dart` | Multipart upload and download, both with progress callbacks; not available on web |
| Feature flags, analytics, notifications, images, logging, accessibility, app updates, offline sync, app reviews | `examples/advanced_features_showcase.dart` | One screen touring the rest of `core/` |

A few of these (the local webhook receiver, gRPC, and file transfer to disk) need a real filesystem or raw TCP socket and are intentionally unavailable on Flutter Web — each says so in its own screen and doc comment rather than failing silently.

---

## 📚 Documentation

The full guide set lives in [`docs/`](docs/) and is published as a static site at **[ssoad.github.io/flutter_riverpod_clean_architecture](https://ssoad.github.io/flutter_riverpod_clean_architecture/)** (rebuilt automatically on every push to `docs/`). The most useful starting points:

| Guide | What it covers |
|---|---|
| [Getting Started](docs/GETTING_STARTED.md) | The fastest path from clone to running app |
| [Architecture Guide](docs/ARCHITECTURE_GUIDE.md) | The Clean Architecture layering this template enforces |
| [Coding Standards](docs/CODING_STANDARDS.md) | Naming, structure, and lint conventions used throughout |
| [CLI Tools](docs/TOOLS.md) | The generator/rename/icon scripts, in more depth than below |
| [Features](docs/FEATURES.md) | What each built-in feature does |
| [Examples](docs/EXAMPLES.md) | Deeper walkthroughs of specific patterns |
| [CI/CD Guide](docs/CICD_GUIDE.md) | How the GitHub Actions workflows are wired up |
| [Contributing](docs/CONTRIBUTING.md) | How to propose changes to this template |

Plus focused guides for individual subsystems: [Localization](docs/LOCALIZATION_GUIDE.md), [Biometric Auth](docs/BIOMETRIC_AUTH_GUIDE.md), [Offline Architecture](docs/OFFLINE_ARCHITECTURE_GUIDE.md), [Feature Flags](docs/FEATURE_FLAGS_GUIDE.md), [Analytics](docs/ANALYTICS_GUIDE.md), [Accessibility](docs/ACCESSIBILITY_GUIDE.md), and [Image Handling](docs/IMAGE_HANDLING_GUIDE.md).

---

## 🛠️ Quick Start

### 1. Prerequisites
- Flutter SDK, latest stable channel (developed and CI-tested against 3.35+)
- Dart SDK 3.10+ (bundled with the Flutter SDK above)

### 2. Installation
```bash
# Clone the repository
git clone https://github.com/ssoad/flutter_riverpod_clean_architecture.git
cd flutter_riverpod_clean_architecture

# Install dependencies
flutter pub get

# Generate code (Freezed, Riverpod, JSON serialization)
dart run build_runner build --delete-conflicting-outputs
```

### 3. Running the App
```bash
# Development
flutter run

# Production build
flutter build apk --release
```

---

## ⚡ CLI Tools

Five scripts automate the parts of starting a new project that are otherwise tedious and error-prone. All are executable (`chmod +x` already set) and safe to run from the repo root; see [`docs/TOOLS.md`](docs/TOOLS.md) for full detail on each.

### Generate a new feature
```bash
./generate_feature.sh --name my_awesome_feature
```
Scaffolds a complete feature module — `domain/{entities,repositories,usecases}`, `data/{models,datasources,repositories}`, `presentation/{providers,screens,widgets}`, a `providers/` DI file, and unit tests for every layer — following the same structure as every existing feature.

### Rename the app
```bash
./rename_app.sh --app-name "My Super App" --package-name com.company.superapp
```
Updates the display name and package/bundle identifier across Android, iOS, macOS, Windows, Linux and Web, moves the Kotlin package directory, and rewrites internal `package:...` Dart imports. Cross-platform (works with both BSD/macOS and GNU/Linux `sed`).

### Generate app icons
```bash
# 1. Place a 1024x1024 source icon at assets/icon/app_icon.png
# 2. Run:
./generate_icons.sh
```
Generates native icons for Android `mipmap`, iOS `Assets.xcassets`, Web `manifest.json`, and Windows/macOS/Linux via `flutter_launcher_icons`.

### Manage localization
```bash
./generate_language.sh generate       # regenerate the localization delegate from the ARB files
./generate_language.sh list           # list supported languages
./generate_language.sh add <code>     # scaffold a new language, e.g. `add fr`
```
Also checks every non-English ARB file against `intl_en.arb` and reports any missing translation keys.

### Run tests with coverage
```bash
./test_generator.sh                   # run all tests and generate an HTML coverage report
./test_generator.sh --no-coverage     # skip coverage collection
./test_generator.sh --target test/features/auth  # scope to a directory
```

---

## 🏗️ Project Structure

```
lib/
├── core/                       # Shared kernel: network, storage, auth, error handling, DI
│   ├── network/
│   │   └── integrations/       # WebSocket, webhook, GraphQL, gRPC, file transfer clients
│   ├── background/             # WorkManager background task service
│   └── ...                     # accessibility, analytics, logging, theming, localization, ...
├── examples/                   # Copyable pattern examples, browsable via the in-app Examples Hub
│   └── integrations/           # Demo screens for each core/network/integrations/* client
├── features/                   # Feature modules (see structure below)
│   ├── auth/                   # Login, registration, profile
│   ├── chat/                   # WebSocket chat feature
│   ├── tasks/                  # Local CRUD to-do list
│   ├── posts/                  # Paginated feed with offline cache
│   ├── notifications/          # In-app notification center
│   ├── survey/                 # Complex form handling
│   └── ...
├── l10n/                       # Localization delegate and helpers
├── main.dart                   # Entry point
└── ...

tool/
└── grpc_demo_server.dart       # Local reference gRPC server for the streaming example

test/                           # Mirrors lib/, unit + widget + golden tests
```

### Feature structure ("Screaming Architecture")
Each feature is a self-contained module:

```
feature_name/
├── domain/                     # 1. Innermost layer (pure Dart)
│   ├── entities/                #    Business objects (Equatable)
│   ├── repositories/            #    Abstract interfaces
│   └── usecases/                #    Business logic units
├── data/                       # 2. Outer layer (implementation)
│   ├── datasources/              #    API/DB clients
│   ├── models/                   #    JSON parsing & adapters
│   └── repositories/             #    Repository implementations
├── presentation/                # 3. UI layer (Flutter)
│   ├── providers/                 #    UI state management (Notifiers)
│   ├── screens/                   #    Widget pages
│   └── widgets/                   #    Reusable components
└── providers/                   # 4. DI layer (Riverpod)
    └── feature_providers.dart     #    Data layer dependency injection
```

---

## 🧪 Testing

```bash
# Run all tests
flutter test

# Update golden files after an intentional UI change
flutter test --update-goldens

# Run with coverage and an HTML report
./test_generator.sh
```

- **Unit tests** for use cases, repositories, and data sources (`mocktail` for mocking).
- **Widget tests** for reusable UI components.
- **Golden tests** for visual regression, with a small pixel-difference tolerance for cross-platform font rendering.

CI (`.github/workflows/flutter_ci_cd.yml`) runs `dart format --set-exit-if-changed`, `flutter analyze`, and `flutter test` on every push and pull request against `main`/`develop`.

---

## 🤝 Contributing

See [`docs/CONTRIBUTING.md`](docs/CONTRIBUTING.md) for the full guide. In short:

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a pull request

---

## 📄 License

Distributed under the MIT License. See [`LICENSE`](LICENSE) for the full text.
