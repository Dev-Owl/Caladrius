import 'package:caladrius/component/sharedDialogs.dart';
import 'package:caladrius/component/widget/databaseGridElement.dart';
import 'package:caladrius/core/router.dart';
import 'package:flutter/material.dart';

typedef OnDatabaseTab = void Function(String databaseName);

class DatabaseGridList extends StatefulWidget {
  final List<String> databaseNames;
  final OnDatabaseTab dbTap;

  const DatabaseGridList(
    this.databaseNames,
    this.dbTap, {
    Key? key,
  }) : super(key: key);

  @override
  _DatabaseGridListState createState() => _DatabaseGridListState();
}

class _DatabaseGridListState extends State<DatabaseGridList> {
  String? selectedDatabase;
  final TextEditingController searchController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    var viewData = widget.databaseNames;
    if (searchController.text.isNotEmpty) {
      viewData = viewData
          .where((element) =>
              element.toLowerCase().contains(searchController.text))
          .toList();
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final r = await showDatabaseAddDialog(context);
          if (r != null) {
            setState(() {
              widget.databaseNames.add(r);
            });
          }
        },
        child: Icon(Icons.add),
      ),
      body: Column(
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
                                setState(() {
                                  searchController.clear();
                                });
                              },
                              icon: Icon(Icons.clear),
                            )
                          : null,
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.blueAccent, width: 32.0),
                          borderRadius: BorderRadius.circular(15.0)),
                    ),
                    onSubmitted: (term) {
                      setState(() {});
                    },
                  ),
                ),
              ),
            ],
          ),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(5),
              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200,
                  childAspectRatio: 3 / 2,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20),
              itemCount: viewData.length,
              itemBuilder: (_, index) {
                return DatabaseGridElement(
                  viewData[index],
                  databaseSelected,
                  selectedDatabase == viewData[index],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void databaseSelected(String newDatabaseSelected) {
    setState(() {
      selectedDatabase = newDatabaseSelected;
    });
    AppRouter.updateUrl(AppRouter.getCurrentURL() + '/openDatabase/$newDatabaseSelected');
    widget.dbTap(newDatabaseSelected);
  }
}
