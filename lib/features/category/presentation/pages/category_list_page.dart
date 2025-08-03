import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_todo/core/utils/dialog_utils.dart';
import 'package:supabase_todo/core/utils/snackbar_utils.dart';
import 'package:supabase_todo/features/category/presentation/bloc/category_cubit.dart';
import 'package:supabase_todo/features/category/presentation/widgets/category_card.dart';

class CategoryListPage extends StatefulWidget {
  final String userId;
  const CategoryListPage({required this.userId, super.key});

  @override
  State<CategoryListPage> createState() => _CategoryListPageState();
}

class _CategoryListPageState extends State<CategoryListPage> {
  @override
  void initState() {
    super.initState();
    context.read<CategoryCubit>().load(widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/categories/form'),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: BlocConsumer<CategoryCubit, CategoryState>(
          listener: (context, state) {
            if (state.errorMessage != null) {
              SnackbarUtils.showError(context, state.errorMessage!);
            } else if (state.lastSuccessMessage != null) {
              SnackbarUtils.showSuccess(context, state.lastSuccessMessage!);
            }
          },
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state.errorMessage != null && state.categories.isEmpty) {
              return Center(child: Text('Error: ${state.errorMessage}'));
            } else if (state.categories.isEmpty) {
              return const Center(child: Text("No categories found"));
            }

            final categories = state.categories;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () => context.pop(),
                      ),
                      Text(
                        "Categories",
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (_, i) {
                      final category = categories[i];
                      return CategoryCard(
                        category: category,
                        userId: widget.userId,
                        onDelete: () {
                          DialogUtils.showDeleteDialog(
                            context,
                            'Delete Category',
                            'Are you sure you want to delete "${category.name}"?',
                            () {
                              context.read<CategoryCubit>().delete(
                                category.id,
                                widget.userId,
                              );
                            },
                          );
                        },

                        onEdit: () {
                          context.push('/categories/form', extra: category);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
