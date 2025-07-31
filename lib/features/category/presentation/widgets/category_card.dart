import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_todo/core/domain/entities/category_entity.dart';
import 'package:supabase_todo/core/utils/dialog_utils.dart';
import 'package:supabase_todo/features/category/presentation/bloc/category_bloc.dart';
import 'package:supabase_todo/features/category/presentation/bloc/category_events.dart';

class CategoryCard extends StatelessWidget {
  final CategoryEntity category;
  final String userId;

  const CategoryCard({super.key, required this.category, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      child: ListTile(
        title: Text(
          category.name,
          style: TextStyle(
            fontWeight: FontWeight.bold,

            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),

        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: Theme.of(context).primaryColor),
              onPressed: () {
                context.push('/categories/form', extra: category);
              },
            ),
            IconButton(
              icon: Icon(
                Icons.delete,
                color: Theme.of(context).colorScheme.error,
              ),
              onPressed: () {
                DialogUtils.showDeleteDialog(
                  context,
                  'Delete Category',
                  'Are you sure you want to delete "${category.name}"?',
                  () {
                    context.read<CategoryBloc>().add(
                      DeleteCategoryEvent(category.id, userId),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
