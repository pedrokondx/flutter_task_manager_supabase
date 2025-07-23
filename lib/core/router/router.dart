import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
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

        if (authState is AuthAuthenticated && state.fullPath == '/login' ||
            state.fullPath == '/') {
          return '/home';
        }

        if (authState is AuthUnauthenticated && state.fullPath != '/login') {
          return '/login';
        }

        return null;
      },
      routes: [
        GoRoute(path: '/', builder: (_, __) => const SplashPage()),
        GoRoute(path: '/login', builder: (_, __) => const LoginPage()),
        GoRoute(path: '/home', builder: (_, __) => const HomePage()),
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
