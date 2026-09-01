# Flutter Riverpod Clean Architecture Template

![Flutter](https://img.shields.io/badge/Flutter-3.7+-02569B?style=flat&logo=flutter)
![Riverpod](https://img.shields.io/badge/Riverpod-2.0+-0175C2?style=flat)
![Architecture](https://img.shields.io/badge/Architecture-Clean-success)
![License](https://img.shields.io/badge/License-MIT-purple)

A production-ready, highly scalable Flutter template designed for modern application development. This project implements strictly typed **Clean Architecture** with **Riverpod** for state management and dependency injection.

---

## 🚀 Key Features

### Core Architecture
- **Strict Clean Architecture**: Clear separation of Domain, Data, and Presentation layers.
- **Functional Error Handling**: Uses `fpdart` for type-safe error handling (`Either<Failure, T>`).
- **Riverpod 2.0**: Modern provider patterns with `Notifier` and `AsyncNotifier`.
- **Framework Independence**: Domain and Data layers are testable without Flutter dependencies.

### Developer Experience
- **Feature Generator**: Create complete features in seconds (`./generate_feature.sh`).
- **Strict Linting**: Zero-tolerance analysis options for code quality.
- **CI/CD Ready**: GitHub Actions workflows for automated testing and analysis.
- **Type Safety**: Full null-safety and strict typing throughout.

### Advanced Capabilities
- **Real-Time Features**: WebSocket integration example (Chat).
- **Complex Forms**: Advanced form handling with validation (Survey).
- **Offline First**: Local storage strategies with Hive/SharedPreferences.
- **Secure Storage**: Encrypted credential storage.
- **Biometric Auth**: FaceID and Fingerprint integration.
- **Localization**: Built-in multi-language support.

---

## 🧭 Examples Hub - start here for any requirement

This template isn't just Clean Architecture boilerplate - it ships small,
copyable examples of the integration and platform patterns most apps need
sooner or later, so you can pick the one your requirement matches and adapt
it instead of researching it from scratch. Run the app, sign in, and tap
**Examples** (home screen tile, or the compass icon in the bottom nav) to
browse all of them from `lib/examples/examples_hub_screen.dart`.

| Pattern | Where | Notes |
|---|---|---|
| REST | `features/posts/` (uses `core/network/api_client.dart`) | Repository pattern over Dio, with offline cache fallback |
| WebSocket | `core/network/integrations/websocket_client.dart` | Connect/send/receive/reconnect; demoed against a public echo server |
| Webhook (send) | `core/network/integrations/webhook_sender.dart` + `webhook_signature.dart` | HMAC-SHA256 signed outbound POST |
| Webhook (receive) | `core/network/integrations/local_webhook_receiver.dart` | Local-only `dart:io HttpServer` for dev/testing; not available on web |
| GraphQL | `core/network/integrations/graphql_client.dart` | Thin Dio wrapper - a query and a mutation, no extra state-management framework |
| gRPC | `core/network/integrations/grpc/` | Real `protoc`-generated client for a unary + a server-streaming call; not available on web. Run `dart run tool/grpc_demo_server.dart` locally to exercise the streaming call end-to-end |
| Background tasks | `core/background/background_task_service.dart` | `workmanager`: one-off and periodic scheduled work, survives the app being closed |
| Biometric auth | `core/auth/local_biometric_service.dart` + `examples/biometrics_demo.dart` | Fingerprint/Face ID gating app access and sensitive transactions |
| File upload/download | `core/network/integrations/file_transfer_service.dart` | Multipart upload and download, both with progress callbacks; not available on web |
| Feature flags, analytics, notifications, images, logging, accessibility, app updates, offline sync, app reviews | `examples/advanced_features_showcase.dart` | One screen touring the rest of `core/` |

A few of these (the local webhook receiver, gRPC, and file transfer to disk)
need a real filesystem or raw TCP socket and are intentionally unavailable
on Flutter Web - each says so in its own screen and doc comment rather than
failing silently.

---

## 📚 Documentation

- [**Architecture Guide**](docs/ARCHITECTURE_GUIDE.md): Deep dive into the project structure.
- [**Coding Standards**](docs/CODING_STANDARDS.md): Rules and patterns used in this project.
- [**Feature Guide**](docs/FEATURES.md): Documentation for core features.
- [**CLI Tools**](docs/TOOLS.md): How to use the generator scripts.

---

## 🛠️ Quick Start

### 1. Prerequisites
- Flutter SDK (3.35+, latest stable recommended)
- Dart SDK (3.10+)

### 2. Installation
```bash
# Clone the repository
git clone https://github.com/ssoad/flutter_riverpod_clean_architecture.git

# Install dependencies
flutter pub get

# Generate code (Freezed, Riverpod, etc.)
dart run build_runner build --delete-conflicting-outputs
```

### 3. Running the App
```bash
# Development
flutter run

# Production Build
flutter build apk --release
```

---

## ⚡ Generating New Features

Don't write boilerplate manually! Use the included generator script:

```bash
# Generate a full feature with UI, Domain, and Data layers
./generate_feature.sh --name my_awesome_feature
```

This creates:
- `domain/entities/`, `repositories/`, `usecases/`
- `data/models/`, `datasources/`, `repositories/`
- `presentation/providers/`, `screens/`, `widgets/`
- `providers/` (DI configuration)
- Unit tests for all layers

## 📦 App Renaming

Start your project with the right identity! Use our renaming utility:

```bash
./rename_app.sh --app-name "My Super App" --package-name com.company.superapp
```

This updates:
- Android: `AndroidManifest.xml`, `build.gradle`, Kotlin files
- iOS: `Info.plist`, Project files
- macOS, Windows, Linux Build files
- Dart package name & imports

## 🎨 Icon Generation

Generate native app icons for all platforms in one command:

1. Place your icon file (1024x1024) at `assets/icon/app_icon.png`.
2. Run the generator script:

```bash
./generate_icons.sh
```

This updates:
- Android `mipmap` resources
- iOS `Assets.xcassets`
- Web `manifest.json` and icons
- Windows/macOS/Linux icon files

---

## 🏗️ Project Structure

```
lib/
├── core/                       # Shared kernel (Errors, Network, Utils)
├── features/                   # Feature modules
│   ├── auth/                   # Authentication Feature
│   ├── chat/                   # WebSocket Chat Feature
│   ├── survey/                 # Complex Form Feature
│   └── ...
├── main.dart                   # Entry point
└── ...
```

### Feature Structure (The "Screaming Architecture")
Each feature is a self-contained module:

```
feature_name/
├── domain/                     # 1. Innermost Layer (Pure Dart)
│   ├── entities/               # Business objects (Equatable)
│   ├── repositories/           # Abstract interfaces
│   └── usecases/               # Business logic units
├── data/                       # 2. Outer Layer (Implementation)
│   ├── datasources/            # API/DB clients
│   ├── models/                 # JSON parsing & Adapters
│   └── repositories/           # Repository implementations
├── presentation/               # 3. UI Layer (Flutter)
│   ├── providers/              # UI State Management (Notifiers)
│   ├── screens/                # Widget pages
│   └── widgets/                # Reusable components
└── providers/                  # 4. DI Layer (Riverpod)
    └── feature_providers.dart  # Data layer dependency injection
```

---

## 🧪 Testing

We use a comprehensive testing strategy:

- **Unit Tests**: For Use Cases, Repositories, and Data Sources.
- **Widget Tests**: For reusable UI components.
- **Golden Tests**: For visual regression testing of screens.

```bash
# Run all tests
flutter test

# Update Golden files
flutter test --update-goldens
```

---

## 🤝 Contributing

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 📄 License

Distributed under the MIT License. See `LICENSE` for more information.
