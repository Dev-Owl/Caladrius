import 'package:caladrius/component/dashboardMasterDetail.dart';
import 'package:caladrius/component/databaseGridList.dart';
import 'package:caladrius/component/listtile/databaseListTile.dart';
import 'package:caladrius/component/sharedDialogs.dart';
import 'package:caladrius/component/widget/addNewDbForm.dart';
import 'package:caladrius/core/clientHelper.dart';
import 'package:caladrius/core/exceptions/authenticationFailed.dart';
import 'package:caladrius/core/exceptions/noClient.dart';
import 'package:caladrius/component/widget/loginForm.dart';
import 'package:caladrius/component/bootstrap/CaladriusBootstrap.dart';
import 'package:caladrius/core/helper.dart';
import 'package:caladrius/screens/database.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatefulWidget {
  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  List<String>? totalDbs;
  bool reuseList = false;
  String? selectedDatabase;

  Future<List<String>> getAllDatabases() {
    try {
      if (reuseList) {
        return Future.value(totalDbs);
      }
      return PillowClientHelper.getClient().getAllDbs();
    } catch (e) {
      return Future.error(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final mobileMode = widget.renderMobileMode(context);
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
        body: databaseList(mobileMode),
        floatingActionButton: mobileMode
            ? FloatingActionButton(
                onPressed: () async {
                  final r = await showDatabaseAddDialog(context);
                  if (r != null) {
                    setState(() {
                      totalDbs?.add(r);
                    });
                  }
                },
                child: Icon(Icons.add),
              )
            : null,
      );
    });
  }

  Widget databaseList(bool mobileMode) {
    return FutureBuilder<List<String>>(
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
            return Text('Something went wrong: ${snapshot.error?.toString()}');
          }
        }
        return buildBody(context, mobileMode, snapshot.data ?? []);
      },
    );
  }

  Widget buildBody(BuildContext context, bool mobileMode, List<String> dbs) {
    //If we are short on space, only the database list
    if (mobileMode) {
      return DatabaseGridList(dbs, (db) {
        Navigator.of(context).pushNamed('database/$db');
      });
    }
    return DashboardMasterDetail(dbs);
  }
}
