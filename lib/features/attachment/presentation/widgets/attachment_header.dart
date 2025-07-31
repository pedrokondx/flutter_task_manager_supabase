import 'package:flutter/material.dart';

class AttachmentHeader extends StatelessWidget {
  final VoidCallback onAddAttachment;
  const AttachmentHeader({super.key, required this.onAddAttachment});

  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }
}
