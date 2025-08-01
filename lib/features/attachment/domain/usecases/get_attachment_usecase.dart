import 'package:dartz/dartz.dart';
import 'package:supabase_todo/features/attachment/domain/entities/attachment_entity.dart';
import 'package:supabase_todo/features/attachment/domain/exceptions/attachment_exception.dart';
import 'package:supabase_todo/features/attachment/domain/repositories/attachment_repository.dart';

class GetAttachmentsUsecase {
  final AttachmentRepository repository;

  GetAttachmentsUsecase(this.repository);

  Future<Either<AttachmentException, List<AttachmentEntity>>> call(
    String taskId,
  ) {
    return repository.getAttachments(taskId);
  }
}
