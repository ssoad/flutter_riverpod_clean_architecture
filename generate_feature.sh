#!/bin/bash

# Flutter Riverpod Clean Architecture - Feature Generator
# Clean rewrite: robust argument parsing, clear structure, no duplicate logic

# Color definitions
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

usage() {
  echo -e "${YELLOW}Usage: $0 [options] --name <feature_name>${NC}"
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

# Defaults
FEATURE_NAME=""
WITH_UI="yes"
WITH_TESTS="yes"
WITH_DOCS="yes"
WITH_REPOSITORY="yes"
FEATURE_TYPE="full"

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --name)
      FEATURE_NAME="$2"; shift 2;;
    --no-ui)
      WITH_UI="no"; shift;;
    --no-repository)
      WITH_REPOSITORY="no"; shift;;
    --ui-only)
      FEATURE_TYPE="ui-only"; WITH_REPOSITORY="no"; shift;;
    --service-only)
      FEATURE_TYPE="service-only"; WITH_REPOSITORY="no"; WITH_UI="no"; shift;;
    --no-tests)
      WITH_TESTS="no"; shift;;
    --no-docs)
      WITH_DOCS="no"; shift;;
    --help)
      usage;;
    *)
      echo -e "${RED}Unknown option: $1${NC}"; usage;;
  esac
done

# Validate required parameters
if [[ -z "$FEATURE_NAME" ]]; then
  echo -e "${RED}Error: --name <feature_name> is required${NC}"; usage
fi

# Case conversions - Convert snake_case to PascalCase and camelCase
PASCAL_CASE=""
IFS='_' read -ra PARTS <<< "$FEATURE_NAME"
for part in "${PARTS[@]}"; do
    if [[ -n "$part" ]]; then
        PASCAL_CASE="${PASCAL_CASE}$(echo "${part:0:1}" | tr '[:lower:]' '[:upper:]')${part:1}"
    fi
done

CAMEL_CASE="${PASCAL_CASE:0:1}"
CAMEL_CASE="$(echo "$CAMEL_CASE" | tr '[:upper:]' '[:lower:]')${PASCAL_CASE:1}"

# Check if feature already exists
BASE_DIR="lib/features/$FEATURE_NAME"
if [[ -d "$BASE_DIR" ]]; then
  echo -e "${RED}Error: Feature already exists: $BASE_DIR${NC}"; exit 1
fi

# Display header
echo -e "${BLUE}=======================================${NC}"
echo -e "${BLUE}      Feature Generator Tool          ${NC}"
echo -e "${BLUE}=======================================${NC}"
echo -e "${YELLOW}Generating feature: ${CYAN}$FEATURE_NAME${NC}"
echo -e "  PascalCase: ${CYAN}$PASCAL_CASE${NC}"
echo -e "  camelCase: ${CYAN}$CAMEL_CASE${NC}"

echo -e "${BLUE}Creating directory structure...${NC}"

# Create directory structure based on feature type
if [[ "$FEATURE_TYPE" == "ui-only" ]]; then
  mkdir -p "$BASE_DIR/models"
  mkdir -p "$BASE_DIR/presentation/widgets"
  mkdir -p "$BASE_DIR/presentation/providers"
  mkdir -p "$BASE_DIR/providers"
  [[ "$WITH_TESTS" == "yes" ]] && mkdir -p "test/features/$FEATURE_NAME/models" "test/features/$FEATURE_NAME/presentation"
elif [[ "$FEATURE_TYPE" == "service-only" ]]; then
  mkdir -p "$BASE_DIR/models"
  mkdir -p "$BASE_DIR/services"
  mkdir -p "$BASE_DIR/providers"
  [[ "$WITH_TESTS" == "yes" ]] && mkdir -p "test/features/$FEATURE_NAME/models" "test/features/$FEATURE_NAME/services"
else
  if [[ "$WITH_REPOSITORY" == "yes" ]]; then
    mkdir -p "$BASE_DIR/data/datasources" "$BASE_DIR/data/models" "$BASE_DIR/data/repositories"
    mkdir -p "$BASE_DIR/domain/entities" "$BASE_DIR/domain/repositories" "$BASE_DIR/domain/usecases"
    [[ "$WITH_TESTS" == "yes" ]] && mkdir -p "test/features/$FEATURE_NAME/data" "test/features/$FEATURE_NAME/domain"
  else
    mkdir -p "$BASE_DIR/models"
    [[ "$WITH_TESTS" == "yes" ]] && mkdir -p "test/features/$FEATURE_NAME/models"
  fi
  if [[ "$WITH_UI" == "yes" ]]; then
    mkdir -p "$BASE_DIR/presentation/providers" "$BASE_DIR/presentation/screens" "$BASE_DIR/presentation/widgets"
    [[ "$WITH_TESTS" == "yes" ]] && mkdir -p "test/features/$FEATURE_NAME/presentation"
  fi
  mkdir -p "$BASE_DIR/providers"
fi

# === File Generation Logic ===

# Data Layer Files (for full architecture)
if [[ "$FEATURE_TYPE" != "ui-only" && "$FEATURE_TYPE" != "service-only" && "$WITH_REPOSITORY" == "yes" ]]; then
  cat > "$BASE_DIR/data/models/${FEATURE_NAME}_model.dart" << EOF
// ${PASCAL_CASE} Model
// Data model for the ${FEATURE_NAME} feature

import '../../domain/entities/${FEATURE_NAME}_entity.dart';

class ${PASCAL_CASE}Model extends ${PASCAL_CASE}Entity {
  const ${PASCAL_CASE}Model({
    required String id,
    // Add other fields here
  }) : super(id: id);

  factory ${PASCAL_CASE}Model.fromJson(Map<String, dynamic> json) {
    return ${PASCAL_CASE}Model(
      id: json['id'] as String,
      // Map other fields here
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      // Add other fields here
    };
  }
}
EOF

  cat > "$BASE_DIR/data/datasources/${FEATURE_NAME}_remote_datasource.dart" << EOF
// ${PASCAL_CASE} Remote Data Source
// Handles API calls for ${FEATURE_NAME} data

import '../models/${FEATURE_NAME}_model.dart';

abstract class ${PASCAL_CASE}RemoteDataSource {
  /// Gets all ${CAMEL_CASE}s from the API
  Future<List<${PASCAL_CASE}Model>> getAll${PASCAL_CASE}s();
  
  /// Gets a specific ${CAMEL_CASE} by ID from the API
  Future<${PASCAL_CASE}Model> get${PASCAL_CASE}ById(String id);
}

class ${PASCAL_CASE}RemoteDataSourceImpl implements ${PASCAL_CASE}RemoteDataSource {
  // Add HTTP client dependency here
  
  @override
  Future<List<${PASCAL_CASE}Model>> getAll${PASCAL_CASE}s() async {
    // TODO: Implement API call
    throw UnimplementedError();
  }
  
  @override
  Future<${PASCAL_CASE}Model> get${PASCAL_CASE}ById(String id) async {
    // TODO: Implement API call
    throw UnimplementedError();
  }
}
EOF

  cat > "$BASE_DIR/data/datasources/${FEATURE_NAME}_local_datasource.dart" << EOF
// ${PASCAL_CASE} Local Data Source
// Handles local storage for ${FEATURE_NAME} data

import '../models/${FEATURE_NAME}_model.dart';

abstract class ${PASCAL_CASE}LocalDataSource {
  /// Gets cached ${CAMEL_CASE}s from local storage
  Future<List<${PASCAL_CASE}Model>> getCached${PASCAL_CASE}s();
  
  /// Caches ${CAMEL_CASE}s to local storage
  Future<void> cache${PASCAL_CASE}s(List<${PASCAL_CASE}Model> ${CAMEL_CASE}s);
}

class ${PASCAL_CASE}LocalDataSourceImpl implements ${PASCAL_CASE}LocalDataSource {
  // Add local storage dependency here
  
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
// Implements the repository interface for ${FEATURE_NAME}

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/${FEATURE_NAME}_entity.dart';
import '../../domain/repositories/${FEATURE_NAME}_repository.dart';
import '../datasources/${FEATURE_NAME}_local_datasource.dart';
import '../datasources/${FEATURE_NAME}_remote_datasource.dart';

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
        final remote${PASCAL_CASE}s = await remoteDataSource.getAll${PASCAL_CASE}s();
        localDataSource.cache${PASCAL_CASE}s(remote${PASCAL_CASE}s);
        return Right(remote${PASCAL_CASE}s);
      } catch (e) {
        return Left(ServerFailure());
      }
    } else {
      try {
        final local${PASCAL_CASE}s = await localDataSource.getCached${PASCAL_CASE}s();
        return Right(local${PASCAL_CASE}s);
      } catch (e) {
        return Left(CacheFailure());
      }
    }
  }

  @override
  Future<Either<Failure, ${PASCAL_CASE}Entity>> get${PASCAL_CASE}ById(String id) async {
    if (await networkInfo.isConnected) {
      try {
        final ${CAMEL_CASE} = await remoteDataSource.get${PASCAL_CASE}ById(id);
        return Right(${CAMEL_CASE});
      } catch (e) {
        return Left(ServerFailure());
      }
    } else {
      return Left(NetworkFailure());
    }
  }
}
EOF

  # Domain Layer Files
  cat > "$BASE_DIR/domain/entities/${FEATURE_NAME}_entity.dart" << EOF
// ${PASCAL_CASE} Entity
// Core business entity for ${FEATURE_NAME}

import 'package:equatable/equatable.dart';

class ${PASCAL_CASE}Entity extends Equatable {
  final String id;
  // Add other properties here

  const ${PASCAL_CASE}Entity({
    required this.id,
    // Add other required parameters here
  });

  @override
  List<Object> get props => [id]; // Add other properties to props
}
EOF

  cat > "$BASE_DIR/domain/repositories/${FEATURE_NAME}_repository.dart" << EOF
// ${PASCAL_CASE} Repository Interface
// Defines data operations for ${FEATURE_NAME}

import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/${FEATURE_NAME}_entity.dart';

abstract class ${PASCAL_CASE}Repository {
  /// Gets all ${CAMEL_CASE} entities
  Future<Either<Failure, List<${PASCAL_CASE}Entity>>> getAll${PASCAL_CASE}s();
  
  /// Gets a specific ${CAMEL_CASE} entity by ID
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
fi

# Providers
cat > "$BASE_DIR/providers/${FEATURE_NAME}_providers.dart" << EOF
// ${PASCAL_CASE} Providers
// Riverpod providers for the ${FEATURE_NAME} feature

import 'package:flutter_riverpod/flutter_riverpod.dart';

EOF

if [[ "$WITH_REPOSITORY" == "yes" && "$FEATURE_TYPE" != "ui-only" && "$FEATURE_TYPE" != "service-only" ]]; then
  cat >> "$BASE_DIR/providers/${FEATURE_NAME}_providers.dart" << EOF
import '../../../../core/network/network_info.dart';
import '../../../../core/usecases/usecase.dart';
import '../data/datasources/${FEATURE_NAME}_local_datasource.dart';
import '../data/datasources/${FEATURE_NAME}_remote_datasource.dart';
import '../data/repositories/${FEATURE_NAME}_repository_impl.dart';
import '../domain/entities/${FEATURE_NAME}_entity.dart';
import '../domain/repositories/${FEATURE_NAME}_repository.dart';
import '../domain/usecases/get_all_${FEATURE_NAME}s.dart';
import '../domain/usecases/get_${FEATURE_NAME}_by_id.dart';

// Data sources
final ${CAMEL_CASE}RemoteDataSourceProvider = Provider<${PASCAL_CASE}RemoteDataSource>(
  (ref) => ${PASCAL_CASE}RemoteDataSourceImpl(),
);

final ${CAMEL_CASE}LocalDataSourceProvider = Provider<${PASCAL_CASE}LocalDataSource>(
  (ref) => ${PASCAL_CASE}LocalDataSourceImpl(),
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
else
  cat >> "$BASE_DIR/providers/${FEATURE_NAME}_providers.dart" << EOF
// Simple providers for ${FEATURE_TYPE} feature
final ${CAMEL_CASE}StateProvider = StateProvider<String>((ref) => 'initial');
EOF
fi

# Presentation Layer Files (if enabled)
if [[ "$WITH_UI" == "yes" ]]; then
  if [[ "$FEATURE_TYPE" == "ui-only" ]]; then
    # Create UI component widget for ui-only features
    cat > "$BASE_DIR/presentation/widgets/${FEATURE_NAME}_widget.dart" << EOF
// ${PASCAL_CASE} Widget
// Reusable UI component for ${FEATURE_NAME}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/${FEATURE_NAME}_providers.dart';

class ${PASCAL_CASE}Widget extends ConsumerWidget {
  final String? id;
  final String? label;
  final VoidCallback? onPressed;
  
  const ${PASCAL_CASE}Widget({
    Key? key,
    this.id,
    this.label,
    this.onPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(${CAMEL_CASE}StateProvider);
    
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label ?? '${PASCAL_CASE} Component',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text('State: \$state'),
          if (onPressed != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onPressed,
              child: const Text('Action'),
            ),
          ],
        ],
      ),
    );
  }
}
EOF

    cat > "$BASE_DIR/presentation/providers/${FEATURE_NAME}_ui_providers.dart" << EOF
// ${PASCAL_CASE} UI Providers
// Riverpod providers specific to UI state

import 'package:flutter_riverpod/flutter_riverpod.dart';

// UI state providers
final ${CAMEL_CASE}FilterProvider = StateProvider<String>((ref) => '');

final ${CAMEL_CASE}SortOrderProvider = StateProvider<SortOrder>((ref) => SortOrder.asc);

enum SortOrder { asc, desc }
EOF

  elif [[ "$FEATURE_TYPE" != "service-only" ]]; then
    # Create screens for full features
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('${PASCAL_CASE}s'),
      ),
      body: const Center(
        child: Text('${PASCAL_CASE} List Screen'),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('${PASCAL_CASE} Details'),
      ),
      body: const Center(
        child: Text('${PASCAL_CASE} Detail Screen'),
      ),
    );
  }
}
EOF

    cat > "$BASE_DIR/presentation/widgets/${FEATURE_NAME}_list_item.dart" << EOF
// ${PASCAL_CASE} List Item
// Widget that displays a single ${CAMEL_CASE} in a list

import 'package:flutter/material.dart';

class ${PASCAL_CASE}ListItem extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  
  const ${PASCAL_CASE}ListItem({
    Key? key,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }
}
EOF

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
fi

# Test Files (if enabled)
if [[ "$WITH_TESTS" == "yes" && "$WITH_REPOSITORY" == "yes" && "$FEATURE_TYPE" != "ui-only" && "$FEATURE_TYPE" != "service-only" ]]; then
  mkdir -p "test/features/$FEATURE_NAME/data/models"
  mkdir -p "test/features/$FEATURE_NAME/domain/usecases"
  
  cat > "test/features/$FEATURE_NAME/data/models/${FEATURE_NAME}_model_test.dart" << EOF
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod_clean_architecture/features/$FEATURE_NAME/data/models/${FEATURE_NAME}_model.dart';
import 'package:flutter_riverpod_clean_architecture/features/$FEATURE_NAME/domain/entities/${FEATURE_NAME}_entity.dart';

void main() {
  final ${CAMEL_CASE}Model = ${PASCAL_CASE}Model(
    id: 'test-id',
  );

  test('should be a subclass of ${PASCAL_CASE}Entity', () {
    expect(${CAMEL_CASE}Model, isA<${PASCAL_CASE}Entity>());
  });

  group('fromJson', () {
    test('should return a valid model when JSON data is valid', () {
      final Map<String, dynamic> jsonMap = {
        'id': 'test-id',
      };
      
      final result = ${PASCAL_CASE}Model.fromJson(jsonMap);
      
      expect(result, ${CAMEL_CASE}Model);
    });
  });

  group('toJson', () {
    test('should return a JSON map with proper data', () {
      final result = ${CAMEL_CASE}Model.toJson();
      
      final expectedMap = {
        'id': 'test-id',
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
  late Mock${PASCAL_CASE}Repository mockRepository;

  setUp(() {
    mockRepository = Mock${PASCAL_CASE}Repository();
    usecase = GetAll${PASCAL_CASE}s(mockRepository);
  });

  final testEntities = [
    ${PASCAL_CASE}Entity(id: 'test-id-1'),
    ${PASCAL_CASE}Entity(id: 'test-id-2'),
  ];

  test('should get all ${CAMEL_CASE}s from the repository', () async {
    when(mockRepository.getAll${PASCAL_CASE}s())
        .thenAnswer((_) async => Right(testEntities));
    
    final result = await usecase(NoParams());
    
    expect(result, Right(testEntities));
    verify(mockRepository.getAll${PASCAL_CASE}s());
    verifyNoMoreInteractions(mockRepository);
  });
}
EOF
fi

# Documentation (if enabled)
if [[ "$WITH_DOCS" == "yes" ]]; then
  mkdir -p "docs/features"
  
  if [[ "$FEATURE_TYPE" == "ui-only" ]]; then
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

\`\`\`dart
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
\`\`\`

## Implementation Notes

- The component uses Riverpod for internal state management
- Designed to be easily configurable and adaptable
EOF

  elif [[ "$FEATURE_TYPE" == "service-only" ]]; then
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

\`\`\`dart
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
\`\`\`

## Implementation Notes

- The service is initialized lazily through Riverpod providers
- Configuration can be customized through the config provider
EOF

  elif [[ "$WITH_REPOSITORY" == "no" ]]; then
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

\`\`\`dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:your_app/features/${FEATURE_NAME}/providers/${FEATURE_NAME}_providers.dart';

// Access data
final items = ref.watch(${CAMEL_CASE}DataProvider);

// Update state
ref.read(${CAMEL_CASE}NotifierProvider.notifier).loadItems();
\`\`\`

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

# Make script executable
chmod +x "$0"

# Print success message based on feature type
if [[ "$FEATURE_TYPE" == "ui-only" ]]; then
    echo -e "\n${GREEN}✅ UI Component feature '${FEATURE_NAME}' created successfully!${NC}"
    echo -e "Created component structure in ${CYAN}lib/features/${FEATURE_NAME}/${NC}"
elif [[ "$FEATURE_TYPE" == "service-only" ]]; then
    echo -e "\n${GREEN}✅ Service feature '${FEATURE_NAME}' created successfully!${NC}"
    echo -e "Created service structure in ${CYAN}lib/features/${FEATURE_NAME}/${NC}"
elif [[ "$WITH_REPOSITORY" == "no" ]]; then
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

exit 0
