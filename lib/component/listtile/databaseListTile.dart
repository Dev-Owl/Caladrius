import 'dart:convert';

import 'package:caladrius/core/clientHelper.dart';
import 'package:caladrius/core/exceptions/couchError.dart';
import 'package:caladrius/core/filesize.dart';
import 'package:caladrius/pillowdart/client.dart';
import 'package:caladrius/pillowdart/couchModels/databaseInfo.dart';
import 'package:flutter/material.dart';

class DatabaseListTile extends StatefulWidget {
  final String databaseName;
  final VoidCallback? onTap;

  const DatabaseListTile(this.databaseName, {Key? key, this.onTap})
      : super(key: key);

  @override
  _DatabaseListTileState createState() => _DatabaseListTileState();
}

class _DatabaseListTileState extends State<DatabaseListTile> {
  DatabaseInfo? info;

  Future<Widget> loadDatabaseInformation() async {
    try {
      final client = PillowClientHelper.getClient();
      final response =
          await client.request(widget.databaseName, HttpMethod.GET);
      if (response.statusCode == 200) {
        info = DatabaseInfo.fromJson(jsonDecode(response.body));
        if (info != null) {
          final deletionColor =
              (info?.deletedDocsCount ?? 0) > (info?.totlaDocsCount ?? 0)
                  ? Colors.red
                  : Colors.black;
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Chip(
                label: Row(
                  children: [
                    Icon(Icons.note_add),
                    Text('${info?.totlaDocsCount}'),
                  ],
                ),
              ),
              Chip(
                label: Row(
                  children: [
                    Icon(
                      Icons.delete_forever,
                      color: deletionColor,
                    ),
                    Text(
                      '${info?.deletedDocsCount}',
                      style: TextStyle(
                        color: deletionColor,
                      ),
                    ),
                  ],
                ),
              ),
              Chip(
                label: Row(
                  children: [
                    Icon(Icons.storage),
                    Text('${filesize(info?.size.file)}'),
                  ],
                ),
              ),
            ],
          );
        }
        return Text('Unable to get database stats');
      } else {
        throw CouchError(response.body, response.statusCode);
      }
    } catch (e) {
      return Future.error(e);
    }
  }
  //TODO Design overview card and move it out of listtiles 
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(widget.databaseName),
          ),
          ListTile(
            title: Text(widget.databaseName),
            subtitle: FutureBuilder<Widget>(
              initialData: Text('Loading database information...'),
              builder: (c, snapshot) {
                if (snapshot.hasError) {
                  return Text('Error loading database stats');
                } else if (snapshot.hasData) {
                  return snapshot.data!;
                }
                return CircularProgressIndicator();
              },
              future: loadDatabaseInformation(),
            ),
            onTap: widget.onTap,
          ),
        ],
      ),
    );
  }
}
