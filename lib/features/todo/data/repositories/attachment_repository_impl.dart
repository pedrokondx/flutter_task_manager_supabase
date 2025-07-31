import 'dart:io';
import 'package:supabase_todo/features/todo/data/datasources/attachment_datasource.dart';
import 'package:supabase_todo/features/todo/domain/entities/attachment_entity.dart';
import 'package:supabase_todo/features/todo/domain/repositories/attachment_repository.dart';

class AttachmentRepositoryImpl implements AttachmentRepository {
  final AttachmentDatasource datasource;

  AttachmentRepositoryImpl(this.datasource);

  @override
  Future<List<AttachmentEntity>> getAttachments(String taskId) async {
    final dtos = await datasource.getAttachments(taskId);
    return dtos.map((dto) => dto.toEntity()).toList();
  }

  @override
  Future<AttachmentEntity> createAttachment({
    required String userId,
    required String taskId,
    required File file,
    required String type,
    required String fileName,
  }) async {
    final dto = await datasource.createAttachment(
      userId: userId,
      taskId: taskId,
      file: file,
      type: type,
      fileName: fileName,
    );
    return dto.toEntity();
  }

  @override
  Future<void> deleteAttachment(String attachmentId) {
    return datasource.deleteAttachment(attachmentId);
  }
}
