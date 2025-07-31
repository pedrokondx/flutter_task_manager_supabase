import 'dart:io';
import 'package:supabase_todo/features/todo/domain/entities/attachment_entity.dart';

abstract class AttachmentRepository {
  Future<List<AttachmentEntity>> getAttachments(String taskId);
  Future<AttachmentEntity> createAttachment({
    required String userId,
    required String taskId,
    required File file,
    required String type,
    required String fileName,
  });
  Future<void> deleteAttachment(String attachmentId);
}
