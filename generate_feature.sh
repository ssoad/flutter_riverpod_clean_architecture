#!/bin/bash

# Flutter Riverpod Clean Architecture - Feature Generator
# This script generates a new feature with all required layers and files

# Colors for pretty output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}=======================================${NC}"
echo -e "${BLUE}      Feature Generator Tool          ${NC}"
echo -e "${BLUE}=======================================${NC}"

# Default values
FEATURE_NAME=""
WITH_UI="yes"
WITH_TESTS="yes"
WITH_DOCS="yes"
WITH_REPOSITORY="yes"
FEATURE_TYPE="full" # Options: full, ui-only, service-only

# Function to display usage information
usage() {
    echo -e "Usage: $0 [options] --name <feature_name>"
    echo -e "\nOptions:"
    echo -e "  --name <feature_name>    Name of the feature (required, use snake_case)"
    echo -e "  --no-ui                  Generate without UI/presentation layer"
    echo -e "  --no-repository          Generate without repository pattern (simplified structure)"
    echo -e "  --ui-only                Generate UI components only (models, widgets, and providers)"
    echo -e "  --service-only           Generate service only (models, service, and providers)"
    echo -e "  --no-tests               Skip test files generation"
    echo -e "  --no-docs                Skip documentation generation"
    echo -e "  --help                   Display this help message"
    echo -e "\nExamples:"
    echo -e "  $0 --name user_profile               # Full Clean Architecture"
    echo -e "  $0 --name theme_switcher --no-repository  # Without repository pattern"
    echo -e "  $0 --name button --ui-only           # UI component only"
    echo -e "  $0 --name logger --service-only      # Service only"
    exit 1
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --name)
            FEATURE_NAME="$2"
            shift 2
            ;;
        --no-ui)
            WITH_UI="no"
            shift
            ;;
        --no-repository)
            WITH_REPOSITORY="no"
            shift
            ;;
        --ui-only)
            FEATURE_TYPE="ui-only"
            WITH_REPOSITORY="no"
            shift
            ;;
        --service-only)
            FEATURE_TYPE="service-only"
            WITH_REPOSITORY="no"
            WITH_UI="no"
            shift
            ;;
        --no-tests)
            WITH_TESTS="no"
            shift
            ;;
        --no-docs)
            WITH_DOCS="no"
            shift
            ;;
        --help)
            usage
            ;;
        *)
            echo -e "${RED}Error: Unknown option: $1${NC}"
            usage
            ;;
    esac
done

# Validate feature name
if [ -z "$FEATURE_NAME" ]; then
    echo -e "${RED}Error: Feature name is required${NC}"
    usage
fi

# Convert feature_name to FeatureName (PascalCase) and featureName (camelCase)
PASCAL_CASE=$(echo "$FEATURE_NAME" | sed -r 's/(^|_)([a-z])/\U\2/g')
CAMEL_CASE=$(echo "$PASCAL_CASE" | sed 's/^./\L&/')

echo -e "${YELLOW}Generating feature: ${CYAN}$FEATURE_NAME${NC}"
echo -e "  PascalCase: ${CYAN}$PASCAL_CASE${NC}"
echo -e "  camelCase: ${CYAN}$CAMEL_CASE${NC}"

# Base directory for the feature
BASE_DIR="lib/features/$FEATURE_NAME"

# Check if feature already exists
if [ -d "$BASE_DIR" ]; then
    echo -e "${RED}Error: Feature '$FEATURE_NAME' already exists at $BASE_DIR${NC}"
    exit 1
fi

# Create directories
echo -e "\n${BLUE}Creating directory structure...${NC}"

# Feature type specific setup
if [ "$FEATURE_TYPE" = "ui-only" ]; then
    echo -e "${YELLOW}Creating UI-only feature structure...${NC}"
    
    # Models folder for data structures
    mkdir -p "$BASE_DIR/models"
    
    # Presentation layer for UI components
    mkdir -p "$BASE_DIR/presentation/widgets"
    mkdir -p "$BASE_DIR/presentation/providers"
    
    # Providers folder
    mkdir -p "$BASE_DIR/providers"
    
    # Test directories (if enabled)
    if [ "$WITH_TESTS" = "yes" ]; then
        mkdir -p "test/features/$FEATURE_NAME/models"
        mkdir -p "test/features/$FEATURE_NAME/presentation"
    fi
elif [ "$FEATURE_TYPE" = "service-only" ]; then
    echo -e "${YELLOW}Creating service-only feature structure...${NC}"
    
    # Models folder for data structures
    mkdir -p "$BASE_DIR/models"
    
    # Services folder
    mkdir -p "$BASE_DIR/services"
    
    # Providers folder
    mkdir -p "$BASE_DIR/providers"
    
    # Test directories (if enabled)
    if [ "$WITH_TESTS" = "yes" ]; then
        mkdir -p "test/features/$FEATURE_NAME/models"
        mkdir -p "test/features/$FEATURE_NAME/services"
    fi
else
    # Standard feature with or without repository
    if [ "$WITH_REPOSITORY" = "yes" ]; then
        # Full Clean Architecture structure
        
        # Data layer
        mkdir -p "$BASE_DIR/data/datasources"
        mkdir -p "$BASE_DIR/data/models"
        mkdir -p "$BASE_DIR/data/repositories"
        
        # Domain layer
        mkdir -p "$BASE_DIR/domain/entities"
        mkdir -p "$BASE_DIR/domain/repositories"
        mkdir -p "$BASE_DIR/domain/usecases"
        
        # Test directories (if enabled)
        if [ "$WITH_TESTS" = "yes" ]; then
            mkdir -p "test/features/$FEATURE_NAME/data"
            mkdir -p "test/features/$FEATURE_NAME/domain"
        fi
    else
        # No repository structure
        mkdir -p "$BASE_DIR/models"
        
        # Test directories (if enabled)
        if [ "$WITH_TESTS" = "yes" ]; then
            mkdir -p "test/features/$FEATURE_NAME/models"
        fi
    fi
    
    # Presentation layer (if enabled)
    if [ "$WITH_UI" = "yes" ]; then
        mkdir -p "$BASE_DIR/presentation/providers"
        mkdir -p "$BASE_DIR/presentation/screens"
        mkdir -p "$BASE_DIR/presentation/widgets"
        
        if [ "$WITH_TESTS" = "yes" ]; then
            mkdir -p "test/features/$FEATURE_NAME/presentation"
        fi
    fi
    
    # Providers folder
    mkdir -p "$BASE_DIR/providers"
fi

# Documentation (if enabled)
if [ "$WITH_DOCS" = "yes" ]; then
    mkdir -p "docs/features"
fi

# Create files based on feature type
if [ "$FEATURE_TYPE" = "ui-only" ]; then
    generate_ui_only_files
elif [ "$FEATURE_TYPE" = "service-only" ]; then
    generate_service_only_files
elif [ "$WITH_REPOSITORY" = "no" ]; then
    generate_no_repository_files
    
    # Add UI files if needed
    if [ "$WITH_UI" = "yes" ]; then
        # Create presentation files here
        # Simplified from the standard UI files
        echo -e "\n${BLUE}Creating presentation files...${NC}"
        
        # Screen file
        cat > "$BASE_DIR/presentation/screens/${FEATURE_NAME}_screen.dart" << EOF
// ${PASCAL_CASE} Screen

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/${FEATURE_NAME}_providers.dart';

class ${PASCAL_CASE}Screen extends ConsumerWidget {
  const ${PASCAL_CASE}Screen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dataAsync = ref.watch(${CAMEL_CASE}DataProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('${PASCAL_CASE}'),
      ),
      body: dataAsync.when(
        data: (items) => ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) => ListTile(
            title: Text('Item \${items[index].id}'),
            onTap: () {
              ref.read(selected${PASCAL_CASE}IdProvider.notifier).state = items[index].id;
            },
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text('Error: \$error'),
        ),
      ),
    );
  }
}
EOF
    fi
else
    echo -e "\n${BLUE}Creating scaffold files...${NC}"
    
    # Data layer files
    cat > "$BASE_DIR/data/models/${FEATURE_NAME}_model.dart" << EOF
// ${PASCAL_CASE} Model
// Implements the ${PASCAL_CASE}Entity with additional data layer functionality

import '../../domain/entities/${FEATURE_NAME}_entity.dart';

class ${PASCAL_CASE}Model extends ${PASCAL_CASE}Entity {
  ${PASCAL_CASE}Model({
    required String id,
    // Add required fields here
  }) : super(
          id: id,
          // Initialize super class with required fields
        );

  // Factory method to create a model from JSON
  factory ${PASCAL_CASE}Model.fromJson(Map<String, dynamic> json) {
    return ${PASCAL_CASE}Model(
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
  ${PASCAL_CASE}Model copyWith({
    String? id,
    // Add other fields here
  }) {
    return ${PASCAL_CASE}Model(
      id: id ?? this.id,
      // Add other fields with null-coalescing
    );
  }
}
EOF

cat > "$BASE_DIR/data/datasources/${FEATURE_NAME}_remote_datasource.dart" << EOF
// ${PASCAL_CASE} Remote Data Source
// Handles API calls and external data sources

import '../models/${FEATURE_NAME}_model.dart';

abstract class ${PASCAL_CASE}RemoteDataSource {
  /// Fetches ${CAMEL_CASE} data from the remote API
  ///
  /// Throws a [ServerException] for all error codes
  Future<List<${PASCAL_CASE}Model>> get${PASCAL_CASE}s();
  
  /// Fetches a specific ${CAMEL_CASE} by ID
  Future<${PASCAL_CASE}Model?> get${PASCAL_CASE}ById(String id);
}

class ${PASCAL_CASE}RemoteDataSourceImpl implements ${PASCAL_CASE}RemoteDataSource {
  // Add your API client here
  // final ApiClient apiClient;
  
  ${PASCAL_CASE}RemoteDataSourceImpl(/*{required this.apiClient}*/);
  
  @override
  Future<List<${PASCAL_CASE}Model>> get${PASCAL_CASE}s() async {
    // TODO: Implement API call
    throw UnimplementedError();
  }
  
  @override
  Future<${PASCAL_CASE}Model?> get${PASCAL_CASE}ById(String id) async {
    // TODO: Implement API call
    throw UnimplementedError();
  }
}
EOF

cat > "$BASE_DIR/data/datasources/${FEATURE_NAME}_local_datasource.dart" << EOF
// ${PASCAL_CASE} Local Data Source
// Handles local storage operations (SharedPreferences, SQLite, etc.)

import '../models/${FEATURE_NAME}_model.dart';

abstract class ${PASCAL_CASE}LocalDataSource {
  /// Gets cached ${CAMEL_CASE} data
  ///
  /// Throws a [CacheException] if no cached data is present
  Future<List<${PASCAL_CASE}Model>> getCached${PASCAL_CASE}s();
  
  /// Caches ${CAMEL_CASE} data
  Future<void> cache${PASCAL_CASE}s(List<${PASCAL_CASE}Model> ${CAMEL_CASE}s);
}

class ${PASCAL_CASE}LocalDataSourceImpl implements ${PASCAL_CASE}LocalDataSource {
  // Add your storage client here
  // final SharedPreferences sharedPreferences;
  
  ${PASCAL_CASE}LocalDataSourceImpl(/*{required this.sharedPreferences}*/);
  
  @override
  Future<List<${PASCAL_CASE}Model>> getCached${PASCAL_CASE}s() async {
    // TODO: Implement local storage retrieval
    throw UnimplementedError();
  }
  
  @override
  Future<void> cache${PASCAL_CASE}s(List<${PASCAL_CASE}Model> ${CAMEL_CASE}s) async {
    // TODO: Implement local storage caching
    throw UnimplementedError();
  }
}
EOF

cat > "$BASE_DIR/data/repositories/${FEATURE_NAME}_repository_impl.dart" << EOF
// ${PASCAL_CASE} Repository Implementation
// Implements the repository interface from domain layer

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/exceptions.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/${FEATURE_NAME}_entity.dart';
import '../../domain/repositories/${FEATURE_NAME}_repository.dart';
import '../datasources/${FEATURE_NAME}_local_datasource.dart';
import '../datasources/${FEATURE_NAME}_remote_datasource.dart';
import '../models/${FEATURE_NAME}_model.dart';

class ${PASCAL_CASE}RepositoryImpl implements ${PASCAL_CASE}Repository {
  final ${PASCAL_CASE}RemoteDataSource remoteDataSource;
  final ${PASCAL_CASE}LocalDataSource localDataSource;
  final NetworkInfo networkInfo;
  
  ${PASCAL_CASE}RepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });
  
  @override
  Future<Either<Failure, List<${PASCAL_CASE}Entity>>> getAll${PASCAL_CASE}s() async {
    if (await networkInfo.isConnected) {
      try {
        final remote${PASCAL_CASE}s = await remoteDataSource.get${PASCAL_CASE}s();
        await localDataSource.cache${PASCAL_CASE}s(remote${PASCAL_CASE}s);
        return Right(remote${PASCAL_CASE}s);
      } on ServerException {
        return Left(ServerFailure());
      }
    } else {
      try {
        final local${PASCAL_CASE}s = await localDataSource.getCached${PASCAL_CASE}s();
        return Right(local${PASCAL_CASE}s);
      } on CacheException {
        return Left(CacheFailure());
      }
    }
  }
  
  @override
  Future<Either<Failure, ${PASCAL_CASE}Entity>> get${PASCAL_CASE}ById(String id) async {
    // TODO: Implement get by ID functionality
    throw UnimplementedError();
  }
}
EOF

# Domain layer files
cat > "$BASE_DIR/domain/entities/${FEATURE_NAME}_entity.dart" << EOF
// ${PASCAL_CASE} Entity
// Core business entity, independent of data sources

import 'package:equatable/equatable.dart';

class ${PASCAL_CASE}Entity extends Equatable {
  final String id;
  // Add more fields here
  
  const ${PASCAL_CASE}Entity({
    required this.id,
    // Add required fields here
  });
  
  @override
  List<Object> get props => [id];
}
EOF

cat > "$BASE_DIR/domain/repositories/${FEATURE_NAME}_repository.dart" << EOF
// ${PASCAL_CASE} Repository Interface
// Define contract for data operations

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/${FEATURE_NAME}_entity.dart';

abstract class ${PASCAL_CASE}Repository {
  /// Gets all ${CAMEL_CASE} entities
  ///
  /// Returns [Failure] or [List<${PASCAL_CASE}Entity>]
  Future<Either<Failure, List<${PASCAL_CASE}Entity>>> getAll${PASCAL_CASE}s();
  
  /// Gets a specific ${CAMEL_CASE} entity by ID
  ///
  /// Returns [Failure] or [${PASCAL_CASE}Entity]
  Future<Either<Failure, ${PASCAL_CASE}Entity>> get${PASCAL_CASE}ById(String id);
}
EOF

cat > "$BASE_DIR/domain/usecases/get_all_${FEATURE_NAME}s.dart" << EOF
// Get All ${PASCAL_CASE}s Use Case
// Business logic for retrieving all ${CAMEL_CASE} entities

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/${FEATURE_NAME}_entity.dart';
import '../repositories/${FEATURE_NAME}_repository.dart';

class GetAll${PASCAL_CASE}s implements UseCase<List<${PASCAL_CASE}Entity>, NoParams> {
  final ${PASCAL_CASE}Repository repository;
  
  GetAll${PASCAL_CASE}s(this.repository);
  
  @override
  Future<Either<Failure, List<${PASCAL_CASE}Entity>>> call(NoParams params) {
    return repository.getAll${PASCAL_CASE}s();
  }
}
EOF

cat > "$BASE_DIR/domain/usecases/get_${FEATURE_NAME}_by_id.dart" << EOF
// Get ${PASCAL_CASE} By ID Use Case
// Business logic for retrieving a specific ${CAMEL_CASE} entity

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/${FEATURE_NAME}_entity.dart';
import '../repositories/${FEATURE_NAME}_repository.dart';

class Get${PASCAL_CASE}ById implements UseCase<${PASCAL_CASE}Entity, ${PASCAL_CASE}Params> {
  final ${PASCAL_CASE}Repository repository;
  
  Get${PASCAL_CASE}ById(this.repository);
  
  @override
  Future<Either<Failure, ${PASCAL_CASE}Entity>> call(${PASCAL_CASE}Params params) {
    return repository.get${PASCAL_CASE}ById(params.id);
  }
}

class ${PASCAL_CASE}Params extends Equatable {
  final String id;
  
  const ${PASCAL_CASE}Params({required this.id});
  
  @override
  List<Object> get props => [id];
}
EOF

# Providers
cat > "$BASE_DIR/providers/${FEATURE_NAME}_providers.dart" << EOF
// ${PASCAL_CASE} Providers
// Riverpod providers for the ${FEATURE_NAME} feature

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/network_info.dart';
import '../data/datasources/${FEATURE_NAME}_local_datasource.dart';
import '../data/datasources/${FEATURE_NAME}_remote_datasource.dart';
import '../data/repositories/${FEATURE_NAME}_repository_impl.dart';
import '../domain/entities/${FEATURE_NAME}_entity.dart';
import '../domain/repositories/${FEATURE_NAME}_repository.dart';
import '../domain/usecases/get_all_${FEATURE_NAME}s.dart';
import '../domain/usecases/get_${FEATURE_NAME}_by_id.dart';

// Data sources
final ${CAMEL_CASE}RemoteDataSourceProvider = Provider<${PASCAL_CASE}RemoteDataSource>(
  (ref) => ${PASCAL_CASE}RemoteDataSourceImpl(
    // Add dependencies here
  ),
);

final ${CAMEL_CASE}LocalDataSourceProvider = Provider<${PASCAL_CASE}LocalDataSource>(
  (ref) => ${PASCAL_CASE}LocalDataSourceImpl(
    // Add dependencies here
  ),
);

// Repository
final ${CAMEL_CASE}RepositoryProvider = Provider<${PASCAL_CASE}Repository>(
  (ref) => ${PASCAL_CASE}RepositoryImpl(
    remoteDataSource: ref.read(${CAMEL_CASE}RemoteDataSourceProvider),
    localDataSource: ref.read(${CAMEL_CASE}LocalDataSourceProvider),
    networkInfo: ref.read(networkInfoProvider),
  ),
);

// Use cases
final getAll${PASCAL_CASE}sProvider = Provider<GetAll${PASCAL_CASE}s>(
  (ref) => GetAll${PASCAL_CASE}s(ref.read(${CAMEL_CASE}RepositoryProvider)),
);

final get${PASCAL_CASE}ByIdProvider = Provider<Get${PASCAL_CASE}ById>(
  (ref) => Get${PASCAL_CASE}ById(ref.read(${CAMEL_CASE}RepositoryProvider)),
);

// State providers
final ${CAMEL_CASE}ListProvider = FutureProvider<List<${PASCAL_CASE}Entity>>(
  (ref) async {
    final usecase = ref.read(getAll${PASCAL_CASE}sProvider);
    final result = await usecase(NoParams());
    
    return result.fold(
      (failure) => throw Exception(failure.toString()),
      (${CAMEL_CASE}s) => ${CAMEL_CASE}s,
    );
  },
);

final selected${PASCAL_CASE}IdProvider = StateProvider<String?>((ref) => null);

final selected${PASCAL_CASE}Provider = FutureProvider<${PASCAL_CASE}Entity?>((ref) async {
  final id = ref.watch(selected${PASCAL_CASE}IdProvider);
  if (id == null) return null;
  
  final usecase = ref.read(get${PASCAL_CASE}ByIdProvider);
  final result = await usecase(${PASCAL_CASE}Params(id: id));
  
  return result.fold(
    (failure) => throw Exception(failure.toString()),
    (${CAMEL_CASE}) => ${CAMEL_CASE},
  );
});
EOF

# Presentation layer (if enabled)
if [ "$WITH_UI" = "yes" ]; then
  # UI files
  cat > "$BASE_DIR/presentation/screens/${FEATURE_NAME}_list_screen.dart" << EOF
// ${PASCAL_CASE} List Screen
// Screen that displays a list of ${CAMEL_CASE} items

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/${FEATURE_NAME}_providers.dart';
import '../widgets/${FEATURE_NAME}_list_item.dart';

class ${PASCAL_CASE}ListScreen extends ConsumerWidget {
  const ${PASCAL_CASE}ListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ${CAMEL_CASE}sAsync = ref.watch(${CAMEL_CASE}ListProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('${PASCAL_CASE}s'),
      ),
      body: ${CAMEL_CASE}sAsync.when(
        data: (${CAMEL_CASE}s) => ListView.builder(
          itemCount: ${CAMEL_CASE}s.length,
          itemBuilder: (context, index) => ${PASCAL_CASE}ListItem(
            ${CAMEL_CASE}: ${CAMEL_CASE}s[index],
            onTap: () {
              ref.read(selected${PASCAL_CASE}IdProvider.notifier).state = ${CAMEL_CASE}s[index].id;
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
          // Add new ${CAMEL_CASE} action
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
EOF

  cat > "$BASE_DIR/presentation/screens/${FEATURE_NAME}_detail_screen.dart" << EOF
// ${PASCAL_CASE} Detail Screen
// Screen that displays details of a specific ${CAMEL_CASE}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/${FEATURE_NAME}_providers.dart';

class ${PASCAL_CASE}DetailScreen extends ConsumerWidget {
  const ${PASCAL_CASE}DetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ${CAMEL_CASE}Async = ref.watch(selected${PASCAL_CASE}Provider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('${PASCAL_CASE} Details'),
      ),
      body: ${CAMEL_CASE}Async.when(
        data: (${CAMEL_CASE}) {
          if (${CAMEL_CASE} == null) {
            return const Center(child: Text('${PASCAL_CASE} not found'));
          }
          
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ID: \${${CAMEL_CASE}.id}', style: Theme.of(context).textTheme.headlineSmall),
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
EOF

  cat > "$BASE_DIR/presentation/widgets/${FEATURE_NAME}_list_item.dart" << EOF
// ${PASCAL_CASE} List Item
// Widget that displays a single ${CAMEL_CASE} in a list

import 'package:flutter/material.dart';

import '../../domain/entities/${FEATURE_NAME}_entity.dart';

class ${PASCAL_CASE}ListItem extends StatelessWidget {
  final ${PASCAL_CASE}Entity ${CAMEL_CASE};
  final VoidCallback onTap;
  
  const ${PASCAL_CASE}ListItem({
    Key? key,
    required this.${CAMEL_CASE},
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text('${PASCAL_CASE} \${${CAMEL_CASE}.id}'),
        // Add more details here
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
EOF

  # Presentation providers
  cat > "$BASE_DIR/presentation/providers/${FEATURE_NAME}_ui_providers.dart" << EOF
// ${PASCAL_CASE} UI Providers
// Riverpod providers specific to UI state

import 'package:flutter_riverpod/flutter_riverpod.dart';

// UI state providers
final ${CAMEL_CASE}FilterProvider = StateProvider<String>((ref) => '');

final ${CAMEL_CASE}SortOrderProvider = StateProvider<SortOrder>((ref) => SortOrder.asc);

enum SortOrder { asc, desc }
EOF
fi

# Test files (if enabled)
if [ "$WITH_TESTS" = "yes" ]; then
  mkdir -p "test/features/$FEATURE_NAME/data/datasources"
  mkdir -p "test/features/$FEATURE_NAME/data/models"
  mkdir -p "test/features/$FEATURE_NAME/data/repositories"
  mkdir -p "test/features/$FEATURE_NAME/domain/usecases"
  
  cat > "test/features/$FEATURE_NAME/data/models/${FEATURE_NAME}_model_test.dart" << EOF
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod_clean_architecture/features/$FEATURE_NAME/data/models/${FEATURE_NAME}_model.dart';
import 'package:flutter_riverpod_clean_architecture/features/$FEATURE_NAME/domain/entities/${FEATURE_NAME}_entity.dart';

void main() {
  final ${CAMEL_CASE}Model = ${PASCAL_CASE}Model(
    id: 'test-id',
    // Add other test fields
  );

  test('should be a subclass of ${PASCAL_CASE}Entity', () {
    // assert
    expect(${CAMEL_CASE}Model, isA<${PASCAL_CASE}Entity>());
  });

  group('fromJson', () {
    test('should return a valid model when JSON data is valid', () {
      // arrange
      final Map<String, dynamic> jsonMap = {
        'id': 'test-id',
        // Add other fields
      };
      
      // act
      final result = ${PASCAL_CASE}Model.fromJson(jsonMap);
      
      // assert
      expect(result, ${CAMEL_CASE}Model);
    });
  });

  group('toJson', () {
    test('should return a JSON map with proper data', () {
      // act
      final result = ${CAMEL_CASE}Model.toJson();
      
      // assert
      final expectedMap = {
        'id': 'test-id',
        // Add other fields
      };
      expect(result, expectedMap);
    });
  });
}
EOF

  cat > "test/features/$FEATURE_NAME/domain/usecases/get_all_${FEATURE_NAME}s_test.dart" << EOF
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:flutter_riverpod_clean_architecture/core/usecases/usecase.dart';
import 'package:flutter_riverpod_clean_architecture/features/$FEATURE_NAME/domain/entities/${FEATURE_NAME}_entity.dart';
import 'package:flutter_riverpod_clean_architecture/features/$FEATURE_NAME/domain/repositories/${FEATURE_NAME}_repository.dart';
import 'package:flutter_riverpod_clean_architecture/features/$FEATURE_NAME/domain/usecases/get_all_${FEATURE_NAME}s.dart';

@GenerateMocks([${PASCAL_CASE}Repository])
void main() {
  late GetAll${PASCAL_CASE}s usecase;
  late MockRepository mockRepository;

  setUp(() {
    mockRepository = MockRepository();
    usecase = GetAll${PASCAL_CASE}s(mockRepository);
  });

  final testEntities = [
    ${PASCAL_CASE}Entity(id: 'test-id-1'),
    ${PASCAL_CASE}Entity(id: 'test-id-2'),
  ];

  test('should get all ${CAMEL_CASE}s from the repository', () async {
    // arrange
    when(mockRepository.getAll${PASCAL_CASE}s())
        .thenAnswer((_) async => Right(testEntities));
    
    // act
    final result = await usecase(NoParams());
    
    // assert
    expect(result, Right(testEntities));
    verify(mockRepository.getAll${PASCAL_CASE}s());
    verifyNoMoreInteractions(mockRepository);
  });
}
EOF
fi

# Documentation (if enabled)
if [ "$WITH_DOCS" = "yes" ]; then
  mkdir -p "docs/features"
  
  # Choose documentation template based on feature type
  if [ "$FEATURE_TYPE" = "ui-only" ]; then
    cat > "docs/features/${FEATURE_NAME}_guide.md" << EOF
# ${PASCAL_CASE} UI Component Guide

This document provides an overview of the \`${FEATURE_NAME}\` UI component.

## Overview

The ${PASCAL_CASE} component provides a reusable UI element for displaying and interacting with ${CAMEL_CASE} data.

## Architecture

This is a UI-only feature designed for maximum reusability:

- **Models**: Simple data structures for component configuration
- **Presentation**: Reusable widgets and UI-specific providers
- **Providers**: State management for the component

## Components

### Models

- \`${FEATURE_NAME}_model.dart\`: Data model for the ${CAMEL_CASE} component

### Presentation

- \`${FEATURE_NAME}_widget.dart\`: The main reusable UI component
- \`${FEATURE_NAME}_ui_providers.dart\`: UI-specific state providers

### Providers

- \`${FEATURE_NAME}_providers.dart\`: Riverpod providers for the component

## Usage

### Adding the ${PASCAL_CASE} Widget to a Screen

```dart
import 'package:flutter/material.dart';
import 'package:your_app/features/${FEATURE_NAME}/presentation/widgets/${FEATURE_NAME}_widget.dart';

class SomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ${PASCAL_CASE}Widget(
        id: 'component-1',
        label: 'My ${PASCAL_CASE}',
        onPressed: () {
          // Handle interaction
        },
      ),
    );
  }
}
```

## Implementation Notes

- The component uses Riverpod for internal state management
- Designed to be easily configurable and adaptable
EOF

  elif [ "$FEATURE_TYPE" = "service-only" ]; then
    cat > "docs/features/${FEATURE_NAME}_guide.md" << EOF
# ${PASCAL_CASE} Service Guide

This document provides an overview of the \`${FEATURE_NAME}\` service.

## Overview

The ${PASCAL_CASE} service provides functionality to handle ${CAMEL_CASE}-related operations.

## Architecture

This is a service-only feature:

- **Models**: Configuration and data models for the service
- **Services**: Core service implementation
- **Providers**: Dependency injection and state management

## Components

### Models

- \`${FEATURE_NAME}_model.dart\`: Configuration model for the ${CAMEL_CASE} service

### Services

- \`${FEATURE_NAME}_service.dart\`: Main service implementation

### Providers

- \`${FEATURE_NAME}_providers.dart\`: Riverpod providers for the service

## Usage

### Using the ${PASCAL_CASE} Service

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_app/features/${FEATURE_NAME}/providers/${FEATURE_NAME}_providers.dart';

class SomeConsumerWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Access the service
    final service = ref.watch(${CAMEL_CASE}ServiceProvider);
    
    // Use the service
    return ElevatedButton(
      onPressed: () async {
        final result = await service.performOperation(input: 'test');
        print('Operation result: \$result');
      },
      child: Text('Perform Operation'),
    );
  }
}
```

## Implementation Notes

- The service is initialized lazily through Riverpod providers
- Configuration can be customized through the config provider
EOF

  elif [ "$WITH_REPOSITORY" = "no" ]; then
    cat > "docs/features/${FEATURE_NAME}_guide.md" << EOF
# ${PASCAL_CASE} Feature Guide

This document provides an overview of the \`${FEATURE_NAME}\` feature.

## Overview

The ${PASCAL_CASE} feature provides functionality to manage and display ${CAMEL_CASE} data.

## Architecture

This feature uses a simplified architecture without the repository pattern:

- **Models**: Data models for the feature
- **Providers**: Direct data access and state management
- **Presentation** (if applicable): User interface components

## Components

### Models

- \`${FEATURE_NAME}_model.dart\`: Data model representing ${CAMEL_CASE}s

### Providers

- \`${FEATURE_NAME}_providers.dart\`: Riverpod providers for state management and data access

### Presentation Layer (if included)

- \`${FEATURE_NAME}_screen.dart\`: Main screen for the feature
- Additional UI components as needed

## Usage

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_app/features/${FEATURE_NAME}/providers/${FEATURE_NAME}_providers.dart';

// Access data
final items = ref.watch(${CAMEL_CASE}DataProvider);

// Update state
ref.read(${CAMEL_CASE}NotifierProvider.notifier).loadItems();
```

## Implementation Notes

- The feature uses Riverpod for state management
- Data is accessed directly through providers without a repository layer
- Simplified architecture for less complex features
EOF

  else
    # Standard Clean Architecture documentation
    cat > "docs/features/${FEATURE_NAME}_guide.md" << EOF
# ${PASCAL_CASE} Feature Guide

This document provides an overview of the \`${FEATURE_NAME}\` feature.

## Overview

The ${PASCAL_CASE} feature provides functionality to manage and display ${CAMEL_CASE} data.

## Architecture

The feature follows Clean Architecture principles with the following layers:

- **Data Layer**: Handles data sources, models, and repository implementations
- **Domain Layer**: Contains business entities, repository interfaces, and use cases
- **Presentation Layer**: User interface components and state management

## Components

### Data Layer

- \`${FEATURE_NAME}_model.dart\`: Data model representing a ${CAMEL_CASE}
- \`${FEATURE_NAME}_remote_datasource.dart\`: Handles API calls for ${CAMEL_CASE} data
- \`${FEATURE_NAME}_local_datasource.dart\`: Handles local storage for ${CAMEL_CASE} data
- \`${FEATURE_NAME}_repository_impl.dart\`: Implements the repository interface

### Domain Layer

- \`${FEATURE_NAME}_entity.dart\`: Core business entity
- \`${FEATURE_NAME}_repository.dart\`: Repository interface defining data operations
- \`get_all_${FEATURE_NAME}s.dart\`: Use case to retrieve all ${CAMEL_CASE}s
- \`get_${FEATURE_NAME}_by_id.dart\`: Use case to retrieve a specific ${CAMEL_CASE}

### Presentation Layer

- \`${FEATURE_NAME}_list_screen.dart\`: Screen to display a list of ${CAMEL_CASE}s
- \`${FEATURE_NAME}_detail_screen.dart\`: Screen to display details of a specific ${CAMEL_CASE}
- \`${FEATURE_NAME}_list_item.dart\`: Widget to display a single ${CAMEL_CASE} in a list

### Providers

- \`${FEATURE_NAME}_providers.dart\`: Riverpod providers for the feature
- \`${FEATURE_NAME}_ui_providers.dart\`: UI-specific state providers

## Usage

### Adding a ${PASCAL_CASE}

1. Navigate to the ${PASCAL_CASE} List Screen
2. Tap the + button
3. Fill in the required fields
4. Submit the form

### Viewing ${PASCAL_CASE} Details

1. Navigate to the ${PASCAL_CASE} List Screen
2. Tap on a ${PASCAL_CASE} item to view its details

## Implementation Notes

- The feature uses Riverpod for state management
- Error handling follows the Either pattern from dartz
- Repository pattern is used to abstract data sources
EOF
  fi
fi

# Make dart feature generator file
cat > "$BASE_DIR/core/cli/feature_generator.dart" << EOF
/// Flutter Riverpod Clean Architecture Feature Generator
/// 
/// This Dart file can be used programmatically to generate new features
/// It mirrors the functionality of the generate_feature.sh script
/// but allows for more complex integration with IDE plugins or Flutter tools.

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
    print('Generating feature: \$featureName');
    
    await _createDirectories();
    await _createFiles();
    
    print('Feature \$featureName generated successfully!');
  }

  /// Create the directory structure for the feature
  Future<void> _createDirectories() async {
    final baseDir = 'lib/features/\$featureName';
    
    // Data layer
    await _createDir('\$baseDir/data/datasources');
    await _createDir('\$baseDir/data/models');
    await _createDir('\$baseDir/data/repositories');
    
    // Domain layer
    await _createDir('\$baseDir/domain/entities');
    await _createDir('\$baseDir/domain/repositories');
    await _createDir('\$baseDir/domain/usecases');
    
    // Presentation layer (if enabled)
    if (withUi) {
      await _createDir('\$baseDir/presentation/providers');
      await _createDir('\$baseDir/presentation/screens');
      await _createDir('\$baseDir/presentation/widgets');
    }
    
    // Providers folder
    await _createDir('\$baseDir/providers');
    
    // Test directories (if enabled)
    if (withTests) {
      await _createDir('test/features/\$featureName/data');
      await _createDir('test/features/\$featureName/domain');
      if (withUi) {
        await _createDir('test/features/\$featureName/presentation');
      }
    }
    
    // Documentation (if enabled)
    if (withDocs) {
      await _createDir('docs/features');
    }
  }

  /// Create all template files for the feature
  Future<void> _createFiles() async {
    // TODO: Implement file creation logic similar to the shell script
  }

  /// Helper method to create a directory and its parents if they don't exist
  Future<void> _createDir(String path) async {
    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
      print('Created directory: \$path');
    }
  }

  /// Helper method to create a file with the given content
  Future<void> _createFile(String path, String content) async {
    final file = File(path);
    await file.writeAsString(content);
    print('Created file: \$path');
  }

  /// Convert snake_case to PascalCase
  String _toPascalCase(String input) {
    return input.split('_')
        .map((word) => word.isEmpty 
            ? '' 
            : word[0].toUpperCase() + word.substring(1).toLowerCase())
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
    print('Please provide a feature name in snake_case format.');
    return;
  }
  
  final generator = FeatureGenerator(featureName: args.first);
  generator.generate();
}
EOF

# Make feature script executable
chmod +x "generate_feature.sh"

# Print success message based on feature type
if [ "$FEATURE_TYPE" = "ui-only" ]; then
    echo -e "\n${GREEN}✅ UI Component feature '${FEATURE_NAME}' created successfully!${NC}"
    echo -e "Created component structure in ${CYAN}lib/features/${FEATURE_NAME}/${NC}"
elif [ "$FEATURE_TYPE" = "service-only" ]; then
    echo -e "\n${GREEN}✅ Service feature '${FEATURE_NAME}' created successfully!${NC}"
    echo -e "Created service structure in ${CYAN}lib/features/${FEATURE_NAME}/${NC}"
elif [ "$WITH_REPOSITORY" = "no" ]; then
    echo -e "\n${GREEN}✅ Simplified feature '${FEATURE_NAME}' created successfully!${NC}"
    echo -e "Created feature structure (without repository pattern) in ${CYAN}lib/features/${FEATURE_NAME}/${NC}"
else
    echo -e "\n${GREEN}✅ Clean Architecture feature '${FEATURE_NAME}' created successfully!${NC}"
    echo -e "Created complete feature structure in ${CYAN}lib/features/${FEATURE_NAME}/${NC}"
fi

echo -e "\nYou can create more features using:"
echo -e "  ${YELLOW}./generate_feature.sh --name your_feature_name${NC}"
echo -e "\nOptions:"
echo -e "  ${YELLOW}--no-ui${NC}            Skip UI/presentation layer"
echo -e "  ${YELLOW}--no-repository${NC}    Skip repository pattern (simplified structure)"
echo -e "  ${YELLOW}--ui-only${NC}          Create UI component only"
echo -e "  ${YELLOW}--service-only${NC}     Create service only"
echo -e "  ${YELLOW}--no-tests${NC}         Skip test files generation"
echo -e "  ${YELLOW}--no-docs${NC}          Skip documentation generation"
echo

exit 0
