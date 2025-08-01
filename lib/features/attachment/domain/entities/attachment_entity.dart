import 'package:equatable/equatable.dart';

class AttachmentEntity extends Equatable {
  final String id;
  final String taskId;
  final String fileUrl;
  final String type; // 'image' or 'video'
  final String fileName;
  final DateTime createdAt;

  const AttachmentEntity({
    required this.id,
    required this.taskId,
    required this.fileUrl,
    required this.type,
    required this.fileName,
    required this.createdAt,
  });
  @override
  List<Object?> get props => [id, taskId, fileUrl, type, fileName, createdAt];
}
