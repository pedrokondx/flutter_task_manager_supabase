import 'dart:io';

import 'package:supabase_todo/features/attachment/domain/entities/attachment_entity.dart';
import 'package:supabase_todo/features/attachment/domain/repositories/attachment_repository.dart';

class CreateAttachmentUsecase {
  final AttachmentRepository repository;

  CreateAttachmentUsecase(this.repository);

  Future<AttachmentEntity> call({
    required String userId,
    required String taskId,
    required File file,
    required String type,
    required String fileName,
  }) {
    return repository.createAttachment(
      userId: userId,
      taskId: taskId,
      file: file,
      type: type,
      fileName: fileName,
    );
  }
}
