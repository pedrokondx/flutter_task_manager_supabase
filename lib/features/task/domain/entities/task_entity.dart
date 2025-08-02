import 'package:equatable/equatable.dart';
import 'package:supabase_todo/features/task/domain/entities/task_status.dart';

class TaskEntity extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final String? categoryId;
  final TaskStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TaskEntity({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    this.dueDate,
    this.categoryId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    title,
    description,
    dueDate,
    categoryId,
    status,
    createdAt,
    updatedAt,
  ];
}
