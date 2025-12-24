/// Flutter Riverpod Clean Architecture Feature Generator
///
/// This Dart file can be used programmatically to generate new features
/// It mirrors the functionality of the generate_feature.sh script
/// but allows for more complex integration with IDE plugins or Flutter tools.
library;

import 'dart:io';

class FeatureGenerator {
  final String featureName;
  final bool withUi;
  final bool withTests;
  final bool withDocs;

  /// Feature name in PascalCase (e.g., UserProfile)
  late final String pascalCase;

  /// Feature name in camelCase (e.g., userProfile)
  late final String camelCase;

  FeatureGenerator({
    required this.featureName,
    this.withUi = true,
    this.withTests = true,
    this.withDocs = true,
  }) {
    pascalCase = _toPascalCase(featureName);
    camelCase = _toCamelCase(featureName);
  }

  /// Generate all files and folders for the feature
  Future<void> generate() async {
    stdout.writeln('Generating feature: $featureName');

    await _createDirectories();
    await _createFiles();

    stdout.writeln('Feature $featureName generated successfully!');
  }

  /// Create the directory structure for the feature
  Future<void> _createDirectories() async {
    final baseDir = 'lib/features/$featureName';

    // Data layer
    await _createDir('$baseDir/data/datasources');
    await _createDir('$baseDir/data/models');
    await _createDir('$baseDir/data/repositories');

    // Domain layer
    await _createDir('$baseDir/domain/entities');
    await _createDir('$baseDir/domain/repositories');
    await _createDir('$baseDir/domain/usecases');

    // Presentation layer (if enabled)
    if (withUi) {
      await _createDir('$baseDir/presentation/providers');
      await _createDir('$baseDir/presentation/screens');
      await _createDir('$baseDir/presentation/widgets');
    }

    // Providers folder
    await _createDir('$baseDir/providers');

    // Test directories (if enabled)
    if (withTests) {
      await _createDir('test/features/$featureName/data');
      await _createDir('test/features/$featureName/domain');
      if (withUi) {
        await _createDir('test/features/$featureName/presentation');
      }
    }

    // Documentation (if enabled)
    if (withDocs) {
      await _createDir('docs/features');
    }
  }

  /// Create all template files for the feature
  Future<void> _createFiles() async {
    final baseDir = 'lib/features/$featureName';

    // Data Layer Files
    await _createFile('$baseDir/data/models/${featureName}_model.dart', '''
// $pascalCase Model
// Implements the ${pascalCase}Entity with additional data layer functionality

import '../../domain/entities/${featureName}_entity.dart';

class ${pascalCase}Model extends ${pascalCase}Entity {
  ${pascalCase}Model({
    required String id,
    // Add required fields here
  }) : super(
          id: id,
          // Initialize super class with required fields
        );

  // Factory method to create a model from JSON
  factory ${pascalCase}Model.fromJson(Map<String, dynamic> json) {
    return ${pascalCase}Model(
      id: json['id'],
      // Map other fields from JSON
    );
  }

  // Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      // Add other fields here
    };
  }

  // Create a copy with modified fields
  ${pascalCase}Model copyWith({
    String? id,
    // Add other fields here
  }) {
    return ${pascalCase}Model(
      id: id ?? this.id,
      // Add other fields with null-coalescing
    );
  }
}
''');

    await _createFile(
      '$baseDir/data/datasources/${featureName}_remote_datasource.dart',
      '''
// $pascalCase Remote Data Source
// Handles API calls and external data sources

import '../models/${featureName}_model.dart';

abstract class ${pascalCase}RemoteDataSource {
  /// Fetches $camelCase data from the remote API
  ///
  /// Throws a [ServerException] for all error codes
  Future<List<${pascalCase}Model>> get${pascalCase}s();
  
  /// Fetches a specific $camelCase by ID
  Future<${pascalCase}Model?> get${pascalCase}ById(String id);
}

class ${pascalCase}RemoteDataSourceImpl implements ${pascalCase}RemoteDataSource {
  // Add your API client here
  // final ApiClient apiClient;
  
  ${pascalCase}RemoteDataSourceImpl(/*{required this.apiClient}*/);
  
  @override
  Future<List<${pascalCase}Model>> get${pascalCase}s() async {
    // TODO: Implement API call
    throw UnimplementedError();
  }
  
  @override
  Future<${pascalCase}Model?> get${pascalCase}ById(String id) async {
    // TODO: Implement API call
    throw UnimplementedError();
  }
}
''',
    );

    await _createFile(
      '$baseDir/data/datasources/${featureName}_local_datasource.dart',
      '''
// $pascalCase Local Data Source
// Handles local storage operations (SharedPreferences, SQLite, etc.)

import '../models/${featureName}_model.dart';

abstract class ${pascalCase}LocalDataSource {
  /// Gets cached $camelCase data
  ///
  /// Throws a [CacheException] if no cached data is present
  Future<List<${pascalCase}Model>> getCached${pascalCase}s();
  
  /// Caches $camelCase data
  Future<void> cache${pascalCase}s(List<${pascalCase}Model> ${camelCase}s);
}

class ${pascalCase}LocalDataSourceImpl implements ${pascalCase}LocalDataSource {
  // Add your storage client here
  // final SharedPreferences sharedPreferences;
  
  ${pascalCase}LocalDataSourceImpl(/*{required this.sharedPreferences}*/);
  
  @override
  Future<List<${pascalCase}Model>> getCached${pascalCase}s() async {
    // TODO: Implement local storage retrieval
    throw UnimplementedError();
  }
  
  @override
  Future<void> cache${pascalCase}s(List<${pascalCase}Model> ${camelCase}s) async {
    // TODO: Implement local storage caching
    throw UnimplementedError();
  }
}
''',
    );

    await _createFile(
      '$baseDir/data/repositories/${featureName}_repository_impl.dart',
      '''
// $pascalCase Repository Implementation
// Implements the repository interface from domain layer

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/${featureName}_entity.dart';
import '../../domain/repositories/${featureName}_repository.dart';
import '../datasources/${featureName}_local_datasource.dart';
import '../datasources/${featureName}_remote_datasource.dart';
import '../models/${featureName}_model.dart';

class ${pascalCase}RepositoryImpl implements ${pascalCase}Repository {
  final ${pascalCase}RemoteDataSource remoteDataSource;
  final ${pascalCase}LocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  
  ${pascalCase}RepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });
  
  @override
  Future<Either<Failure, List<${pascalCase}Entity>>> getAll${pascalCase}s() async {
    if (await networkInfo.isConnected) {
      try {
        final remote${pascalCase}s = await remoteDataSource.get${pascalCase}s();
        await localDataSource.cache${pascalCase}s(remote${pascalCase}s);
        return Right(remote${pascalCase}s);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      try {
        final local${pascalCase}s = await localDataSource.getCached${pascalCase}s();
        return Right(local${pascalCase}s);
      } on CacheException {
        return Left(CacheFailure());
      }
    }
  }
  
  @override
  Future<Either<Failure, ${pascalCase}Entity>> get${pascalCase}ById(String id) async {
    // TODO: Implement get by ID functionality
    throw UnimplementedError();
  }
}
''',
    );

    // Domain Layer Files
    await _createFile('$baseDir/domain/entities/${featureName}_entity.dart', '''
// $pascalCase Entity
// Core business entity, independent of data sources

import 'package:equatable/equatable.dart';

class ${pascalCase}Entity extends Equatable {
  final String id;
  // Add more fields here
  
  const ${pascalCase}Entity({
    required this.id,
    // Add required fields here
  });
  
  @override
  List<Object> get props => [id];
}
''');

    await _createFile(
      '$baseDir/domain/repositories/${featureName}_repository.dart',
      '''
// $pascalCase Repository Interface
// Define contract for data operations

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/${featureName}_entity.dart';

abstract class ${pascalCase}Repository {
  /// Gets all $camelCase entities
  ///
  /// Returns [Failure] or [List<${pascalCase}Entity>]
  Future<Either<Failure, List<${pascalCase}Entity>>> getAll${pascalCase}s();
  
  /// Gets a specific $camelCase entity by ID
  ///
  /// Returns [Failure] or [${pascalCase}Entity]
  Future<Either<Failure, ${pascalCase}Entity>> get${pascalCase}ById(String id);
}
''',
    );

    await _createFile(
      '$baseDir/domain/usecases/get_all_${featureName}s.dart',
      '''
// Get All ${pascalCase}s Use Case
// Business logic for retrieving all $camelCase entities

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/${featureName}_entity.dart';
import '../repositories/${featureName}_repository.dart';

class GetAll${pascalCase}s implements UseCase<List<${pascalCase}Entity>, NoParams> {
  final ${pascalCase}Repository repository;
  
  GetAll${pascalCase}s(this.repository);
  
  @override
  Future<Either<Failure, List<${pascalCase}Entity>>> call(NoParams params) {
    return repository.getAll${pascalCase}s();
  }
}
''',
    );

    await _createFile(
      '$baseDir/domain/usecases/get_${featureName}_by_id.dart',
      '''
// Get $pascalCase By ID Use Case
// Business logic for retrieving a specific $camelCase entity

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/${featureName}_entity.dart';
import '../repositories/${featureName}_repository.dart';

class Get${pascalCase}ById implements UseCase<${pascalCase}Entity, ${pascalCase}Params> {
  final ${pascalCase}Repository repository;
  
  Get${pascalCase}ById(this.repository);
  
  @override
  Future<Either<Failure, ${pascalCase}Entity>> call(${pascalCase}Params params) {
    return repository.get${pascalCase}ById(params.id);
  }
}

class ${pascalCase}Params extends Equatable {
  final String id;
  
  const ${pascalCase}Params({required this.id});
  
  @override
  List<Object> get props => [id];
}
''',
    );

    // Add UI files if requested
    if (withUi) {
      await _createUiFiles(baseDir);
    }

    // Provider Files
    await _createFile('$baseDir/providers/${featureName}_providers.dart', '''
// $pascalCase Providers
// Riverpod providers for the $featureName feature

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/network_info.dart';
import '../data/datasources/${featureName}_local_datasource.dart';
import '../data/datasources/${featureName}_remote_datasource.dart';
import '../data/repositories/${featureName}_repository_impl.dart';
import '../domain/entities/${featureName}_entity.dart';
import '../domain/repositories/${featureName}_repository.dart';
import '../domain/usecases/get_all_${featureName}s.dart';
import '../domain/usecases/get_${featureName}_by_id.dart';

// Data sources
final ${camelCase}RemoteDataSourceProvider = Provider<${pascalCase}RemoteDataSource>(
  (ref) => ${pascalCase}RemoteDataSourceImpl(
    // Add dependencies here
  ),
);

final ${camelCase}LocalDataSourceProvider = Provider<${pascalCase}LocalDataSource>(
  (ref) => ${pascalCase}LocalDataSourceImpl(
    // Add dependencies here
  ),
);

// Repository
final ${camelCase}RepositoryProvider = Provider<${pascalCase}Repository>(
  (ref) => ${pascalCase}RepositoryImpl(
    remoteDataSource: ref.read(${camelCase}RemoteDataSourceProvider),
    localDataSource: ref.read(${camelCase}LocalDataSourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  ),
);

// Use cases
final getAll${pascalCase}sProvider = Provider<GetAll${pascalCase}s>(
  (ref) => GetAll${pascalCase}s(ref.read(${camelCase}RepositoryProvider)),
);

final get${pascalCase}ByIdProvider = Provider<Get${pascalCase}ById>(
  (ref) => Get${pascalCase}ById(ref.read(${camelCase}RepositoryProvider)),
);

// State providers
final ${camelCase}ListProvider = FutureProvider<List<${pascalCase}Entity>>(
  (ref) async {
    final usecase = ref.read(getAll${pascalCase}sProvider);
    final result = await usecase(NoParams());
    
    return result.fold(
      (failure) => throw Exception(failure.toString()),
      (${camelCase}s) => ${camelCase}s,
    );
  },
);

final selected${pascalCase}IdProvider = StateProvider<String?>((ref) => null);

final selected${pascalCase}Provider = FutureProvider<${pascalCase}Entity?>((ref) async {
  final id = ref.watch(selected${pascalCase}IdProvider);
  if (id == null) return null;
  
  final usecase = ref.read(get${pascalCase}ByIdProvider);
  final result = await usecase(${pascalCase}Params(id: id));
  
  return result.fold(
    (failure) => throw Exception(failure.toString()),
    ($camelCase) => $camelCase,
  );
});
''');

    // Create test files if requested
    if (withTests) {
      await _createTestFiles();
    }

    // Create documentation if requested
    if (withDocs) {
      await _createDocFiles();
    }
  }

  /// Create presentation layer files
  Future<void> _createUiFiles(String baseDir) async {
    await _createFile(
      '$baseDir/presentation/screens/${featureName}_list_screen.dart',
      '''
// $pascalCase List Screen
// Screen that displays a list of $camelCase items

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/${featureName}_providers.dart';
import '../widgets/${featureName}_list_item.dart';

class ${pascalCase}ListScreen extends ConsumerWidget {
  const ${pascalCase}ListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ${camelCase}sAsync = ref.watch(${camelCase}ListProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('${pascalCase}s'),
      ),
      body: ${camelCase}sAsync.when(
        data: (${camelCase}s) => ListView.builder(
          itemCount: ${camelCase}s.length,
          itemBuilder: (context, index) => ${pascalCase}ListItem(
            $camelCase: ${camelCase}s[index],
            onTap: () {
              ref.read(selected${pascalCase}IdProvider.notifier).state = ${camelCase}s[index].id;
              // Navigate to detail screen
            },
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: \${error.toString()}'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Add new $camelCase action
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
''',
    );

    await _createFile(
      '$baseDir/presentation/screens/${featureName}_detail_screen.dart',
      '''
// $pascalCase Detail Screen
// Screen that displays details of a specific $camelCase

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/${featureName}_providers.dart';

class ${pascalCase}DetailScreen extends ConsumerWidget {
  const ${pascalCase}DetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ${camelCase}Async = ref.watch(selected${pascalCase}Provider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('$pascalCase Details'),
      ),
      body: ${camelCase}Async.when(
        data: ($camelCase) {
          if ($camelCase == null) {
            return const Center(child: Text('$pascalCase not found'));
          }
          
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ID: \${$camelCase.id}', style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 16),
                // Add more fields here
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('Error: \${error.toString()}'),
        ),
      ),
    );
  }
}
''',
    );

    await _createFile(
      '$baseDir/presentation/widgets/${featureName}_list_item.dart',
      '''
// $pascalCase List Item
// Widget that displays a single $camelCase in a list

import 'package:flutter/material.dart';

import '../../domain/entities/${featureName}_entity.dart';

class ${pascalCase}ListItem extends StatelessWidget {
  final ${pascalCase}Entity $camelCase;
  final VoidCallback onTap;
  
  const ${pascalCase}ListItem({
    Key? key,
    required this.$camelCase,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text('$pascalCase \${$camelCase.id}'),
        // Add more details here
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
''',
    );

    await _createFile(
      '$baseDir/presentation/providers/${featureName}_ui_providers.dart',
      '''
// $pascalCase UI Providers
// Riverpod providers specific to UI state

import 'package:flutter_riverpod/flutter_riverpod.dart';

// UI state providers
final ${camelCase}FilterProvider = StateProvider<String>((ref) => '');

final ${camelCase}SortOrderProvider = StateProvider<SortOrder>((ref) => SortOrder.asc);

enum SortOrder { asc, desc }
''',
    );
  }

  /// Create test files
  Future<void> _createTestFiles() async {
    // TODO: Implement test files creation
    // This would mirror the shell script's test file creation
  }

  /// Create documentation files
  Future<void> _createDocFiles() async {
    // TODO: Implement documentation file creation
    // This would mirror the shell script's documentation file creation
  }

  /// Helper method to create a directory and its parents if they don't exist
  Future<void> _createDir(String path) async {
    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
      stdout.writeln('Created directory: $path');
    }
  }

  /// Helper method to create a file with the given content
  Future<void> _createFile(String path, String content) async {
    final file = File(path);
    await file.writeAsString(content);
    stdout.writeln('Created file: $path');
  }

  /// Convert snake_case to PascalCase
  String _toPascalCase(String input) {
    return input
        .split('_')
        .map(
          (word) => word.isEmpty
              ? ''
              : word[0].toUpperCase() + word.substring(1).toLowerCase(),
        )
        .join('');
  }

  /// Convert snake_case to camelCase
  String _toCamelCase(String input) {
    final pascal = _toPascalCase(input);
    return pascal.isEmpty ? '' : pascal[0].toLowerCase() + pascal.substring(1);
  }
}

void main(List<String> args) {
  // Example usage:
  // dart run lib/core/cli/feature_generator.dart user_profile
  if (args.isEmpty) {
    stdout.writeln('Please provide a feature name in snake_case format.');
    return;
  }

  final generator = FeatureGenerator(featureName: args.first);
  generator.generate();
}
