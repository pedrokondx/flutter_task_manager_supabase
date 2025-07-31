import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_todo/features/todo/domain/entities/attachment_entity.dart';

class AttachmentPreview extends StatelessWidget {
  final List<AttachmentEntity> attachments;
  final List<XFile> pendingFiles;
  final Function(AttachmentEntity) onDeleteAttachment;
  final Function(XFile) onDeletePendingFile;
  final Function(AttachmentEntity) onViewAttachment;
  final VoidCallback onAddAttachment;

  const AttachmentPreview({
    super.key,
    required this.attachments,
    required this.pendingFiles,
    required this.onDeleteAttachment,
    required this.onDeletePendingFile,
    required this.onViewAttachment,
    required this.onAddAttachment,
  });

  @override
  Widget build(BuildContext context) {
    final totalItems = attachments.length + pendingFiles.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.attachment),
            const SizedBox(width: 8),
            Text('Attachments', style: Theme.of(context).textTheme.titleMedium),
            const Spacer(),
            IconButton(
              onPressed: onAddAttachment,
              icon: const Icon(Icons.add_circle_outline),
              tooltip: 'Add attachment',
            ),
          ],
        ),
        if (totalItems > 0) ...[
          const SizedBox(height: 8),
          SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: totalItems + 1,
              itemBuilder: (context, index) {
                if (index == totalItems) {
                  return _buildAddButton(context);
                }

                if (index < attachments.length) {
                  return _buildAttachmentThumbnail(
                    context,
                    attachments[index],
                    onDeleteAttachment,
                    onViewAttachment,
                  );
                } else {
                  final pendingIndex = index - attachments.length;
                  return _buildPendingFileThumbnail(
                    context,
                    pendingFiles[pendingIndex],
                    onDeletePendingFile,
                  );
                }
              },
            ),
          ),
        ] else
          Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.attachment, size: 48, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text(
                    'No attachments yet',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return Container(
      width: 70,
      margin: const EdgeInsets.only(right: 8),
      child: InkWell(
        onTap: onAddAttachment,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.add, size: 32, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildAttachmentThumbnail(
    BuildContext context,
    AttachmentEntity attachment,
    Function(AttachmentEntity) onDelete,
    Function(AttachmentEntity) onView,
  ) {
    return Container(
      width: 70,
      margin: const EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          InkWell(
            onTap: () => onView(attachment),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: attachment.type == 'image'
                    ? Image.network(
                        attachment.fileUrl,
                        width: 70,
                        height: 70,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.broken_image),
                        ),
                      )
                    : Container(
                        width: 70,
                        height: 70,
                        color: Colors.grey[200],
                        child: const Icon(
                          Icons.play_circle_filled,
                          size: 32,
                          color: Colors.blue,
                        ),
                      ),
              ),
            ),
          ),
          Positioned(
            top: 2,
            right: 2,
            child: InkWell(
              onTap: () => onDelete(attachment),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 12, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingFileThumbnail(
    BuildContext context,
    XFile file,
    Function(XFile) onDelete,
  ) {
    return Container(
      width: 70,
      margin: const EdgeInsets.only(right: 8),
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange[300]!),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child:
                  file.path.toLowerCase().contains(
                    RegExp(r'\.(jpg|jpeg|png|gif)'),
                  )
                  ? Image.file(
                      File(file.path),
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      width: 70,
                      height: 70,
                      color: Colors.orange[100],
                      child: const Icon(
                        Icons.videocam,
                        size: 32,
                        color: Colors.orange,
                      ),
                    ),
            ),
          ),
          Positioned(
            top: 2,
            right: 2,
            child: InkWell(
              onTap: () => onDelete(file),
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.orange,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, size: 12, color: Colors.white),
              ),
            ),
          ),

          const Positioned(
            bottom: 2,
            left: 2,
            child: Icon(Icons.schedule, size: 16, color: Colors.orange),
          ),
        ],
      ),
    );
  }
}
