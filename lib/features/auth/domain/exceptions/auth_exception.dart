import 'package:supabase_todo/core/domain/exceptions/app_exception.dart';

class AuthException extends AppException {
  const AuthException({required super.message, super.code, super.inner});

  factory AuthException.invalidCredentials() => const AuthException(
    message: 'Invalid email or password',
    code: 'INVALID_CREDENTIALS',
  );
  factory AuthException.loginFailure(Object inner) => AuthException(
    message: 'Login failed',
    code: 'LOGIN_FAILED',
    inner: inner,
  );
  factory AuthException.registrationFailure(Object inner) => AuthException(
    message: 'Registration failed',
    code: 'REGISTRATION_FAILED',
    inner: inner,
  );
  factory AuthException.sessionNotFound() => const AuthException(
    message: 'No active session found',
    code: 'SESSION_NOT_FOUND',
  );
  factory AuthException.logoutFailure(Object inner) => AuthException(
    message: 'Logout failed',
    code: 'LOGOUT_FAILED',
    inner: inner,
  );

  factory AuthException.sessionCheckFailure(Object inner) => AuthException(
    message: 'Session check failed',
    code: 'SESSION_CHECK_FAILED',
    inner: inner,
  );
}
