class NoClientException implements Exception {
  final String cause;
  NoClientException(this.cause);
}
