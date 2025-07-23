import 'package:supabase_todo/features/auth/data/datasources/auth_datasource.dart';
import 'package:supabase_todo/features/auth/domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource remote;

  AuthRepositoryImpl(this.remote);

  @override
  Future<UserEntity> login(String email, String password) async {
    final dto = await remote.login(email, password);
    return dto.toEntity();
  }

  @override
  Future<UserEntity?> hasSession() async {
    final dto = await remote.hasSession();
    return dto?.toEntity();
  }

  @override
  Future<void> logout() => remote.logout();

  @override
  Future<UserEntity> register(String email, String password) async {
    final dto = await remote.register(email, password);
    return dto.toEntity();
  }
}
