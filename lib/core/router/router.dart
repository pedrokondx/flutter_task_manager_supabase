import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_todo/features/auth/presentation/pages/register_page.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/bloc/auth_state.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/home/presentation/pages/home_page.dart';

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
          return '/home';
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
        GoRoute(path: '/home', builder: (_, __) => const HomePage()),
        GoRoute(path: '/register', builder: (_, __) => const RegisterPage()),
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
