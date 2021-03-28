import 'package:caladrius/component/bootstrap/bootstrap.dart';
import 'package:caladrius/core/clientHelper.dart';
import 'package:caladrius/screens/login.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:universal_html/html.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class LoginBootStep extends BootstrapStep {
  const LoginBootStep();

  @override
  Widget buildStep(BootstrapController controller) {
    return Login(controller: controller);
  }

  @override
  Future<bool> stepRequired(SharedPreferences preferences) async {
    String? serverUrl;
    _AuthDetails? details;
    if ((preferences.getBool('storeAuth') ?? false) &&
        PillowClientHelper.initNeeded()) {
      //2 Ways to go:
      //CORS -> no way to read the cookie as its http only
      //App/NoneCors -> either read the cookie or get login details
      serverUrl = preferences.getString('serverUrl');
      if (kIsWeb) {
        if (document.cookie?.isEmpty ?? true) {
          //We are runnin in CORS mode need to read user and pass
          if (serverUrl != null) {
            final client = PillowClientHelper.initClient(serverUrl);
            if (await client.checkAuthentication()) {
              return false;
            }
          }
          details = _getAuthDetails(preferences);
        } else {
          //TODO implement none CORS mode, read cookie and check if still ok
        }
      } else {
        details = _getAuthDetails(preferences);
      }
      if (serverUrl != null && (details?.present ?? false)) {
        PillowClientHelper.initClient(serverUrl,
            username: details?.user, password: details?.password);
      }
    }
    //Check if client was created and has configuration for login
    return PillowClientHelper.initNeeded();
  }

  _AuthDetails _getAuthDetails(SharedPreferences preferences) {
    final user = preferences.getString('username');
    final password = preferences.getString('password');
    return _AuthDetails(user, password);
  }
}

class _AuthDetails {
  final String? user;
  final String? password;
  bool get present => user != null;
  _AuthDetails(this.user, this.password);
}
