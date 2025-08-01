import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_todo/app.dart';
import 'package:supabase_todo/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:supabase_todo/features/auth/presentation/bloc/auth_events.dart';
import 'core/di/injector.dart' as di;
import 'core/router/router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://himoxskkepawhegsskwm.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhpbW94c2trZXBhd2hlZ3Nza3dtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTMxMjQ3ODUsImV4cCI6MjA2ODcwMDc4NX0.7y5TkbhCja_EFsmP_Md2pxWil_Bv7Sh4rCOggVinsEA',
  );

  await di.init();

  final authBloc = AuthBloc(
    loginUseCase: di.sl(),
    checkSessionUseCase: di.sl(),
    logoutUsecase: di.sl(),
    registerUseCase: di.sl(),
  )..add(AuthCheckSession());

  AppRouter.init(authBloc);

  runApp(MyApp(authBloc: authBloc));
}
