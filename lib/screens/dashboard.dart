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
  List<String>? totalDbs;
  bool reuseList = false;
  final TextEditingController searchController = TextEditingController();

  Future<List<String>> getAllDatabases() {
    try {
      if (reuseList) {
        Future.value(totalDbs);
      }
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
            totalDbs = null;
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
            reuseList = false;
            snapshot.data?.sort();
            totalDbs = snapshot.data;
            var viewData = totalDbs;
            if (viewData != null && searchController.text.isNotEmpty) {
              viewData = viewData
                  .where((element) =>
                      element.toLowerCase().contains(searchController.text))
                  .toList();
            }

            return Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Padding(
                        padding: EdgeInsets.all(10),
                        child: TextField(
                          controller: searchController,
                          decoration: InputDecoration(
                            hintText: 'Search for a db',
                            suffixIcon: searchController.text.isNotEmpty
                                ? IconButton(
                                    onPressed: () {
                                      searchController.clear();
                                      setState(() {
                                        reuseList = true;
                                      });
                                    },
                                    icon: Icon(Icons.clear),
                                  )
                                : null,
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.blueAccent, width: 32.0),
                                borderRadius: BorderRadius.circular(25.0)),
                          ),
                          onSubmitted: (term) {
                            setState(() {
                              reuseList = true;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: viewData?.length ?? 0,
                    itemBuilder: (_, index) {
                      return DatabaseListTile(
                        viewData![index],
                        onTap: () {
                          Navigator.of(context)
                              .pushNamed('database/${viewData![index]}');
                        },
                      );
                    },
                  ),
                )
              ],
            );
          },
        ),
      );
    });
  }

  Future showDatabaseAddDialog() async {
    final result = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('New database'),
        content: AddNewDB(),
      ),
    );

    if (result != null) {
      //Db created
      setState(() {
        reuseList = false;
      });
    }
  }
}
