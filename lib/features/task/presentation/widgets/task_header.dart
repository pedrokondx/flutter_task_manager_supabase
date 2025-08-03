import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TaskHeader extends StatelessWidget {
  final VoidCallback onNewTask;
  final VoidCallback onCategoryPressed;
  final VoidCallback onLogoutPressed;

  const TaskHeader({
    super.key,
    required this.onNewTask,
    required this.onCategoryPressed,
    required this.onLogoutPressed,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('EEEE, d MMM').format(DateTime.now());

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("My Tasks", style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                today,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ],
          ),
          const Spacer(),

          const SizedBox(width: 8),
          Tooltip(
            message: "Categories",
            child: IconButton(
              onPressed: onCategoryPressed,
              icon: Icon(Icons.category_outlined),
            ),
          ),
          const SizedBox(width: 8),
          Tooltip(
            message: "Logout",
            child: IconButton(
              onPressed: onLogoutPressed,
              icon: Icon(Icons.logout),
            ),
          ),
          const SizedBox(width: 8),
          Tooltip(
            message: "New Task",
            child: IconButton(onPressed: onNewTask, icon: Icon(Icons.add)),
          ),
        ],
      ),
    );
  }
}
