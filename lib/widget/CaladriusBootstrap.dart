import 'package:caladrius/component/bootSteps/LoginBootStep.dart';
import 'package:caladrius/component/bootstrap.dart';
import 'package:flutter/material.dart';

class CaladriusBootstrap extends StatelessWidget {
  final BootCompleted bootCompleted;

  const CaladriusBootstrap(this.bootCompleted, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BootStrap(
      [
        LoginBootStep(),
      ],
      bootCompleted,
    );
  }
}
/*
class CaladriusBootstrapCustom extends StatelessWidget {
  final BootCompleted bootCompleted;
  final loginBootStep = const LoginBootStep();

  const CaladriusBootstrapCustom(
    this.bootCompleted, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (loginBootStep.stepRequired()) {
      return BootStrap(
        [
          loginBootStep,
        ],
      );
    }
    return bootCompleted();
  }
}
*/
