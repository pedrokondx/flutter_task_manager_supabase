class AttachmentEntity {
  final String id;
  final String taskId;
  final String fileUrl;
  final String type; // 'image' or 'video'
  final String fileName;
  final DateTime createdAt;

  AttachmentEntity({
    required this.id,
    required this.taskId,
    required this.fileUrl,
    required this.type,
    required this.fileName,
    required this.createdAt,
  });
}
