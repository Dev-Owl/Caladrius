import 'package:caladrius/component/listtile/databaseListTile.dart';
import 'package:caladrius/core/clientHelper.dart';
import 'package:caladrius/core/exceptions/authenticationFailed.dart';
import 'package:caladrius/core/exceptions/noClient.dart';
import 'package:caladrius/component/widget/loginForm.dart';
import 'package:caladrius/component/bootstrap/CaladriusBootstrap.dart';
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
            if (snapshot.hasError) {
              if (snapshot.error is NoClientException ||
                  snapshot.error is AuthenticationFailed) {
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
                return DatabaseListTile(snapshot.data![index]);
              },
            );
          },
        ),
      );
    });
  }

  Future showDatabaseAddDialog() {
    //TODO move this into its own widget, return the new created db name if any
    return showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          final formKey = GlobalKey<FormState>();
          final dbName = TextEditingController();
          return Container(
            height: 200,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Text('Add a new database'),
                  Form(
                    key: formKey,
                    child: TextFormField(
                      controller: dbName,
                      validator: (newDb) {
                        if (newDb != null && newDb.isNotEmpty) {
                          final lowerNewDb = newDb.toLowerCase();
                          final validationRegex =
                              RegExp(r'^[a-z][a-z0-9_$()+/-]*$');
                          if (!validationRegex.hasMatch(lowerNewDb)) {
                            return 'Database name not valid';
                          }
                        } else {
                          return "Can't be empty";
                        }
                      },
                      decoration: InputDecoration(
                        helperText: 'Database name',
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      final validationResult =
                          formKey.currentState?.validate() ?? false;
                      if (validationResult) {
                        final newDbName = dbName.text.toLowerCase();
                        //TODO run put to server to create db and trigger reload
                      }
                    },
                    child: const Text('Add'),
                  )
                ],
              ),
            ),
          );
        });
  }
}
