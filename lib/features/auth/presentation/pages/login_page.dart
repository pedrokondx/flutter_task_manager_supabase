import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_todo/core/utils/snackbar_utils.dart';
import 'package:supabase_todo/core/validators/email_validator.dart';
import 'package:supabase_todo/core/validators/password_validator.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_events.dart';
import '../bloc/auth_state.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    login() {
      if (formKey.currentState!.validate()) {
        context.read<AuthBloc>().add(
          AuthLoginRequested(emailController.text, passwordController.text),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            context.go('/tasks');
          } else if (state is AuthError) {
            SnackbarUtils.showError(context, state.message);
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Welcome back!',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: emailController,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator: EmailValidator.validate,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: passwordController,
                    onFieldSubmitted: (_) => login(),
                    obscureText: true,
                    decoration: InputDecoration(labelText: 'Password'),
                    validator: PasswordValidator.validate,
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => context.go('/register'),
                    child: Text(
                      'Don\'t have an account? Register here',
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: login, child: const Text('Login')),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
