import 'package:caladrius/component/listtile/databaseListTile.dart';
import 'package:caladrius/component/widget/addNewDbForm.dart';
import 'package:caladrius/core/clientHelper.dart';
import 'package:caladrius/core/exceptions/authenticationFailed.dart';
import 'package:caladrius/core/exceptions/noClient.dart';
import 'package:caladrius/component/widget/loginForm.dart';
import 'package:caladrius/component/bootstrap/CaladriusBootstrap.dart';
import 'package:caladrius/pillowdart/client.dart';
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
                icon: Icon(Icons.add_box_rounded),
                onPressed: showDatabaseAddDialog),
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
            if (snapshot.connectionState != ConnectionState.done) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.hasError) {
              if (snapshot.error is NoClientException ||
                  snapshot.error is AuthenticationFailed) {
                return LoginForm();
              } else {
                return Text(
                    'Something went wrong: ${snapshot.error?.toString()}');
              }
            }
            snapshot.data?.sort();
            return ListView.builder(
              itemCount: snapshot.data?.length ?? 0,
              itemBuilder: (_, index) {
                return DatabaseListTile(snapshot.data![index]);
              },
            );
          },
        ),
      );
    });
  }

  Future showDatabaseAddDialog() async {
    //TODO move this into its own widget, return the new created db name if any
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('New database'),
        content: AddNewDB(),
      ),
    );

    if (result != null) {
      //Db created
      setState(() {});
    }
  }
}
