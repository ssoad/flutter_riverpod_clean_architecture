# Flutter Riverpod Clean Architecture

![Flutter](https://img.shields.io/badge/Flutter-3.7+-02569B.svg?style=flat&logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.0+-0175C2.svg?style=flat&logo=dart)
![Riverpod](https://img.shields.io/badge/Riverpod-2.0+-0175C2.svg?style=flat)
![License](https://img.shields.io/badge/License-MIT-purple.svg)

A production-ready Flutter project template implementing Clean Architecture principles with Riverpod for state management. This template provides a solid foundation for building scalable, maintainable, and testable Flutter applications.

<p align="center">
  <img src="https://flutter.dev/assets/images/shared/brand/flutter/logo/flutter-lockup.png" alt="Flutter" height="100"/>
</p>

## 🌟 Key Features

- **Clean Architecture** — Domain, data, and presentation layers separation
- **Riverpod State Management** — Powerful, testable state management
- **Multi-language Support** — Full internationalization with language switching
- **Advanced Caching** — Memory and disk caching with type-safety
- **Biometric Authentication** — Secure fingerprint and face recognition
- **Feature Flags** — A/B testing and staged rollouts
- **Analytics Integration** — Flexible event tracking
- **Push Notifications** — Deep linking and background handling
- **Accessibility** — Screen reader and dynamic text support
- **Offline-First** — Work seamlessly with or without connection
- **CI/CD Ready** — Automated workflows with GitHub Actions

[See All Features](docs/FEATURES.md)

## � Documentation

- [Architecture Guide](https://ssoad.github.io/flutter_riverpod_clean_architecture/architecture.html) - Project structure and principles
- [Utility Tools](docs/TOOLS.md) - CLI tools for development
- [Feature Documentation](docs/FEATURES.md) - Core features explained
- [Code Examples](docs/EXAMPLES.md) - Usage examples
- [Online Documentation](https://ssoad.github.io/flutter_riverpod_clean_architecture/) - Complete reference

## 🏗️ Project Structure

```plaintext
lib/
├── core/                       # Core shared functionality
├── features/                   # Feature modules
│   └── feature_name/           # Individual feature
│       ├── data/               # Data layer (repositories, sources)
│       ├── domain/             # Domain layer (entities, use cases)
│       └── presentation/       # UI layer (screens, providers)
├── examples/                   # Example implementations
└── main.dart                   # Application entry point
```

[Full Architecture Overview](docs/ARCHITECTURE.md)

## 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/ssoad/flutter_riverpod_clean_architecture.git

# Navigate to the project directory
cd flutter_riverpod_clean_architecture

# Install dependencies
flutter pub get

# Run the app
flutter run
```

[Detailed Getting Started Guide](docs/GETTING_STARTED.md)

## 🧑‍💻 Adding New Features

This template provides two approaches to creating new features: automated generation with our powerful CLI tools or manual setup following Clean Architecture principles.

### Method 1: Using the Feature Generator Tool (Recommended)

The fastest way to create a new feature is using our built-in feature generator:

```bash
./generate_feature.sh --name user_profile
```

This will automatically:

1. Create the complete folder structure following Clean Architecture
2. Generate data, domain, and presentation layer templates
3. Add Riverpod providers with proper dependency injection
4. Create test file templates for each component
5. Add basic documentation for the feature

#### Feature Generator Options

```bash
# Basic usage - creates a complete feature with all layers
./generate_feature.sh --name user_profile

# Create a feature without UI (for background services)
./generate_feature.sh --name analytics_service --no-ui

# Create a feature without repository pattern (simplified structure)
./generate_feature.sh --name theme_switcher --no-repository

# Create a UI-only feature (for shared components)
./generate_feature.sh --name custom_button --ui-only

# Create a service-only feature (for utility services)
./generate_feature.sh --name logger --service-only

# Create data-only feature without tests
./generate_feature.sh --name local_storage --no-ui --no-tests

# Minimal feature without UI, tests or docs (for utilities)
./generate_feature.sh --name formatter --no-ui --no-tests --no-docs

# See all available options
./generate_feature.sh --help
```

#### Generated Structure

The feature generator creates different structures based on the options you choose:

##### Full Clean Architecture Structure (Default)

```plaintext
lib/features/feature_name/
├── data/
│   ├── datasources/
│   │   ├── feature_name_remote_datasource.dart
│   │   └── feature_name_local_datasource.dart
│   ├── models/
│   │   └── feature_name_model.dart
│   └── repositories/
│       └── feature_name_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── feature_name_entity.dart
│   ├── repositories/
│   │   └── feature_name_repository.dart
│   └── usecases/
│       ├── get_all_feature_names.dart
│       └── get_feature_name_by_id.dart
├── presentation/ (optional with --no-ui flag)
│   ├── providers/
│   │   └── feature_name_ui_providers.dart
│   ├── screens/
│   │   ├── feature_name_list_screen.dart
│   │   └── feature_name_detail_screen.dart
│   └── widgets/
│       └── feature_name_list_item.dart
└── providers/
    └── feature_name_providers.dart
```

##### No-Repository Structure (with --no-repository flag)

```plaintext
lib/features/feature_name/
├── models/
│   └── feature_name_model.dart
├── presentation/ (optional with --no-ui flag)
│   ├── providers/
│   │   └── feature_name_ui_providers.dart
│   ├── screens/
│   │   └── feature_name_screen.dart
│   └── widgets/
│       └── feature_name_widget.dart
└── providers/
    └── feature_name_providers.dart
```

##### UI-Only Structure (with --ui-only flag)

```plaintext
lib/features/feature_name/
├── models/
│   └── feature_name_model.dart
├── presentation/
│   ├── providers/
│   │   └── feature_name_ui_providers.dart
│   └── widgets/
│       └── feature_name_widget.dart
└── providers/
    └── feature_name_providers.dart
```

##### Service-Only Structure (with --service-only flag)

```plaintext
lib/features/feature_name/
├── models/
│   └── feature_name_model.dart
├── services/
│   └── feature_name_service.dart
└── providers/
    └── feature_name_providers.dart
```

#### Using the Dart Feature Generator

For programmatic usage in your own tools or scripts, you can also use the included Dart class:

```dart
// Import the generator
import 'package:flutter_riverpod_clean_architecture/core/cli/feature_generator.dart';

// Create and run the generator
final generator = FeatureGenerator(
  featureName: 'user_profile',
  withUi: true,     // Include presentation layer
  withTests: true,  // Generate test files
  withDocs: true    // Create documentation
);

// Generate all files and folders
await generator.generate();
```

### Method 2: Manual Feature Creation

If you prefer to create features manually, follow this structure:

1. **Create the feature directory structure**:

```plaintext
lib/features/feature_name/
├── data/
│   ├── datasources/       # Remote and local data sources
│   ├── models/            # DTOs and model classes
│   └── repositories/      # Repository implementations
├── domain/
│   ├── entities/          # Business entities
│   ├── repositories/      # Repository interfaces
│   └── usecases/          # Business use cases
├── presentation/
│   ├── providers/         # UI-specific providers
│   ├── screens/           # Page/screen widgets
│   └── widgets/           # Reusable UI components
└── providers/             # Core feature providers
```

Then implement each component:

**Step 1:** Define your entities in `domain/entities/` - these are your core business models.

**Step 2:** Create repository interfaces in `domain/repositories/` that define how data will be accessed.

**Step 3:** Implement use cases in `domain/usecases/` for each business operation.

**Step 4:** Create data models in `data/models/` that extend your entities with data layer functionality.

**Step 5:** Implement repositories in `data/repositories/` that fulfill your repository interfaces.

**Step 6:** Create Riverpod providers in `providers/feature_providers.dart`:

```dart
// Data source providers
final userRemoteDataSourceProvider = Provider<UserRemoteDataSource>((ref) => 
  UserRemoteDataSourceImpl(client: ref.read(httpClientProvider)));

// Repository providers
final userRepositoryProvider = Provider<UserRepository>((ref) => 
  UserRepositoryImpl(
    remoteDataSource: ref.read(userRemoteDataSourceProvider),
    localDataSource: ref.read(userLocalDataSourceProvider),
  ));

// Use case providers
final getUserProfileProvider = Provider((ref) => 
  GetUserProfile(ref.read(userRepositoryProvider)));

// State providers
final userProfileProvider = FutureProvider<UserEntity>((ref) async {
  final usecase = ref.read(getUserProfileProvider);
  final result = await usecase(NoParams());
  
  return result.fold(
    (failure) => throw Exception(failure.toString()),
    (user) => user,
  );
});
```

**Step 7:** Create UI components in the presentation layer that consume your providers.

**Step 8:** Write tests for each layer in the corresponding test directory.

### Feature Organization Best Practices

- Keep feature code isolated from other features
- Use dependency injection via Riverpod providers
- Follow the unidirectional data flow: UI → Use Case → Repository → Data Source
- Write tests for each layer, especially use cases and repositories
- Document feature usage and key integration points

### Example: Complete User Profile Feature

Here's a comprehensive example of implementing a user profile feature using Clean Architecture:

#### 1. Domain Layer

```dart
// domain/entities/user_entity.dart
class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? profileImage;
  final DateTime lastActive;
  
  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.profileImage,
    required this.lastActive,
  });
  
  @override
  List<Object?> get props => [id, name, email, profileImage, lastActive];
}

// domain/repositories/user_repository.dart
abstract class UserRepository {
  /// Get the current user's profile
  Future<Either<Failure, UserEntity>> getUserProfile();
  
  /// Update the user's profile information
  Future<Either<Failure, void>> updateUserProfile(UserEntity user);
  
  /// Update just the profile image
  Future<Either<Failure, String>> updateProfileImage(File imageFile);
}

// domain/usecases/get_user_profile.dart
class GetUserProfile implements UseCase<UserEntity, NoParams> {
  final UserRepository repository;
  
  GetUserProfile(this.repository);
  
  @override
  Future<Either<Failure, UserEntity>> call(NoParams params) {
    return repository.getUserProfile();
  }
}

// domain/usecases/update_user_profile.dart
class UpdateUserProfile implements UseCase<void, UpdateUserParams> {
  final UserRepository repository;
  
  UpdateUserProfile(this.repository);
  
  @override
  Future<Either<Failure, void>> call(UpdateUserParams params) {
    return repository.updateUserProfile(params.user);
  }
}

class UpdateUserParams extends Equatable {
  final UserEntity user;
  
  const UpdateUserParams({required this.user});
  
  @override
  List<Object> get props => [user];
}
```

#### 2. Data Layer

```dart
// data/models/user_model.dart
class UserModel extends UserEntity {
  UserModel({
    required String id,
    required String name,
    required String email,
    String? profileImage,
    required DateTime lastActive,
  }) : super(
          id: id,
          name: name,
          email: email,
          profileImage: profileImage,
          lastActive: lastActive,
        );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      profileImage: json['profile_image'],
      lastActive: DateTime.parse(json['last_active']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'profile_image': profileImage,
      'last_active': lastActive.toIso8601String(),
    };
  }
  
  // Convert entity to model
  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      profileImage: entity.profileImage,
      lastActive: entity.lastActive,
    );
  }
}

// data/datasources/user_remote_datasource.dart
class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final http.Client client;
  final AuthService authService;
  
  UserRemoteDataSourceImpl({
    required this.client,
    required this.authService,
  });
  
  @override
  Future<UserModel> getUserProfile() async {
    final token = await authService.getToken();
    
    final response = await client.get(
      Uri.parse('${ApiConfig.baseUrl}/user/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    
    if (response.statusCode == 200) {
      return UserModel.fromJson(json.decode(response.body));
    } else {
      throw ServerException(
        message: 'Failed to load profile',
        statusCode: response.statusCode,
      );
    }
  }
  
  @override
  Future<void> updateUserProfile(UserModel userModel) async {
    final token = await authService.getToken();
    
    final response = await client.put(
      Uri.parse('${ApiConfig.baseUrl}/user/profile'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: json.encode(userModel.toJson()),
    );
    
    if (response.statusCode != 200) {
      throw ServerException(
        message: 'Failed to update profile',
        statusCode: response.statusCode,
      );
    }
  }
}

// data/repositories/user_repository_impl.dart
class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;
  final UserLocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  
  UserRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });
  
  @override
  Future<Either<Failure, UserEntity>> getUserProfile() async {
    if (await networkInfo.isConnected) {
      try {
        final remoteUser = await remoteDataSource.getUserProfile();
        localDataSource.cacheUserProfile(remoteUser);
        return Right(remoteUser);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      try {
        final localUser = await localDataSource.getCachedUserProfile();
        return Right(localUser);
      } on CacheException {
        return Left(CacheFailure(message: 'No cached profile available'));
      }
    }
  }
  
  @override
  Future<Either<Failure, void>> updateUserProfile(UserEntity user) async {
    if (await networkInfo.isConnected) {
      try {
        final userModel = UserModel.fromEntity(user);
        await remoteDataSource.updateUserProfile(userModel);
        await localDataSource.cacheUserProfile(userModel);
        return const Right(null);
      } on ServerException catch (e) {
        return Left(ServerFailure(message: e.message));
      }
    } else {
      return Left(NetworkFailure(message: 'No internet connection'));
    }
  }
}
```

#### 3. Providers and State Management

```dart
// providers/user_providers.dart
final userRemoteDataSourceProvider = Provider<UserRemoteDataSource>((ref) {
  final client = ref.read(httpClientProvider);
  final authService = ref.read(authServiceProvider);
  return UserRemoteDataSourceImpl(
    client: client,
    authService: authService,
  );
});

final userLocalDataSourceProvider = Provider<UserLocalDataSource>((ref) {
  final storage = ref.read(secureStorageProvider);
  return UserLocalDataSourceImpl(storage: storage);
});

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepositoryImpl(
    remoteDataSource: ref.read(userRemoteDataSourceProvider),
    localDataSource: ref.read(userLocalDataSourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  );
});

final getUserProfileProvider = Provider<GetUserProfile>((ref) {
  return GetUserProfile(ref.read(userRepositoryProvider));
});

final updateUserProfileProvider = Provider<UpdateUserProfile>((ref) {
  return UpdateUserProfile(ref.read(userRepositoryProvider));
});

// State provider for the user profile
final userProfileProvider = FutureProvider<UserEntity>((ref) async {
  final usecase = ref.read(getUserProfileProvider);
  final result = await usecase(NoParams());
  
  return result.fold(
    (failure) => throw Exception(failure.message),
    (user) => user,
  );
});

// State provider for profile editing
final userProfileEditingProvider = StateNotifierProvider<UserProfileNotifier, AsyncValue<UserEntity?>>((ref) {
  return UserProfileNotifier(ref);
});

class UserProfileNotifier extends StateNotifier<AsyncValue<UserEntity?>> {
  final Ref ref;
  
  UserProfileNotifier(this.ref) : super(const AsyncValue.loading()) {
    _initUser();
  }
  
  Future<void> _initUser() async {
    final currentUser = await ref.read(userProfileProvider.future);
    state = AsyncValue.data(currentUser);
  }
  
  Future<void> updateProfile({
    String? name,
    String? email,
  }) async {
    if (state.value == null) return;
    
    state = const AsyncValue.loading();
    
    final updatedUser = UserEntity(
      id: state.value!.id,
      name: name ?? state.value!.name,
      email: email ?? state.value!.email,
      profileImage: state.value!.profileImage,
      lastActive: DateTime.now(),
    );
    
    final result = await ref.read(updateUserProfileProvider).call(
      UpdateUserParams(user: updatedUser)
    );
    
    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (_) => AsyncValue.data(updatedUser),
    );
    
    // Invalidate the main user provider to fetch fresh data
    ref.invalidate(userProfileProvider);
  }
}
```

#### 4. Presentation Layer

```dart
// presentation/screens/profile_screen.dart
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const EditProfileScreen(),
              ),
            ),
          )
        ],
      ),
      body: userAsync.when(
        data: (user) => ProfileContent(user: user),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Error: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(userProfileProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileContent extends StatelessWidget {
  final UserEntity user;
  
  const ProfileContent({Key? key, required this.user}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Center(
          child: ProfileAvatar(
            imageUrl: user.profileImage,
            name: user.name,
            radius: 50,
          ),
        ),
        const SizedBox(height: 24),
        ProfileInfoCard(
          title: 'Personal Information',
          items: [
            ProfileInfoItem(label: 'Name', value: user.name),
            ProfileInfoItem(label: 'Email', value: user.email),
            ProfileInfoItem(
              label: 'Last Active', 
              value: DateFormat('MMM d, yyyy').format(user.lastActive),
            ),
          ],
        ),
      ],
    );
  }
}

// presentation/screens/edit_profile_screen.dart
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);
  
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    
    // Initialize with current values
    final currentUser = ref.read(userProfileProvider).value;
    if (currentUser != null) {
      _nameController.text = currentUser.name;
      _emailController.text = currentUser.email;
    }
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final editingState = ref.watch(userProfileEditingProvider);
    
    ref.listen<AsyncValue<UserEntity?>>(
      userProfileEditingProvider, 
      (_, next) {
        if (next.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${next.error}')),
          );
        } else if (!next.isLoading && !next.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile updated!')),
          );
          Navigator.of(context).pop();
        }
      }
    );
    
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: editingState.isLoading
                    ? null
                    : () => _saveChanges(),
                child: editingState.isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Save Changes'),
              ),
            )
          ],
        ),
      ),
    );
  }
  
  void _saveChanges() {
    ref.read(userProfileEditingProvider.notifier).updateProfile(
      name: _nameController.text,
      email: _emailController.text,
    );
  }
}
```

</details>

## 🛠️ Development Tools

The template includes powerful command-line tools to streamline your development workflow:

| | | |
|:--:|:--:|:--:|
| ![App Renamer](https://img.shields.io/badge/-%F0%9F%93%B1%20App%20Renamer-6366f1?style=for-the-badge&logoColor=white) | ![Feature Generator](https://img.shields.io/badge/-%E2%9A%A1%20Feature%20Generator-f43f5e?style=for-the-badge&logoColor=white) | ![Language Generator](https://img.shields.io/badge/-%F0%9F%8C%90%20Language%20Generator-22c55e?style=for-the-badge&logoColor=white) |
| Update app name and package IDs across all platforms | Scaffold new features with clean architecture | Add and manage translations |
| ![Test Generator](https://img.shields.io/badge/-%F0%9F%A7%AA%20Test%20Generator-d946ef?style=for-the-badge&logoColor=white) | ![Feature Creator](https://img.shields.io/badge/-%F0%9F%9B%A0%EF%B8%8F%20Feature%20Creator-ec4899?style=for-the-badge&logoColor=white) | ![CI/CD Tools](https://img.shields.io/badge/-%F0%9F%94%84%20CI/CD%20Tools-0ea5e9?style=for-the-badge&logoColor=white) |
| Create test scaffolds for features | Create new features with boilerplate code | Automate build and deployment |

[Complete Development Tools Documentation](https://ssoad.github.io/flutter_riverpod_clean_architecture/tools.html)

### Feature Generator

Generate complete feature modules with all Clean Architecture layers:

```bash
# Create a new feature with all layers
./generate_feature.sh --name feature_name

# Create a feature without UI layer
./generate_feature.sh --name data_service --no-ui

# Create a minimal feature
./generate_feature.sh --name analytics_tracker --no-ui --no-tests --no-docs
```

The Feature Generator creates a fully structured feature with:

- **Data layer**: Models, remote/local data sources, repository implementation
- **Domain layer**: Entities, repository interfaces, use cases
- **Presentation layer**: UI screens, widgets, Riverpod providers
- **Tests**: Unit tests for each layer
- **Documentation**: Feature usage guide

You can also use the programmatic API in your own tools:

```dart
final generator = FeatureGenerator(
  featureName: 'user_profile',
  withUi: true,
  withTests: true,
  withDocs: true
);
await generator.generate();
```

#### How the Feature Generator Works

Behind the scenes, the feature generator:

1. Creates the directory structure for data, domain, and presentation layers
2. Generates properly formatted entity, repository, and model classes
3. Sets up the Riverpod provider dependency chain for dependency injection
4. Creates boilerplate for remote and local data sources
5. Implements use cases with Either/Failure error handling
6. Adds UI screens with proper state management (if UI enabled)
7. Generates test files with proper mock setup (if tests enabled)
8. Creates markdown documentation with usage examples (if docs enabled)

All generated code follows the project's coding standards and naming conventions, ensuring consistency across features.

### Test Generator

Automate testing workflows with coverage reporting:

```bash
# Run all tests with coverage report
./test_generator.sh

# Run tests for a specific feature
./test_generator.sh --target test/features/auth/

# Run tests without coverage
./test_generator.sh --no-coverage

# Run tests without generating a report
./test_generator.sh --no-report
```

#### Test Generator Options

| Option | Description |
|--------|-------------|
| `--target <path>` | Run tests only in the specified path |
| `--no-coverage` | Run tests without collecting coverage data |
| `--no-report` | Don't generate HTML coverage report |
| `--help` | Display help information |

The test generator:

- Runs Flutter tests with proper configuration
- Generates HTML coverage reports
- Opens reports in your default browser
- Provides CLI options for customizing test runs

## 🔄 Effective Feature Development Workflow

This template is designed to provide a smooth, productive workflow for developing new features. Here's an optimal approach for adding functionality to your app:

### 1. Generate the Feature Scaffold

Start by generating a new feature with all necessary layers:

```bash
./generate_feature.sh --name product_catalog
```

This creates all required files and folders with proper organization.

### 2. Define the Core Business Logic

Next, work on the domain layer to define what your feature needs to accomplish:

1. Update the entity in `domain/entities/product_catalog_entity.dart`
2. Define repository methods in `domain/repositories/product_catalog_repository.dart`
3. Create use cases for each business operation

Focus on defining the contract before implementation, thinking in terms of business requirements.

### 3. Implement Data Sources

Now implement where your data comes from:

1. Update the data model in `data/models/product_catalog_model.dart`
2. Implement the remote data source for API communication
3. Implement the local data source for caching/persistence
4. Complete the repository implementation that orchestrates the data sources

### 4. Connect the UI

With the data flow working, build your user interface:

1. Create the necessary screen layouts in the presentation layer
2. Connect screens to providers for reactive state updates
3. Implement error handling and loading states
4. Add any specific UI providers needed for presentation state

### 5. Write Tests

Use the test generator to create and run tests for your feature:

```bash
# Run tests for your specific feature
./test_generator.sh --target test/features/product_catalog/

# Generate coverage report
./test_generator.sh
```

By following this workflow, you maintain a clear separation of concerns while ensuring your features are fully tested and align with Clean Architecture principles.

## 🔧 CLI Tools Reference

The template includes several command-line tools to accelerate development. Here's a quick reference:

| Tool | Description | Usage |
|------|-------------|-------|
| `generate_feature.sh` | Creates a new feature with Clean Architecture structure | `./generate_feature.sh --name feature_name [options]` |
| `test_generator.sh` | Runs tests with coverage reporting | `./test_generator.sh [--target path] [options]` |
| `generate_language.sh` | Adds translations for internationalization | `./generate_language.sh --lang es [options]` |
| `rename_app.sh` | Updates app name and bundle identifiers | `./rename_app.sh --name "New App Name" --bundle com.company.app` |
| `create_feature.sh` | Alternative feature creator with different options | `./create_feature.sh feature_name` |

To learn more about each tool's options, run any script with the `--help` flag:

```bash
./generate_feature.sh --help
```

These tools follow consistent conventions to make development easier and faster while maintaining architectural integrity.

### Creating Features Without Repositories

Not all features require the full repository pattern, especially for simpler UI components, utilities, or service wrappers. The current generator script creates the full Clean Architecture structure, but you can:

#### Creating Simplified Features Manually

#### Manual Simple Feature Creation

For very simple features like UI components or utilities, you can create a more direct structure:

```plaintext
lib/features/feature_name/
├── models/              # Simple data models if needed
├── providers/           # State providers
└── presentation/
    ├── screens/         # UI screens
    └── widgets/         # UI components
```

#### Example: Simple Theme Switcher Feature

```dart
// lib/features/theme_switcher/models/theme_config.dart
class ThemeConfig {
  final String name;
  final Color primaryColor;
  final Color accentColor;
  final bool isDark;
  
  const ThemeConfig({
    required this.name,
    required this.primaryColor,
    required this.accentColor,
    required this.isDark,
  });
  
  // Create predefined themes
  static const light = ThemeConfig(
    name: 'Light',
    primaryColor: Colors.blue,
    accentColor: Colors.blueAccent,
    isDark: false,
  );
  
  static const dark = ThemeConfig(
    name: 'Dark',
    primaryColor: Colors.indigo,
    accentColor: Colors.indigoAccent,
    isDark: true,
  );
}

// lib/features/theme_switcher/providers/theme_providers.dart
final availableThemesProvider = Provider<List<ThemeConfig>>((ref) {
  return [ThemeConfig.light, ThemeConfig.dark];
});

final currentThemeProvider = StateNotifierProvider<ThemeNotifier, ThemeConfig>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeConfig> {
  ThemeNotifier() : super(ThemeConfig.light);
  
  void setTheme(ThemeConfig theme) {
    state = theme;
    // Save preference if needed
  }
  
  void toggleTheme() {
    state = state.isDark ? ThemeConfig.light : ThemeConfig.dark;
  }
}

// lib/features/theme_switcher/presentation/widgets/theme_toggle_button.dart
class ThemeToggleButton extends ConsumerWidget {
  const ThemeToggleButton({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = ref.watch(currentThemeProvider).isDark;
    
    return IconButton(
      icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
      onPressed: () {
        ref.read(currentThemeProvider.notifier).toggleTheme();
      },
      tooltip: isDark ? 'Switch to light mode' : 'Switch to dark mode',
    );
  }
}
```


