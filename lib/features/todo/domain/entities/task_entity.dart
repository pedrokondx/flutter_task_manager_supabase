class TaskEntity {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final String? categoryId;
  final String status; // 'to_do', 'in_progress', 'done'
  final DateTime createdAt;
  final DateTime updatedAt;

  TaskEntity({
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
}
