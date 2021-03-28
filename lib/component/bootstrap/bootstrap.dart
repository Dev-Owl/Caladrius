import 'package:caladrius/main.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

typedef BootCompleted = Widget Function();

class BootStrap extends StatefulWidget {
  final List<BootstrapStep> steps;
  final int currentIndex;
  final BootCompleted bootCompleted;

  const BootStrap(
    this.steps,
    this.bootCompleted, {
    Key? key,
    this.currentIndex = 0,
  }) : super(key: key);

  @override
  _BootStrapState createState() => _BootStrapState();
}

class _BootStrapState extends State<BootStrap> implements BootstrapController {
  late int currentIndex;
  bool bootRunning = true;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.currentIndex;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Widget>(
        stream: work(),
        builder: (c, snap) {
          if (snap.hasData) {
            return snap.data!;
          }
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        });
  }

  Stream<Widget> work() async* {
    while (bootRunning &&
        !(await widget.steps[currentIndex].stepRequired(preferences))) {
      if (currentIndex + 1 < widget.steps.length) {
        currentIndex++;
      } else {
        bootRunning = false;
      }
    }
    if (bootRunning) {
      yield widget.steps[currentIndex].buildStep(this);
    } else {
      yield widget.bootCompleted();
    }
  }

  @override
  void procced() {
    if (currentIndex + 1 < widget.steps.length) {
      setState(() {
        currentIndex++;
      });
    } else {
      setState(() {
        bootRunning = false;
      });
    }
  }

  @override
  void stepback() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
      });
    } else {
      setState(() {
        bootRunning = false;
      });
    }
  }
}

abstract class BootstrapStep {
  const BootstrapStep();
  Future<bool> stepRequired(SharedPreferences prefs);
  Widget buildStep(BootstrapController controller);
}

abstract class BootstrapController {
  void procced();
  void stepback();
}
