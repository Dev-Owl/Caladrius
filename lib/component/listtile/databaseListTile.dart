import 'dart:convert';

import 'package:caladrius/core/clientHelper.dart';
import 'package:caladrius/core/exceptions/couchError.dart';
import 'package:caladrius/core/filesize.dart';
import 'package:caladrius/pillowdart/couchModels/databaseInfo.dart';
import 'package:flutter/material.dart';

class DatabaseListTile extends StatefulWidget {
  final String databaseName;

  const DatabaseListTile(this.databaseName, {Key? key}) : super(key: key);

  @override
  _DatabaseListTileState createState() => _DatabaseListTileState();
}

class _DatabaseListTileState extends State<DatabaseListTile> {
  DatabaseInfo? info;

  Future<Widget> loadDatabaseInformation() async {
    try {
      final client = PillowClientHelper.getClient();
      final response = await client.getRequest(widget.databaseName);
      if (response.statusCode == 200) {
        info = DatabaseInfo.fromJson(jsonDecode(response.body));
        if (info != null) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total docs: ${info?.totlaDocsCount}'),
              Text('Deleted docs: ${info?.deletedDocsCount}'),
              Text('File size: ${filesize(info?.size.file)}'),
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

  @override
  Widget build(BuildContext context) {
    return ListTile(
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
    );
  }
}
