import 'package:equatable/equatable.dart';

/// Priority level of a [TaskEntity]
enum TaskPriority { low, medium, high }

/// Domain entity representing a single to-do item
class TaskEntity extends Equatable {
  final String id;
  final String title;
  final String? description;
  final bool isCompleted;
  final TaskPriority priority;
  final DateTime createdAt;
  final DateTime? dueDate;

  const TaskEntity({
    required this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    this.priority = TaskPriority.medium,
    required this.createdAt,
    this.dueDate,
  });

  TaskEntity copyWith({
    String? id,
    String? title,
    String? description,
    bool? isCompleted,
    TaskPriority? priority,
    DateTime? createdAt,
    DateTime? dueDate,
    bool clearDueDate = false,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      dueDate: clearDueDate ? null : (dueDate ?? this.dueDate),
    );
  }

  bool get isOverdue =>
      !isCompleted && dueDate != null && dueDate!.isBefore(DateTime.now());

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    isCompleted,
    priority,
    createdAt,
    dueDate,
  ];
}
