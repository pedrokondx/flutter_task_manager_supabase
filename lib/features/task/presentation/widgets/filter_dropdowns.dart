import 'package:flutter/material.dart';
import 'package:supabase_todo/features/task/domain/entities/task_status.dart';

class FilterDropdowns extends StatelessWidget {
  final List<String> categories;
  final String? selectedCategory;
  final Function(String?) onCategoryChanged;
  final Map<String, String> statusOptions;
  final TaskStatus? selectedStatus;
  final Function(TaskStatus?) onStatusChanged;

  const FilterDropdowns({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onCategoryChanged,
    required this.statusOptions,
    required this.selectedStatus,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField(
            value: selectedCategory,
            decoration: const InputDecoration(labelText: 'Category'),
            icon: selectedCategory != null
                ? GestureDetector(
                    onTap: () => onCategoryChanged(null),
                    behavior: HitTestBehavior.opaque,
                    child: const Padding(
                      padding: EdgeInsets.only(right: 8.0),
                      child: Icon(Icons.clear),
                    ),
                  )
                : const Icon(Icons.arrow_drop_down),
            items: categories.map((cat) {
              return DropdownMenuItem(value: cat, child: Text(cat));
            }).toList(),
            onChanged: (value) {
              onCategoryChanged(value);
            },
          ),
        ),

        const SizedBox(width: 16),
        Expanded(
          child: DropdownButtonFormField(
            value: selectedStatus,
            decoration: const InputDecoration(labelText: 'Status'),
            icon: selectedStatus != null
                ? GestureDetector(
                    onTap: () => onStatusChanged(null),
                    behavior: HitTestBehavior.opaque,
                    child: const Padding(
                      padding: EdgeInsets.only(right: 8.0),
                      child: Icon(Icons.clear),
                    ),
                  )
                : const Icon(Icons.arrow_drop_down),
            items: statusOptions.entries.map((entry) {
              final status = TaskStatus.fromString(entry.key);
              return DropdownMenuItem<TaskStatus?>(
                value: status,
                child: Text(entry.value),
              );
            }).toList(),
            onChanged: (value) {
              onStatusChanged(value);
            },
          ),
        ),
      ],
    );
  }
}
