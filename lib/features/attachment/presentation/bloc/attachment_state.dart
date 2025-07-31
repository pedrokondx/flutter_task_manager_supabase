import 'package:equatable/equatable.dart';
import 'package:supabase_todo/features/attachment/domain/entities/attachment_entity.dart';

abstract class AttachmentState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AttachmentsLoading extends AttachmentState {}

class AttachmentsLoaded extends AttachmentState {
  final String taskId;
  final List<AttachmentEntity> attachments;

  AttachmentsLoaded(this.taskId, this.attachments);

  @override
  List<Object?> get props => [taskId, attachments];
}

class AttachmentOperationLoading extends AttachmentState {}

class AttachmentOperationSuccess extends AttachmentState {
  final String message;
  AttachmentOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class AttachmentError extends AttachmentState {
  final String message;
  AttachmentError(this.message);

  @override
  List<Object?> get props => [message];
}
