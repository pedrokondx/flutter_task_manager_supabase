import 'dart:io';
import 'package:supabase_todo/features/todo/data/dtos/attachment_dto.dart';

abstract class AttachmentDatasource {
  Future<List<AttachmentDTO>> getAttachments(String taskId);
  Future<AttachmentDTO> createAttachment({
    required String userId,
    required String taskId,
    required File file,
    required String type,
    required String fileName,
  });
  Future<void> deleteAttachment(String attachmentId);
}
