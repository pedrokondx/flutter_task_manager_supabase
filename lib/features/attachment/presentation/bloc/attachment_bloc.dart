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
    on<ClearAttachmentsEvent>(_onClearAttachments);
  }
  Future<void> _onLoadAttachments(
    LoadAttachmentsEvent event,
    Emitter<AttachmentState> emit,
  ) async {
    emit(AttachmentsLoading());
    final result = await getAttachments(event.taskId);
    result.fold(
      (failure) => emit(AttachmentError(failure.message)),
      (attachments) => emit(AttachmentsLoaded(event.taskId, attachments)),
    );
  }

  Future<void> _onCreateAttachment(
    CreateAttachmentEvent event,
    Emitter<AttachmentState> emit,
  ) async {
    emit(AttachmentOperationLoading());
    final result = await createAttachment(
      userId: event.userId,
      taskId: event.taskId,
      file: event.file,
      type: event.type,
      fileName: event.fileName,
    );
    result.fold((failure) => emit(AttachmentError(failure.message)), (_) {
      emit(AttachmentOperationSuccess('Attachment added successfully'));
      add(LoadAttachmentsEvent(event.taskId));
    });
  }

  Future<void> _onDeleteAttachment(
    DeleteAttachmentEvent event,
    Emitter<AttachmentState> emit,
  ) async {
    emit(AttachmentOperationLoading());
    final result = await deleteAttachment(attachmentId: event.attachmentId);
    result.fold((failure) => emit(AttachmentError(failure.message)), (_) {
      emit(AttachmentOperationSuccess('Attachment deleted successfully'));
      add(LoadAttachmentsEvent(event.taskId));
    });
  }

  void _onClearAttachments(
    ClearAttachmentsEvent event,
    Emitter<AttachmentState> emit,
  ) {
    emit(AttachmentsLoaded("", []));
  }
}
