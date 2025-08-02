import 'package:flutter/material.dart';
import 'package:supabase_todo/features/task/domain/entities/task_status.dart';

class FilterDropdowns extends StatelessWidget {
  final String selectedCategory;
  final TaskStatus? selectedStatus;
  final Map<String, String> statusOptions;
  final List<String> categories;
  final Function(String) onCategoryChanged;
  final Function(TaskStatus?) onStatusChanged;

  const FilterDropdowns({
    super.key,
    required this.selectedCategory,
    required this.selectedStatus,
    required this.statusOptions,
    required this.categories,
    required this.onCategoryChanged,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<String>(
            value: selectedCategory,
            decoration: const InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: categories.map((cat) {
              return DropdownMenuItem(value: cat, child: Text(cat));
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                onCategoryChanged(value);
              }
            },
          ),
        ),
        const SizedBox(width: 16),

        Expanded(
          child: DropdownButtonFormField<TaskStatus?>(
            value: selectedStatus,
            decoration: const InputDecoration(
              labelText: 'Status',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: statusOptions.entries.map((entry) {
              return DropdownMenuItem(
                value: TaskStatus.fromString(entry.key),
                child: Text(entry.value),
              );
            }).toList(),

            onChanged: (value) {
              if (value != null) {
                onStatusChanged(value);
              }
            },
          ),
        ),
      ],
    );
  }
}
