import 'package:supabase_todo/core/domain/entities/category_entity.dart';

class CategoryDTO {
  final String id;
  final String userId;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;

  CategoryDTO({
    required this.id,
    required this.userId,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CategoryDTO.fromMap(Map<String, dynamic> map) {
    return CategoryDTO(
      id: map['id'] ?? '',
      userId: map['user_id'] ?? '',
      name: map['name'] ?? '',
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
      'name': name,
      'updated_at': updatedAt.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };

    return map;
  }

  CategoryEntity toEntity() => CategoryEntity(
    id: id,
    userId: userId,
    name: name,
    createdAt: createdAt,
    updatedAt: updatedAt,
  );

  factory CategoryDTO.fromEntity(CategoryEntity entity) => CategoryDTO(
    id: entity.id,
    userId: entity.userId,
    name: entity.name,
    createdAt: entity.createdAt,
    updatedAt: entity.updatedAt,
  );

  CategoryDTO copyWith({
    String? id,
    String? userId,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CategoryDTO(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,

      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
