class AuthenticationFailed implements Exception {
  final String cause;
  AuthenticationFailed(this.cause);
}
