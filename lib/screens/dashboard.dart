import 'package:caladrius/core/exceptions/noClient.dart';
import 'package:caladrius/main.dart';
import 'package:caladrius/screens/loginForm.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  Future<List<String>> getAllDatabases() {
    try {
      if (pillowClient == null) {
        throw NoClientException('Login required, no session found');
      }
      return pillowClient?.getAllDbs() ?? Future.value([]);
    } catch (e) {
      return Future.error(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard'),
        actions: [
          IconButton(
              icon: Icon(Icons.logout),
              onPressed: () async {
                await pillowClient?.removeSessionIfExists();
                await Navigator.of(context).pushReplacementNamed('/login');
              }),
        ],
      ),
      body: FutureBuilder<List<String>>(
        future: getAllDatabases(),
        builder: (c, snapshot) {
          if (snapshot.hasError) {
            if (snapshot.error is NoClientException) {
              return LoginForm();
            } else {
              return Text(
                  'Something went wrong: ${snapshot.error?.toString()}');
            }
          }
          if (snapshot.connectionState != ConnectionState.done) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data?.length ?? 0,
            itemBuilder: (_, index) {
              return ListTile(
                title: Text(snapshot.data![index]),
              );
            },
          );
        },
      ),
    );
  }
}
