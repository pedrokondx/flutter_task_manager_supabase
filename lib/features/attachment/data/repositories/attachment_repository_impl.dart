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
    } on AttachmentException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        AttachmentException(
          message: 'Unknown error fetching attachments',
          code: 'UNKNOWN_GET_ATTACHMENTS',
          inner: e,
        ),
      );
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
    } on AttachmentException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        AttachmentException(
          message: 'Unknown error creating attachment',
          code: 'UNKNOWN_CREATE_ATTACHMENT',
          inner: e,
        ),
      );
    }
  }

  @override
  Future<Either<AttachmentException, void>> deleteAttachment(
    String attachmentId,
  ) async {
    try {
      await datasource.deleteAttachment(attachmentId);
      return const Right(null);
    } on AttachmentException catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        AttachmentException(
          message: 'Unknown error deleting attachment',
          code: 'UNKNOWN_DELETE_ATTACHMENT',
          inner: e,
        ),
      );
    }
  }
}
