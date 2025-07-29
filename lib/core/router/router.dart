import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_todo/features/auth/presentation/pages/register_page.dart';
import 'package:supabase_todo/core/domain/entities/category_entity.dart';
import 'package:supabase_todo/features/category/presentation/pages/category_form_page.dart';
import 'package:supabase_todo/features/category/presentation/pages/category_list_page.dart';
import 'package:supabase_todo/features/todo/domain/entities/task_entity.dart';
import 'package:supabase_todo/features/todo/presentation/pages/task_form_page.dart';
import 'package:supabase_todo/features/todo/presentation/pages/task_list_page.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';

class AppRouter {
  static late final GoRouter router;

  static void init(AuthBloc authBloc) {
    final authNotifier = AuthRefreshNotifier(authBloc);

    router = GoRouter(
      initialLocation: '/',
      refreshListenable: authNotifier,
      redirect: (context, state) {
        final authState = authBloc.state;

        // Redirect authenticated users away from login/splash to home
        if (authState is AuthAuthenticated &&
            (state.fullPath == '/login' || state.fullPath == '/')) {
          return '/tasks';
        }

        // Redirect unauthenticated users trying to access protected routes (but allow register)
        if (authState is AuthUnauthenticated &&
            state.fullPath != '/login' &&
            state.fullPath != '/register') {
          return '/login';
        }

        return null;
      },
      routes: [
        GoRoute(path: '/', builder: (_, __) => const SplashPage()),
        GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
        GoRoute(path: '/register', builder: (_, __) => const RegisterPage()),
        GoRoute(
          path: '/tasks',
          builder: (context, state) {
            final authState = authBloc.state;
            if (authState is AuthAuthenticated) {
              return TaskListPage(userId: authState.userId);
            }
            return const SplashPage();
          },
        ),
        GoRoute(
          path: '/tasks/form',
          builder: (context, state) {
            final authState = authBloc.state;
            if (authState is AuthAuthenticated) {
              final task = state.extra as TaskEntity?;
              return TaskFormPage(userId: authState.userId, task: task);
            }
            return const SplashPage();
          },
        ),
        GoRoute(
          path: '/categories',
          builder: (context, state) {
            final authState = authBloc.state;
            if (authState is AuthAuthenticated) {
              return CategoryListPage(userId: authState.userId);
            }
            return const SplashPage();
          },
        ),
        GoRoute(
          path: '/categories/form',
          builder: (context, state) {
            final authState = authBloc.state;
            if (authState is AuthAuthenticated) {
              final category = state.extra as CategoryEntity?;
              return CategoryFormPage(
                userId: authState.userId,
                category: category,
              );
            }
            return const SplashPage();
          },
        ),
      ],
    );
  }
}

class AuthRefreshNotifier extends ChangeNotifier {
  AuthRefreshNotifier(AuthBloc bloc) {
    bloc.stream.listen((_) {
      notifyListeners();
    });
  }
}
