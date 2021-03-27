import 'package:caladrius/component/bootstrap.dart';
import 'package:caladrius/component/loginForm.dart';
import 'package:flutter/material.dart';

class Login extends StatelessWidget {
  final BootstrapController? controller;

  const Login({Key? key, this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: LoginForm(controller: controller),
    );
  }
}
