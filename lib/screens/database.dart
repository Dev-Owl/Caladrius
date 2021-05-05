import 'dart:convert';

import 'package:advanced_datatable/advancedDataTableSource.dart';
import 'package:caladrius/component/listtile/databaseListTile.dart';
import 'package:caladrius/component/widget/databaseMenu.dart';
import 'package:caladrius/component/widget/documentList.dart';
import 'package:caladrius/core/clientHelper.dart';
import 'package:caladrius/core/router.dart';
import 'package:caladrius/pillowdart/client.dart';
import 'package:flutter/material.dart';
import 'package:caladrius/core/helper.dart';

class DatabaseView extends StatefulWidget {
  final String? database;

  const DatabaseView({Key? key, this.database}) : super(key: key);

  @override
  _DatabaseViewState createState() => _DatabaseViewState();
}

class _DatabaseViewState extends State<DatabaseView> {
  late RoutingData routingData;
  var selectedMenu = 1;

  @override
  void initState() {
    super.initState();
  }

  String? get getCurrentDataBaseName =>
      routingData.route.length >= 2 ? routingData.route[1] : widget.database;

  @override
  Widget build(BuildContext context) {
    routingData = ModalRoute.of(context)!.settings.arguments as RoutingData;
    final mobileMode = widget.renderMobileMode(context);
    late final Widget body;
    if (getCurrentDataBaseName == null) {
      
      //TODO Add a proper empty widget here
      body = Center(
        child: Text('No database selected, please select or create one'),
      );
    } else {
      body = DatabaseListTile(getCurrentDataBaseName!);
    }
    return Scaffold(
      body: body,
    );

    /*
    if (mobileMode) {
      return mobileScreen(context);
    }
    return desktopScreen(context);
    */
  }

  String getTitle() {
    switch (selectedMenu) {
      case 1:
        return 'All documents';
      case 2:
        return 'Views';
      default:
        return 'Design documents';
    }
  }

  AppBar buildMobileAppBar(BuildContext context) {
    final rootNode = !Navigator.of(context).canPop();

    return AppBar(
      title: Text(
        getTitle(),
      ),
      leading: rootNode
          ? IconButton(
              icon: Icon(Icons.chevron_left_rounded),
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('dashboard');
              },
            )
          : null,
    );
  }

  Widget mobileScreen(BuildContext context) {
    return Scaffold(
      appBar: buildMobileAppBar(context),
      drawer: Drawer(
        child: buildMenu(),
      ),
      body: buildBody(),
    );
  }

  Widget desktopScreen(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          SizedBox(
            width: 250,
            child: buildMenu(),
          ),
          Expanded(
            child: buildBody(),
          )
        ],
      ),
    );
  }

  Widget buildBody() {
    if (selectedMenu == 1) {
      return DocumentList(
        loadAllDocuments,
        title: getTitle(),
      );
    }
    return Container(
      child: Text('Lazy'),
    );
  }

  Future<RemoteDataSourceDetails<Map<String, dynamic>>> loadAllDocuments(
      int pagesize, int offset, bool sortAscending) async {
    try {
      final client = PillowClientHelper.getClient();
      var response = await client.request(
          '$getCurrentDataBaseName/_all_docs?skip=$offset&limit=$pagesize&descending=${sortAscending.toString().toLowerCase()}',
          HttpMethod.GET);
      final data = jsonDecode(response.body);
      return RemoteDataSourceDetails<Map<String, dynamic>>(
          data['total_rows'], List<Map<String, dynamic>>.from(data['rows']));
    } catch (e) {
      return Future.error(e);
    }
  }

  Widget buildMenu() {
    return DatabaseMenu(
      getCurrentDataBaseName!,
      allDocuments: () {
        if (selectedMenu != 1) {
          setState(() {
            selectedMenu = 1;
          });
        }
      },
      views: () {
        if (selectedMenu != 2) {
          setState(() {
            selectedMenu = 2;
          });
        }
      },
      designDocuments: () {
        if (selectedMenu != 3) {
          setState(() {
            selectedMenu = 3;
          });
        }
      },
      activeMenu: selectedMenu,
    );
  }
}
