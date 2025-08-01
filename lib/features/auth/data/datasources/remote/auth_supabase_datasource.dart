import 'package:dartz/dartz.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;
import 'package:supabase_todo/features/auth/data/datasources/auth_datasource.dart';
import 'package:supabase_todo/features/auth/data/dtos/user_dto.dart';
import 'package:supabase_todo/features/auth/domain/exceptions/auth_exception.dart'
    show AuthException;

class AuthSupabaseDatasource implements AuthDataSource {
  final sb.SupabaseClient supabase;

  AuthSupabaseDatasource(this.supabase);

  @override
  Future<UserDTO> login(String email, String password) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return UserDTO.fromSupabaseUser(response.user!);
    } catch (e) {
      throw AuthException.loginFailure(e);
    }
  }

  @override
  Future<UserDTO?> hasSession() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        return null;
      }
      return UserDTO.fromSupabaseUser(user);
    } catch (e) {
      throw AuthException.sessionCheckFailure(e);
    }
  }

  @override
  Future<Unit> logout() async {
    try {
      await supabase.auth.signOut();
      return unit;
    } catch (e) {
      throw AuthException.logoutFailure(e);
    }
  }

  @override
  Future<UserDTO> register(String email, String password) async {
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
      );
      return UserDTO.fromSupabaseUser(response.user!);
    } catch (e) {
      throw AuthException.registrationFailure(e);
    }
  }
}
