import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:supabase_todo/features/attachment/domain/entities/attachment_entity.dart';
import 'package:supabase_todo/features/attachment/domain/exceptions/attachment_exception.dart';

abstract class AttachmentRepository {
  Future<Either<AttachmentException, List<AttachmentEntity>>> getAttachments(
    String taskId,
  );
  Future<Either<AttachmentException, AttachmentEntity>> createAttachment({
    required String userId,
    required String taskId,
    required File file,
    required String type,
    required String fileName,
  });
  Future<Either<AttachmentException, void>> deleteAttachment(
    String attachmentId,
  );
}
