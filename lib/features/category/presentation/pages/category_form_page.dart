import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_todo/core/utils/snackbar_utils.dart';
import 'package:supabase_todo/core/validators/title_validator.dart';
import 'package:supabase_todo/core/domain/entities/category_entity.dart';
import 'package:supabase_todo/features/category/presentation/bloc/category_bloc.dart';
import 'package:supabase_todo/features/category/presentation/bloc/category_events.dart';
import 'package:supabase_todo/features/category/presentation/bloc/category_state.dart';
import 'package:supabase_todo/core/ui/widgets/async_button.dart';

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
  bool _isLoading = false;

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

  void _saveTask() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      final now = DateTime.now();
      final newCategory = CategoryEntity(
        id: widget.category?.id ?? '',
        userId: widget.userId,
        name: _titleController.text.trim(),
        createdAt: widget.category?.createdAt ?? now,
        updatedAt: now,
      );

      if (widget.category == null) {
        context.read<CategoryBloc>().add(CreateCategoryEvent(newCategory));
      } else {
        context.read<CategoryBloc>().add(UpdateCategoryEvent(newCategory));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CategoryBloc, CategoryState>(
      listener: (context, state) {
        setState(() => _isLoading = false);

        if (state is CategoryError) {
          SnackbarUtils.showError(context, state.message);
        } else if (state is CategoryLoaded) {
          final action = widget.category == null ? 'created' : 'updated';
          SnackbarUtils.showSuccess(context, 'Category $action successfully!');
          Navigator.pop(context);
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
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  validator: TitleValidator.validate,
                  enabled: !_isLoading,
                ),

                const SizedBox(height: 24),
                AsyncButton(
                  label: widget.category == null
                      ? 'Create Category'
                      : 'Update Category',
                  isLoading: _isLoading,
                  onPressed: _saveTask,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
