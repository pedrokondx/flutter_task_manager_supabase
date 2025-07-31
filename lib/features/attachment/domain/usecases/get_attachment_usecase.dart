import 'package:supabase_todo/features/attachment/domain/entities/attachment_entity.dart';
import 'package:supabase_todo/features/attachment/domain/repositories/attachment_repository.dart';

class GetAttachmentsUsecase {
  final AttachmentRepository repository;

  GetAttachmentsUsecase(this.repository);

  Future<List<AttachmentEntity>> call(String taskId) {
    return repository.getAttachments(taskId);
  }
}
