import 'package:supabase_todo/features/auth/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> login(String email, String password);
  Future<UserEntity?> hasSession();
  Future<void> logout();
  Future<UserEntity> register(String email, String password);
}
