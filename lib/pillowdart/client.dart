import 'package:caladrius/core/exceptions/authenticationFailed.dart';
import 'package:caladrius/pillowdart/CouchEndpoints.dart';
import 'package:caladrius/pillowdart/cookieJar.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;

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
  int ensureSessionsEveryXMinutes = 5;
  DateTime? lastSessionRequest;

  final http.Client httpClient = getClient();

  bool get authenticated => cookieJar?.cookieStillValid() ?? false;

  PillowDart(this.serverUrl, {this.username, this.password});

  Future removeSessionIfExists() async {
    /* if (httpClient is BrowserClient) {
      //Running in the web -> checking cookie not so easy as its http
      //No luck from JS in this case
      (httpClient as BrowserClient).withCredentials = true;
    }*/
    await httpClient.delete(
      CouchEndpoints.combine(serverUrl, CouchEndpoints.session),
    );
    username = null;
    password = null;
  }

  Future<bool> checkAuthentication() async {
    //If in web do session test only every x minutes, saves requests
    if (kIsWeb &&
        lastSessionRequest != null &&
        lastSessionRequest!.difference(DateTime.now()).inMinutes <
            ensureSessionsEveryXMinutes) return true;

    final authTest = await httpClient.get(
      CouchEndpoints.combine(serverUrl, CouchEndpoints.session),
    );

    if (authTest.statusCode == 200) {
      final authState = jsonDecode(authTest.body);
      if (authState != null) {
        if (authState['userCtx']['name'] != null) {
          lastSessionRequest = DateTime.now();
          username = authState['userCtx']['name'];
          return true;
        }
      }
    }
    lastSessionRequest = null;
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

    final response = await httpClient.post(
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
      if (response.headers.containsKey('set-cookie') &&
          response.headers['set-cookie'] != null) {
        cookieJar = CookieJar(
          response.headers['set-cookie'] ?? '',
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
      final response = await httpClient.get(
          CouchEndpoints.combine(serverUrl, CouchEndpoints.allDbs),
          headers: cookieJar?.header);

      checkResponse(response);
      return List.from(jsonDecode(response.body));
    } else {
      throw AuthenticationFailed('Unable to authenticate against CouchDB');
    }
  }

  Future<http.Response> request(String endpoint, HttpMethod method,
      {Map<String, String>? queryParameter,
      dynamic body,
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
      switch (method) {
        case HttpMethod.GET:
          return httpClient.get(uri, headers: headerForRequest);
        case HttpMethod.POST:
          return httpClient.post(uri, body: body, headers: headerForRequest);
        case HttpMethod.PUT:
          return httpClient.put(uri, body: body, headers: headerForRequest);
        case HttpMethod.DELETE:
          return httpClient.delete(uri, body: body, headers: headerForRequest);
        case HttpMethod.HEAD:
          return httpClient.head(uri, headers: headerForRequest);
      }
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

enum HttpMethod { GET, POST, PUT, DELETE, HEAD }
