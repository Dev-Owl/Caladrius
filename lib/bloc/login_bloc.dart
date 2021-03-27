import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:caladrius/core/clientHelper.dart';
import 'package:meta/meta.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(LoginInitial());

  @override
  Stream<LoginState> mapEventToState(
    LoginEvent event,
  ) async* {
    if (event is LoginRequest) {
      yield* tryLogin(event);
    }
  }

  void ensureClientIsReady(LoginRequest request) {
    if (PillowClientHelper.initNeeded()) {
      PillowClientHelper.initClient(request.serverUrl,
          username: request.username, password: request.password);
    }
    final pillowClient = PillowClientHelper.getClient();
    if (pillowClient.serverUrl != request.serverUrl) {
      PillowClientHelper.initClient(request.serverUrl,
          username: request.username, password: request.password);
    }
  }

  Stream<LoginState> tryLogin(LoginRequest request) async* {
    yield LoginRunning();

    try {
      final prefs = await SharedPreferences.getInstance();
      if (request.storeAuth) {
        await prefs.setString('username', request.username);
        await prefs.setString('password', request.password);
        await prefs.setString('serverUrl', request.serverUrl);
        await prefs.setBool('storeAuth', true);
      } else {
        await prefs.remove('username');
        await prefs.remove('password');
        await prefs.remove('serverUrl');
        await prefs.remove('storeAuth');
      }
      await prefs.setBool('sendbasic', request.addBasicAuth);
      ensureClientIsReady(request);
      final loginResult = await PillowClientHelper.getClient()
          .authenticate(request.username, request.password);
      if (loginResult) {
        yield LoginOk();
      } else {
        yield LoginFailed();
      }
    } catch (e) {
      yield LoginFailed(maybeCors: true);
    }
  }
}
