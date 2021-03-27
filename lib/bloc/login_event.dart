part of 'login_bloc.dart';

@immutable
abstract class LoginEvent {}

class LoginRequest extends LoginEvent {
  final String serverUrl;
  final String username;
  final String password;
  final bool addBasicAuth;
  final bool storeAuth;

  LoginRequest(
    this.serverUrl,
    this.username,
    this.password,
    this.addBasicAuth,
    this.storeAuth,
  );
}

class CheckForOldSession extends LoginEvent {}
