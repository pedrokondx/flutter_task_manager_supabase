import 'package:flutter/material.dart';

class DueDatePicker extends StatelessWidget {
  final DateTime? dueDate;
  final bool isLoading;
  final Function(DateTime?)? onDateSelected;
  final Function()? onClear;
  const DueDatePicker({
    super.key,
    this.dueDate,
    this.isLoading = false,
    this.onDateSelected,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              dueDate == null
                  ? 'No due date selected'
                  : 'Due: ${dueDate!.toLocal().toString().split(' ')[0]}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          TextButton(
            onPressed: isLoading
                ? null
                : () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: dueDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                    );
                    if (picked != null) {
                      onDateSelected?.call(picked);
                    }
                  },
            child: const Text('Pick Date'),
          ),
          if (dueDate != null)
            IconButton(
              onPressed: isLoading ? null : () => onClear?.call(),
              icon: const Icon(Icons.clear),
            ),
        ],
      ),
    );
  }
}
