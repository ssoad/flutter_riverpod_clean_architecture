// Base Use Case Interface
// Defines the contract for all use cases in the application

import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../error/failures.dart';

/// Base interface for all use cases
/// 
/// [Type] - The return type of the use case
/// [Params] - The parameters required by the use case
abstract class UseCase<Type, Params> {
  /// Execute the use case with the given parameters
  Future<Either<Failure, Type>> call(Params params);
}

/// Use case that doesn't require any parameters
class NoParams extends Equatable {
  @override
  List<Object> get props => [];
}