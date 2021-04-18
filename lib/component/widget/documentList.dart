import 'dart:math';

import 'package:advanced_datatable/datatable.dart';
import 'package:caladrius/core/dataPackage.dart';
import 'package:caladrius/main.dart';
import 'package:flutter/material.dart';
import 'package:caladrius/core/helper.dart';

class DocumentList extends StatefulWidget {
  final String title;
  final LoadGenericDataCallBack getDataCallback;

  const DocumentList(
    this.getDataCallback, {
    Key? key,
    this.title = 'Lazy dev',
  }) : super(key: key);
  @override
  _DocumentListState createState() => _DocumentListState();
}

class _DocumentListState extends State<DocumentList> {
  late final DataPackage lastLoadedPackage =
      DataPackage(widget.getDataCallback);
  int rowsPerPage = 10;

  @override
  Widget build(BuildContext context) {
    final mobileMode = widget.renderMobileMode(context);
    return Scaffold(
      appBar: mobileMode
          ? null
          : AppBar(
              title: Text(widget.title),
              automaticallyImplyLeading: false,
            ),
      body: buildTable(),
    );
  }

  Widget errorChild(Object? error) {
    return Center(
      child: Wrap(
        alignment: WrapAlignment.center,
        direction: Axis.vertical,
        children: [
          Text('Something went wrong while loading the data'),
          Text('${error?.toString()}'),
          ElevatedButton(
            onPressed: () {
              //TODO would be nice if I can controll the table from the outside
              setState(() {});
            },
            child: Text('Try again'),
          ),
        ],
      ),
    );
  }

  Widget buildTable() {
    return LayoutBuilder(
      builder: (context, constraints) {
        lastLoadedPackage.onCelltap =
            (row, cell) => showDetails(context, row, cell);
        return SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: AdvancedPaginatedDataTable(
            source: lastLoadedPackage,
            columns: [
              DataColumn(label: Text('id')),
              DataColumn(
                label: Text('key'),
                onSort: (i, s) {
                  setState(() {
                    lastLoadedPackage.sort(i, s);
                  });
                },
              ),
              DataColumn(label: Text('value')),
            ],
            rowsPerPage: rowsPerPage,
            onRowsPerPageChanged: (newRowsPerPage) async {
              if (newRowsPerPage != null) {
                setState(() {
                  rowsPerPage = newRowsPerPage;
                });
                await preferences.setInt('lastpagesize', newRowsPerPage);
              }
            },
            sortAscending: lastLoadedPackage.sortAscending,
            sortColumnIndex: lastLoadedPackage.sortIndex,
            showFirstLastButtons: true,
            addEmptyRows: false,
          ),
        );
      },
    );
  }

  void showDetails(
      BuildContext context, Map<String, dynamic> row, String cellKey) {
    showDialog(
        context: context,
        builder: (c) => AlertDialog(
              title: Text('Cell content'),
              content: Text(row[cellKey]?.toString() ?? 'Seems to be null'),
            ));
  }
}
