import 'dart:math';

import 'package:caladrius/core/dataPackage.dart';
import 'package:caladrius/main.dart';
import 'package:flutter/material.dart';
import 'package:caladrius/core/helper.dart';

typedef GetDataCallback = Future<DataPackage> Function(int offset);

class DocumentList extends StatefulWidget {
  final String title;
  final GetDataCallback getDataCallback;

  const DocumentList(
    this.getDataCallback, {
    Key? key,
    this.title = 'Lazy dev',
  }) : super(key: key);
  @override
  _DocumentListState createState() => _DocumentListState();
}

class _DocumentListState extends State<DocumentList> {
  late Future<DataPackage> loadDataFuture;
  late DataPackage lastLoadedPackage;
  int rowsPerPage = 10;

  @override
  void initState() {
    super.initState();
    loadDataFuture = widget.getDataCallback(0);
  }

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
      body: buildContent(context),
    );
  }

  Widget buildContent(BuildContext context) {
    return FutureBuilder<DataPackage>(
      builder: (fContext, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.data != null) {
            lastLoadedPackage = snapshot.data!;
            return buildTable();
          } else {
            return errorChild('Got empty response, that should not happen');
          }
        } else {
          if (snapshot.hasError) {
            return errorChild(snapshot.error);
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        }
      },
      future: loadDataFuture,
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
              setState(() {
                loadDataFuture = widget.getDataCallback(0);
              });
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
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints.expand(width: constraints.maxWidth),
            child: PaginatedDataTable(
              source: lastLoadedPackage,
              columns: lastLoadedPackage.getColumns((index, asc) {
                setState(() {
                  lastLoadedPackage.sortIndex = index;
                  lastLoadedPackage.sortAscending = asc;
                  lastLoadedPackage.sort();
                });
              }),
              onPageChanged: (targetPage) {
                setState(() {
                  loadDataFuture = widget.getDataCallback(targetPage);
                });
              },
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
              showCheckboxColumn: false,
              rowsPerPage: min(lastLoadedPackage.totalRows, rowsPerPage),
              availableRowsPerPage: [
                min(lastLoadedPackage.totalRows, rowsPerPage),
                min(lastLoadedPackage.totalRows, rowsPerPage) * 2,
                min(lastLoadedPackage.totalRows, rowsPerPage) * 3,
                min(lastLoadedPackage.totalRows, rowsPerPage) * 5
              ],
            ),
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
