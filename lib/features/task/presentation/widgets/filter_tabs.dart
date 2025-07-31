import 'package:flutter/material.dart';

class FilterTabs extends StatelessWidget {
  final String selected;
  final Map<String, int> counts;
  final Function(String) onChanged;

  const FilterTabs({
    super.key,
    required this.selected,
    required this.counts,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final filters = ['all', 'to_do', 'in_progress', 'done'];

    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (_, i) {
          final key = filters[i];
          final label = _label(key);
          final count = counts[key] ?? 0;
          final isSelected = selected == key;

          return GestureDetector(
            onTap: () => onChanged(key),
            child: Chip(
              label: Text(
                '$label $count',
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : Theme.of(context).colorScheme.primary,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              backgroundColor: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemCount: filters.length,
      ),
    );
  }

  String _label(String key) {
    switch (key) {
      case 'all':
        return 'All';
      case 'to_do':
        return 'To Do';
      case 'in_progress':
        return 'In Progress';
      case 'done':
        return 'Done';
      default:
        return key;
    }
  }
}
