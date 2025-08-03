import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_todo/core/utils/snackbar_utils.dart';
import 'package:supabase_todo/core/validators/title_validator.dart';
import 'package:supabase_todo/core/domain/entities/category_entity.dart';
import 'package:supabase_todo/features/category/presentation/bloc/category_cubit.dart';
import 'package:supabase_todo/core/ui/widgets/async_button.dart';
import 'package:uuid/uuid.dart';

class CategoryFormPage extends StatefulWidget {
  final String userId;
  final CategoryEntity? category;

  const CategoryFormPage({super.key, required this.userId, this.category});

  @override
  State<CategoryFormPage> createState() => _CategoryFormPageState();
}

class _CategoryFormPageState extends State<CategoryFormPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  final Uuid _uuid = const Uuid();

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.category?.name ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  void _saveCategory() {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now();
    final newCategory = CategoryEntity(
      id: widget.category?.id ?? _uuid.v4(),
      userId: widget.userId,
      name: _titleController.text.trim(),
      createdAt: widget.category?.createdAt ?? now,
      updatedAt: now,
    );

    final cubit = context.read<CategoryCubit>();
    if (widget.category == null) {
      cubit.create(newCategory);
    } else {
      cubit.update(newCategory);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CategoryCubit, CategoryState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          SnackbarUtils.showError(context, state.errorMessage!);
        } else if (state.lastSuccessMessage != null) {
          final action = widget.category == null ? 'created' : 'updated';
          SnackbarUtils.showSuccess(context, 'Category $action successfully!');
          context.pop();
        }
      },
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: ListView(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => context.pop(),
                    ),
                    Text(
                      widget.category == null
                          ? 'New Category'
                          : 'Edit Category',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                BlocBuilder<CategoryCubit, CategoryState>(
                  builder: (context, state) {
                    final isSubmitting = state.isSaving;
                    return TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: 'Title'),
                      validator: TitleValidator.validate,
                      enabled: !isSubmitting,
                    );
                  },
                ),
                const SizedBox(height: 24),
                BlocBuilder<CategoryCubit, CategoryState>(
                  builder: (context, state) {
                    final isLoading = state.isSaving;
                    return AsyncButton(
                      label: widget.category == null
                          ? 'Create Category'
                          : 'Update Category',
                      isLoading: isLoading,
                      onPressed: _saveCategory,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
