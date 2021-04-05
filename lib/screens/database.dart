import 'dart:convert';

import 'package:caladrius/component/widget/databaseMenu.dart';
import 'package:caladrius/component/widget/documentList.dart';
import 'package:caladrius/core/clientHelper.dart';
import 'package:caladrius/core/dataPackage.dart';
import 'package:caladrius/core/router.dart';
import 'package:caladrius/main.dart';
import 'package:caladrius/pillowdart/client.dart';
import 'package:flutter/material.dart';
import 'package:caladrius/core/helper.dart';

class DatabaseView extends StatefulWidget {
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

  String get getCurrentDataBaseName => routingData.route[1];

  @override
  Widget build(BuildContext context) {
    routingData = ModalRoute.of(context)!.settings.arguments as RoutingData;
    final mobileMode = widget.renderMobileMode(context);

    if (mobileMode) {
      return mobileScreen(context);
    }
    return desktopScreen(context);
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
        (int offset) async {
          try {
            final lastPageSize = preferences.getInt('lastpagesize') ?? 10;
            final client = PillowClientHelper.getClient();
            var response = await client.request(
                '$getCurrentDataBaseName/_all_docs?skip=$offset&limit=$lastPageSize',
                HttpMethod.GET);
            final data = jsonDecode(response.body);
            final package = DataPackage(
              data['total_rows'],
              offset,
              List<Map<String, dynamic>>.from(data['rows']),
            );
            return package;
          } catch (e) {
            return Future.error(e);
          }
        },
        title: getTitle(),
      );
    }
    return Container(
      child: Text('Lazy'),
    );
  }

  Widget buildMenu() {
    return DatabaseMenu(
      getCurrentDataBaseName,
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
