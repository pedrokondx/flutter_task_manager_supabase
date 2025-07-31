import 'package:flutter/material.dart';
import 'package:supabase_todo/features/task/domain/entities/task_entity.dart';

class TaskCard extends StatefulWidget {
  final TaskEntity task;
  final String? categoryName;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const TaskCard({
    super.key,
    required this.task,
    this.categoryName,
    this.onTap,
    this.onDelete,
  });

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  Color _getStatusColor(String status) {
    switch (status) {
      case 'to_do':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'done':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'to_do':
        return 'To Do';
      case 'in_progress':
        return 'In Progress';
      case 'done':
        return 'Done';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.task.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        decoration: widget.task.status == 'done'
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                  ),
                  if (widget.onDelete != null)
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: widget.onDelete,
                      tooltip: 'Delete task',
                    ),
                ],
              ),

              if (widget.task.description != null) ...[
                const SizedBox(height: 8),
                Text(
                  widget.task.description!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],

              const SizedBox(height: 12),

              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(
                        widget.task.status,
                      ).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _getStatusColor(
                          widget.task.status,
                        ).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      _getStatusText(widget.task.status),
                      style: TextStyle(
                        fontSize: 12,
                        color: _getStatusColor(widget.task.status),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  if (widget.categoryName != null) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.purple.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.purple.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Text(
                        widget.categoryName!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.purple,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],

                  const Spacer(),

                  if (widget.task.dueDate != null) ...[
                    Icon(Icons.schedule, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      widget.task.dueDate!.toLocal().toString().split(' ')[0],
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
