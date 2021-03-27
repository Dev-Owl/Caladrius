import 'package:caladrius/main.dart';
import 'package:caladrius/pillowdart/client.dart';

class PillowClientHelper {
  static PillowDart? _pillowClient;

  static PillowDart getClient() {
    if (_pillowClient == null) {
      throw Exception('Client is not yet created');
    }
    //It can't be null here, to compile bang operator is needed
    return _pillowClient!;
  }

  static PillowDart initClient(String serverUrl,
      {String? username, String? password}) {
    _pillowClient =
        PillowDart(serverUrl, password: password, username: username);
    return getClient();
  }

  static bool initNeeded() =>
      _pillowClient == null ||
      (_pillowClient?.username == null && _pillowClient?.password == null);

  static Future clearAuthStorage() async {
    await preferences.remove('username');
    await preferences.remove('password');
  }
}
