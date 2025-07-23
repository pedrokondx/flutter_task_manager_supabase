import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:supabase_todo/features/auth/data/datasources/auth_datasource.dart';
import 'package:supabase_todo/features/auth/data/dtos/user_dto.dart';

class AuthSupabaseDatasource implements AuthDataSource {
  final SupabaseClient supabase;

  AuthSupabaseDatasource(this.supabase);

  @override
  Future<UserDTO> login(String email, String password) async {
    final response = await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return UserDTO.fromSupabaseUser(response.user!);
  }

  @override
  Future<UserDTO?> hasSession() async {
    return supabase.auth.currentSession != null
        ? UserDTO.fromSupabaseUser(supabase.auth.currentUser!)
        : null;
  }

  @override
  Future<void> logout() async {
    await supabase.auth.signOut();
  }

  @override
  Future<UserDTO> register(String email, String password) async {
    final response = await supabase.auth.signUp(
      email: email,
      password: password,
    );
    return UserDTO.fromSupabaseUser(response.user!);
  }
}
