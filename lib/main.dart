import 'package:caladrius/component/bootstrap.dart';
import 'package:caladrius/screens/corsHelp.dart';
import 'package:caladrius/screens/dashboard.dart';
import 'package:caladrius/widget/CaladriusBootstrap.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

late SharedPreferences preferences;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.getInstance().then((instance) {
    preferences = instance;
    runApp(MyApp());
  });
}

class MyApp extends StatelessWidget {
  Widget bootstrapRoute(BootCompleted call) => CaladriusBootstrap(call);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Caladrius',
      initialRoute: 'dashboard',
      routes: {
        'dashboard': (c) => bootstrapRoute(() => Dashboard()),
        'cors': (context) => CorsHelp(),
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}
