import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_todo/features/attachment/data/datasources/attachment_datasource.dart';
import 'package:supabase_todo/features/attachment/data/dtos/attachment_dto.dart';
import 'package:supabase_todo/features/attachment/domain/exceptions/attachment_exception.dart';
import 'package:supabase_todo/features/attachment/data/services/filename_sanitizer.dart';

class AttachmentSupabaseDatasource implements AttachmentDatasource {
  final SupabaseClient supabase;

  AttachmentSupabaseDatasource(this.supabase);
  @override
  Future<List<AttachmentDTO>> getAttachments(String taskId) async {
    try {
      final data = await supabase
          .from('attachments')
          .select()
          .eq('task_id', taskId)
          .order('created_at');

      final List<AttachmentDTO> attachments = [];

      for (final map in data) {
        final dto = AttachmentDTO.fromMap(map);
        final rawUrl = dto.fileUrl;

        final marker = '/attachments/';
        final idx = rawUrl.indexOf(marker);
        if (idx < 0) {
          attachments.add(dto);
          continue;
        }
        final storagePath = rawUrl.substring(idx + marker.length);

        final signed = await supabase.storage
            .from('attachments')
            .createSignedUrl(storagePath, 60 * 10);

        attachments.add(dto.copyWith(fileUrl: signed));
      }

      return attachments;
    } catch (e) {
      throw AttachmentException.attachmentFetchFailure(e);
    }
  }

  @override
  Future<AttachmentDTO> createAttachment({
    required String userId,
    required String taskId,
    required File file,
    required String type,
    required String fileName,
  }) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final safeFileName = sanitizeFileName(fileName);
      final extension = path.extension(safeFileName);

      final dirPath = '$userId/';

      // List everything in that user’s folder
      final storage = supabase.storage.from('attachments');
      final existing = await storage.list(path: dirPath);

      //  Build a candidate name, bumping “(1)”, “(2)”, etc if needed
      String candidateName = '${taskId}_$timestamp$extension';
      int counter = 1;
      while (existing.any((f) => f.name == candidateName)) {
        candidateName = '${taskId}_${timestamp}_($counter)$extension';
        counter++;
      }
      final uniqueFileName = '$dirPath$candidateName';

      await storage.upload(uniqueFileName, file);
      final fileUrl = storage.getPublicUrl(uniqueFileName);

      final dtoMap = {
        'task_id': taskId,
        'file_url': fileUrl,
        'type': type,
        'file_name': fileName,
        'created_at': DateTime.now().toIso8601String(),
      };
      final response = await supabase
          .from('attachments')
          .insert(dtoMap)
          .select()
          .single();

      return AttachmentDTO.fromMap(response);
    } catch (e) {
      throw AttachmentException.attachmentCreationFailure(e);
    }
  }

  @override
  Future<void> deleteAttachment(String attachmentId) async {
    try {
      final attachment = await supabase
          .from('attachments')
          .select('file_url')
          .eq('id', attachmentId)
          .single();

      final fileUrl = attachment['file_url'] as String;
      final fileUrlPath = fileUrl.split('/attachments/').last;

      final removeResult = await supabase.storage.from('attachments').remove([
        fileUrlPath,
      ]);
      if (removeResult.isEmpty) {
        throw AttachmentException.attachmentDeletionFailure('File not found');
      }
      await supabase.from('attachments').delete().eq('id', attachmentId);
    } catch (e) {
      throw AttachmentException.attachmentDeletionFailure(e);
    }
  }
}
