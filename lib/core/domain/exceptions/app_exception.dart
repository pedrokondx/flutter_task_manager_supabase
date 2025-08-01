abstract class AppException implements Exception {
  final String message;
  final String? code;
  final Object? inner;

  const AppException({required this.message, this.code, this.inner});

  @override
  String toString() =>
      'AppException{message: $message, code: $code, inner: $inner}';
}
