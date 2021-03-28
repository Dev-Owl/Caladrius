class CouchError implements Exception {
  final String cause;
  final int statusCode;
  CouchError(this.cause, this.statusCode);
}
