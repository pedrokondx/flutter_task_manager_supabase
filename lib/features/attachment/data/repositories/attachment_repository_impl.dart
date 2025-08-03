import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:supabase_todo/features/attachment/data/datasources/attachment_datasource.dart';
import 'package:supabase_todo/features/attachment/domain/entities/attachment_entity.dart';
import 'package:supabase_todo/features/attachment/domain/exceptions/attachment_exception.dart';
import 'package:supabase_todo/features/attachment/domain/repositories/attachment_repository.dart';

class AttachmentRepositoryImpl implements AttachmentRepository {
  final AttachmentDatasource datasource;

  AttachmentRepositoryImpl(this.datasource);

  @override
  Future<Either<AttachmentException, List<AttachmentEntity>>> getAttachments(
    String taskId,
  ) async {
    try {
      final dtos = await datasource.getAttachments(taskId);
      return Right(dtos.map((dto) => dto.toEntity()).toList());
    } catch (e) {
      if (e is AttachmentException) {
        return Left(e);
      }
      return Left(AttachmentException.attachmentFetchFailure(e));
    }
  }

  @override
  Future<Either<AttachmentException, AttachmentEntity>> createAttachment({
    required String userId,
    required String taskId,
    required File file,
    required String type,
    required String fileName,
  }) async {
    try {
      final dto = await datasource.createAttachment(
        userId: userId,
        taskId: taskId,
        file: file,
        type: type,
        fileName: fileName,
      );
      return Right(dto.toEntity());
    } catch (e) {
      if (e is AttachmentException) {
        return Left(e);
      }

      return Left(AttachmentException.attachmentCreationFailure(e));
    }
  }

  @override
  Future<Either<AttachmentException, void>> deleteAttachment(
    String attachmentId,
  ) async {
    try {
      await datasource.deleteAttachment(attachmentId);
      return const Right(null);
    } catch (e) {
      if (e is AttachmentException) {
        return Left(e);
      }

      return Left(AttachmentException.attachmentDeletionFailure(e));
    }
  }
}
