import 'package:dartz/dartz.dart';
import 'package:supabase_todo/features/attachment/domain/exceptions/attachment_exception.dart';
import 'package:supabase_todo/features/attachment/domain/repositories/attachment_repository.dart';

class DeleteAttachmentUsecase {
  final AttachmentRepository repository;

  DeleteAttachmentUsecase(this.repository);

  Future<Either<AttachmentException, void>> call({
    required String attachmentId,
  }) {
    return repository.deleteAttachment(attachmentId);
  }
}
