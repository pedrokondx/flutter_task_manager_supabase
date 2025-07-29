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
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
              ),
            ],
          ),
          const Spacer(),
          _IconAction(
            icon: Icons.category_outlined,
            tooltip: "Categories",
            onPressed: onCategoryPressed,
          ),
          const SizedBox(width: 8),
          _IconAction(
            icon: Icons.logout,
            tooltip: "Logout",
            onPressed: onLogoutPressed,
          ),
          const SizedBox(width: 8),
          _IconAction(
            icon: Icons.add,
            tooltip: "New Task",
            onPressed: onNewTask,
          ),
        ],
      ),
    );
  }
}

class _IconAction extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _IconAction({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon),
        color: Theme.of(context).colorScheme.primary,
        style: IconButton.styleFrom(
          backgroundColor: Theme.of(
            context,
          ).colorScheme.primary.withValues(alpha: 0.15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
