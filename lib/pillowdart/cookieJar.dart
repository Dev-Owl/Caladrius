class CookieJar {
  final String cookie;
  final DateTime ttl;

  CookieJar(this.cookie, this.ttl);

  bool cookieStillValid() => ttl.isAfter(DateTime.now());

  Map<String, String> get header => {'Cookie': cookie};
}
