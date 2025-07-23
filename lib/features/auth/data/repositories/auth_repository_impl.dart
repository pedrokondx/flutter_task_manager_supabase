import 'package:supabase_todo/features/auth/data/datasources/auth_datasource.dart';
import '../../domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthDataSource remote;

  AuthRepositoryImpl(this.remote);

  @override
  Future<void> login(String email, String password) async {
    return await remote.login(email, password);
  }

  @override
  Future<bool> hasSession() => remote.hasSession();

  @override
  Future<void> logout() => remote.logout();
}
