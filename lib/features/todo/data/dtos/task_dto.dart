import 'package:supabase_todo/features/todo/domain/entities/task_entity.dart';

class TaskDTO {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final String? categoryId;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  TaskDTO({
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

  factory TaskDTO.fromMap(Map<String, dynamic> map) {
    return TaskDTO(
      id: map['id'] ?? '',
      userId: map['user_id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'],
      dueDate: map['due_date'] != null ? DateTime.parse(map['due_date']) : null,
      categoryId: map['category_id'],
      status: map['status'] ?? 'to_do',
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'due_date': dueDate?.toIso8601String(),
      'category_id': categoryId,
      'status': status,
      'updated_at': updatedAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };

    return map;
  }

  TaskEntity toEntity() => TaskEntity(
    id: id,
    userId: userId,
    title: title,
    description: description,
    dueDate: dueDate,
    categoryId: categoryId,
    status: status,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  factory TaskDTO.fromEntity(TaskEntity entity) => TaskDTO(
    id: entity.id,
    userId: entity.userId,
    title: entity.title,
    description: entity.description,
    dueDate: entity.dueDate,
    categoryId: entity.categoryId,
    status: entity.status,
    createdAt: entity.createdAt,
    updatedAt: entity.updatedAt,
  );

  TaskDTO copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    DateTime? dueDate,
    String? categoryId,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaskDTO(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      categoryId: categoryId ?? this.categoryId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
