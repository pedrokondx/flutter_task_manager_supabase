import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class AttachmentEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadAttachmentsEvent extends AttachmentEvent {
  final String taskId;
  LoadAttachmentsEvent(this.taskId);

  @override
  List<Object?> get props => [taskId];
}

class CreateAttachmentEvent extends AttachmentEvent {
  final String userId;
  final String taskId;
  final File file;
  final String type;
  final String fileName;

  CreateAttachmentEvent({
    required this.userId,
    required this.taskId,
    required this.file,
    required this.type,
    required this.fileName,
  });

  @override
  List<Object?> get props => [taskId, fileName, file, type, userId];
}

class DeleteAttachmentEvent extends AttachmentEvent {
  final String attachmentId;
  final String taskId;

  DeleteAttachmentEvent({required this.attachmentId, required this.taskId});

  @override
  List<Object?> get props => [attachmentId, taskId];
}

class ClearAttachmentsEvent extends AttachmentEvent {}
