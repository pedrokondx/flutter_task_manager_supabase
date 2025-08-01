import 'package:dartz/dartz.dart';
import 'package:supabase_todo/features/auth/data/dtos/user_dto.dart';

abstract class AuthDataSource {
  Future<UserDTO> login(String email, String password);
  Future<UserDTO?> hasSession();
  Future<Unit> logout();
  Future<UserDTO> register(String email, String password);
}
