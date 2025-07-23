abstract class AuthDataSource {
  Future<void> login(String email, String password);
  Future<bool> hasSession();
  Future<void> logout();
  Future<void> register(String email, String password);
}
