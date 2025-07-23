import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_todo/features/auth/data/datasources/auth_datasource.dart';

class AuthRemoteDataSourceImpl implements AuthDataSource {
  final SupabaseClient supabase;

  AuthRemoteDataSourceImpl(this.supabase);

  @override
  Future<void> login(String email, String password) async {
    await supabase.auth.signInWithPassword(email: email, password: password);
  }

  @override
  Future<bool> hasSession() async {
    return supabase.auth.currentSession != null;
  }

  @override
  Future<void> logout() async {
    await supabase.auth.signOut();
  }

  @override
  Future<void> register(String email, String password) async {
    await supabase.auth.signUp(email: email, password: password);
  }
}
