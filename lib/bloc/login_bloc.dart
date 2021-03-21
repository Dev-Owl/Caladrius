import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:caladrius/main.dart';
import 'package:caladrius/pillowdart/client.dart';
import 'package:meta/meta.dart';

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
    pillowClient ??= PillowDart(request.serverUrl,
        username: request.username, password: request.password);
    if (pillowClient?.serverUrl != request.serverUrl) {
      pillowClient = PillowDart(request.serverUrl,
          username: request.username, password: request.password);
    }
  }

  Stream<LoginState> tryLogin(LoginRequest request) async* {
    yield LoginRunning();

    try {
      ensureClientIsReady(request);
      final loginResult =
          await pillowClient?.authenticate(request.username, request.password);
      if (loginResult ?? false) {
        yield LoginOk();
      } else {
        yield LoginFailed();
      }
    } catch (e) {
      yield LoginFailed(maybeCors: true);
    }
  }
}
