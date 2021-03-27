import 'package:caladrius/core/router.dart';
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
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Caladrius',
      //This will bootsrap the login
      initialRoute: 'dashboard',
      onGenerateRoute: AppRouter.generateRoute,
      //TODO Below theme is a placeholder
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}
