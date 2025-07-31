import 'package:supabase_todo/features/attachment/domain/repositories/attachment_repository.dart';

class DeleteAttachmentUsecase {
  final AttachmentRepository repository;

  DeleteAttachmentUsecase(this.repository);

  Future<void> call(String attachmentId) {
    return repository.deleteAttachment(attachmentId);
  }
}
