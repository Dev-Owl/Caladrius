import 'package:caladrius/component/databaseGridList.dart';
import 'package:caladrius/component/sharedDialogs.dart';
import 'package:caladrius/screens/database.dart';
import 'package:flutter/material.dart';
import 'package:caladrius/core/helper.dart';

class DashboardMasterDetail extends StatefulWidget {
  final List<String> databaseList;
  final String? preSelectedDatabase;

  const DashboardMasterDetail(this.databaseList,
      {Key? key, this.preSelectedDatabase})
      : super(key: key);
  @override
  _DashboardMasterDetailState createState() => _DashboardMasterDetailState();
}

class _DashboardMasterDetailState extends State<DashboardMasterDetail> {
  String? selectedDatabase;

  @override
  void initState() {
    super.initState();
    selectedDatabase = widget.preSelectedDatabase;
  }

  @override
  Widget build(BuildContext context) {
    //TODO Handle database selection below, ensure its represented in the URL
    return Row(
      children: [
        Flexible(
          flex: 1,
          child: DatabaseGridList(widget.databaseList, (db) {
            setState(() {
              selectedDatabase = db;
            });
          }),
        ),
        Flexible(
          flex: 3,
          child: DatabaseView(
            database: selectedDatabase,
          ),
        )
      ],
    );
  }
}
