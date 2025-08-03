import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_todo/features/attachment/domain/entities/attachment_entity.dart';
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
    final result = await createAttachment(
      userId: event.userId,
      taskId: event.taskId,
      file: event.file,
      type: event.type,
      fileName: event.fileName,
    );
    result.fold((failure) => emit(AttachmentError(failure.message)), (
      newEntity,
    ) {
      final currentList = state is AttachmentsLoaded
          ? (state as AttachmentsLoaded).attachments
          : <AttachmentEntity>[];

      emit(AttachmentOperationSuccess('Attachment added successfully'));

      emit(AttachmentsLoaded(event.taskId, [...currentList, newEntity]));
    });
  }

  Future<void> _onDeleteAttachment(
    DeleteAttachmentEvent event,
    Emitter<AttachmentState> emit,
  ) async {
    final result = await deleteAttachment(attachmentId: event.attachmentId);
    result.fold((failure) => emit(AttachmentError(failure.message)), (_) {
      List<AttachmentEntity> filtered = [];
      if (state is AttachmentsLoaded) {
        final prev = (state as AttachmentsLoaded).attachments;
        filtered = prev.where((a) => a.id != event.attachmentId).toList();
      }
      emit(AttachmentOperationSuccess('Attachment deleted successfully'));
      emit(AttachmentsLoaded(event.taskId, filtered));
    });
  }

  void _onClearAttachments(
    ClearAttachmentsEvent event,
    Emitter<AttachmentState> emit,
  ) {
    emit(AttachmentsLoaded("", []));
  }
}
