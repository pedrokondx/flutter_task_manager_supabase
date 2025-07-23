abstract class AuthRepository {
  Future<void> login(String email, String password);
  Future<bool> hasSession();
  Future<void> logout();
}
