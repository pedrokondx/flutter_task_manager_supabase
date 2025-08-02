import 'package:supabase_todo/features/attachment/domain/entities/attachment_entity.dart';

class AttachmentDTO {
  final String id;
  final String taskId;
  final String fileUrl;
  final String type;
  final String fileName;
  final DateTime createdAt;

  AttachmentDTO({
    required this.id,
    required this.taskId,
    required this.fileUrl,
    required this.type,
    required this.fileName,
    required this.createdAt,
  });

  factory AttachmentDTO.fromMap(Map<String, dynamic> map) {
    return AttachmentDTO(
      id: map['id'] ?? '',
      taskId: map['task_id'] ?? '',
      fileUrl: map['file_url'] ?? '',
      type: map['type'] ?? '',
      fileName: map['file_name'] ?? '',
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'task_id': taskId,
      'file_url': fileUrl,
      'type': type,
      'file_name': fileName,
      'created_at': createdAt.toIso8601String(),
    };
  }

  AttachmentEntity toEntity() => AttachmentEntity(
    id: id,
    taskId: taskId,
    fileUrl: fileUrl,
    type: type,
    fileName: fileName,
    createdAt: createdAt,
  );

  factory AttachmentDTO.fromEntity(AttachmentEntity entity) => AttachmentDTO(
    id: entity.id,
    taskId: entity.taskId,
    fileUrl: entity.fileUrl,
    type: entity.type,
    fileName: entity.fileName,
    createdAt: entity.createdAt,
  );

  AttachmentDTO copyWith({
    String? id,
    String? taskId,
    String? fileUrl,
    String? type,
    String? fileName,
    DateTime? createdAt,
  }) {
    return AttachmentDTO(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      fileUrl: fileUrl ?? this.fileUrl,
      type: type ?? this.type,
      fileName: fileName ?? this.fileName,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
