import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_todo/features/attachment/domain/usecases/create_attachment_usecase.dart';
import 'package:supabase_todo/features/attachment/domain/usecases/delete_attachment_usecase.dart';
import 'package:supabase_todo/features/attachment/domain/usecases/get_attachment_usecase.dart';
import 'attachment_events.dart';
import 'attachment_state.dart';

class AttachmentBloc extends Bloc<AttachmentEvent, AttachmentState> {
  final GetAttachmentsUsecase getAttachments;
  final CreateAttachmentUsecase createAttachment;
  final DeleteAttachmentUsecase deleteAttachment;
  AttachmentBloc({
    required this.getAttachments,
    required this.createAttachment,
    required this.deleteAttachment,
  }) : super(AttachmentsLoading()) {
    on<LoadAttachmentsEvent>(_onLoadAttachments);
    on<CreateAttachmentEvent>(_onCreateAttachment);
    on<DeleteAttachmentEvent>(_onDeleteAttachment);
  }

  Future<void> _onLoadAttachments(
    LoadAttachmentsEvent event,
    Emitter<AttachmentState> emit,
  ) async {
    emit(AttachmentsLoading());
    try {
      final attachments = await getAttachments(event.taskId);
      emit(AttachmentsLoaded(event.taskId, attachments));
    } catch (e) {
      emit(AttachmentError('Failed to load attachments: \$e'));
    }
  }

  Future<void> _onCreateAttachment(
    CreateAttachmentEvent event,
    Emitter<AttachmentState> emit,
  ) async {
    emit(AttachmentOperationLoading());
    try {
      await createAttachment(
        userId: event.userId,
        taskId: event.taskId,
        file: event.file,
        type: event.type,
        fileName: event.fileName,
      );
      emit(AttachmentOperationSuccess('Attachment added successfully'));
      add(LoadAttachmentsEvent(event.taskId));
    } catch (e) {
      emit(AttachmentError('Failed to create attachment: \$e'));
    }
  }

  Future<void> _onDeleteAttachment(
    DeleteAttachmentEvent event,
    Emitter<AttachmentState> emit,
  ) async {
    emit(AttachmentOperationLoading());
    try {
      await deleteAttachment(event.attachmentId);
      emit(AttachmentOperationSuccess('Attachment deleted successfully'));
      add(LoadAttachmentsEvent(event.taskId));
    } catch (e) {
      emit(AttachmentError('Failed to delete attachment: \$e'));
    }
  }
}
