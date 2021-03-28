import 'package:caladrius/core/exceptions/authenticationFailed.dart';
import 'package:caladrius/pillowdart/CouchEndpoints.dart';
import 'package:caladrius/pillowdart/cookieJar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'pillowHttp/pillowHttp_stub.dart'
    if (dart.library.io) 'pillowHttp/pillowHttp_app.dart'
    if (dart.library.html) 'pillowHttp/pillowHttp_web.dart';

//TODO support basic auth on all requests

class PillowDart {
  String serverUrl;

  bool autoLogin = true;
  String? username;
  String? password;
  CookieJar? cookieJar;
  bool sendBasicAuth = false;

  final http.Client httpClinet = getClient();

  bool get authenticated => cookieJar?.cookieStillValid() ?? false;

  PillowDart(this.serverUrl, {this.username, this.password});

  Future removeSessionIfExists() async {
    /* if (httpClinet is BrowserClient) {
      //Running in the web -> checking cookie not so easy as its http
      //No luck from JS in this case
      (httpClinet as BrowserClient).withCredentials = true;
    }*/
    await httpClinet.delete(
      CouchEndpoints.combine(serverUrl, CouchEndpoints.session),
    );
    username = null;
    password = null;
  }

  Future<bool> checkAuthentication() async {
    final authTest = await httpClinet.get(
      CouchEndpoints.combine(serverUrl, CouchEndpoints.session),
    );
    if (authTest.statusCode == 200) {
      final authState = jsonDecode(authTest.body);
      if (authState != null) {
        if (authState['userCtx']['name'] != null) {
          username = authState['userCtx']['name'];
          return true;
        }
      }
    }
    return false;
  }

  Future<bool> authenticate(String? username, String? password,
      {bool autoLogin = true}) async {
    if ((cookieJar?.cookieStillValid() ?? false) &&
        username == this.username &&
        password == this.password) return true;
    //If we have a set of auth details like the requested probe the server
    if (this.username == username && this.password == password) {
      if (await checkAuthentication()) return true;
    } else if (this.username != null && this.password != null) {
      //Kill the session if any (http-only cookie no way to read)
      await removeSessionIfExists();
    }

    final response = await httpClinet.post(
      CouchEndpoints.combine(serverUrl, CouchEndpoints.session),
      body: {
        'name': username,
        'password': password,
      },
    );
    if (autoLogin) {
      this.username = username;
      this.password = password;
    } else {
      this.autoLogin = false;
      this.username = null;
      this.password = null;
    }

    if (response.statusCode == 200) {
      if (response.headers.containsKey('Set-Cookie') &&
          response.headers['Set-Cookie'] != null) {
        cookieJar = CookieJar(
          response.headers['Set-Cookie'] ?? '',
          DateTime.now().add(
            Duration(
              minutes: 9,
            ),
          ),
        );
      }
      return true;
    }
    return false;
  }

  Future<List<String>> getAllDbs() async {
    final authenticated = await authenticate(username, password);
    if (authenticated) {
      final response = await httpClinet.get(
          CouchEndpoints.combine(serverUrl, CouchEndpoints.allDbs),
          headers: cookieJar?.header);

      checkResponse(response);
      return List.from(jsonDecode(response.body));
    } else {
      throw AuthenticationFailed('Unable to authenticate against CouchDB');
    }
  }

  Future<http.Response> getRequest(String endpoint,
      {Map<String, String>? queryParameter,
      Map<String, String>? header}) async {
    final authenticated = await authenticate(username, password);
    if (authenticated) {
      final uri = CouchEndpoints.combine(serverUrl, endpoint);
      if (queryParameter != null) {
        uri.queryParameters.addAll(queryParameter);
      }
      final headerForRequest = <String, String>{};
      if (header != null) {
        headerForRequest.addAll(header);
      }
      final cookieHeader = cookieJar?.header;
      if (cookieHeader != null) {
        headerForRequest.addAll(cookieHeader);
      }

      return httpClinet.get(uri, headers: headerForRequest);
    } else {
      throw AuthenticationFailed('Unable to authenticate against CouchDB');
    }
  }

  void checkResponse(http.Response response,
      {List<int> okStates = const [200, 204]}) {
    if (!okStates.contains(response.statusCode)) {
      throw Exception(
          'None OK response from CouchDB! Code: ${response.statusCode} with body: ${response.body}');
    }
  }
}
