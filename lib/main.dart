import 'package:caladrius/pillowdart/client.dart';
import 'package:caladrius/screens/corsHelp.dart';
import 'package:caladrius/screens/dashboard.dart';
import 'package:caladrius/screens/login.dart';
import 'package:flutter/material.dart';

PillowDart? pillowClient;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Caladrius',
      routes: {
        '/dashboard': (context) => Dashboard(),
        '/cors': (context) => CorsHelp(),
        '/login': (context) => Login(),
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Login(),
    );
  }
}
