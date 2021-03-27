import 'package:caladrius/core/clientHelper.dart';
import 'package:caladrius/core/exceptions/noClient.dart';
import 'package:caladrius/component/loginForm.dart';
import 'package:caladrius/widget/CaladriusBootstrap.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  Future<List<String>> getAllDatabases() {
    try {
      return PillowClientHelper.getClient().getAllDbs();
    } catch (e) {
      return Future.error(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CaladriusBootstrap(() {
      return Scaffold(
        appBar: AppBar(
          title: Text('Dashboard'),
          actions: [
            IconButton(
                icon: Icon(Icons.logout),
                onPressed: () async {
                  await PillowClientHelper.getClient().removeSessionIfExists();
                  await PillowClientHelper.clearAuthStorage();
                  await Navigator.of(context).pushReplacementNamed('dashboard');
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
    });
  }
}
