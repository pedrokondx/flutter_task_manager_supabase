import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_todo/features/category/presentation/bloc/category_bloc.dart';
import 'package:supabase_todo/features/category/presentation/bloc/category_events.dart';
import 'package:supabase_todo/features/category/presentation/bloc/category_state.dart';
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
    context.read<CategoryBloc>().add(LoadCategories(widget.userId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/categories/form'),
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: BlocBuilder<CategoryBloc, CategoryState>(
          builder: (context, state) {
            if (state is CategoryLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is CategoryLoaded) {
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
                    child: categories.isEmpty
                        ? const Center(child: Text("No categories found"))
                        : ListView.builder(
                            itemCount: categories.length,
                            itemBuilder: (_, i) {
                              final category = categories[i];
                              return CategoryCard(
                                category: category,
                                userId: widget.userId,
                              );
                            },
                          ),
                  ),
                ],
              );
            }

            return const Center(child: Text("No category found"));
          },
        ),
      ),
    );
  }
}
