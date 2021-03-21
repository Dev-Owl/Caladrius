part of 'login_bloc.dart';

@immutable
abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginRunning extends LoginState {}

class LoginFailed extends LoginState {
  final bool maybeCors;

  LoginFailed({this.maybeCors = false});
}

class LoginOk extends LoginState {}
