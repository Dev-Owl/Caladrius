import 'package:caladrius/core/clientHelper.dart';
import 'package:caladrius/pillowdart/client.dart';
import 'package:flutter/material.dart';

class AddNewDB extends StatefulWidget {
  @override
  _AddNewDBState createState() => _AddNewDBState();
}

class _AddNewDBState extends State<AddNewDB> {
  final formKey = GlobalKey<FormState>();
  final dbName = TextEditingController();
  String? error;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Form(
          key: formKey,
          child: TextFormField(
            controller: dbName,
            validator: (newDb) {
              if (newDb != null && newDb.isNotEmpty) {
                final lowerNewDb = newDb.toLowerCase();
                final validationRegex = RegExp(r'^[a-z][a-z0-9_$()+/-]*$');
                if (!validationRegex.hasMatch(lowerNewDb)) {
                  return 'Database name not valid';
                }
              } else {
                return "Can't be empty";
              }
            },
            decoration: InputDecoration(
              helperText: 'Database name',
            ),
          ),
        ),
        Text(
          error ?? '',
          style: TextStyle(color: Colors.red),
        ),
        ElevatedButton(
          onPressed: () async {
            final validationResult = formKey.currentState?.validate() ?? false;
            if (validationResult) {
              final newDbName = dbName.text.toLowerCase();
              //TODO run put to server to create db and trigger reload
              final creationRequest = await PillowClientHelper.getClient()
                  .request(newDbName, HttpMethod.PUT);
              if (creationRequest.statusCode == 201) {
                Navigator.of(context).pop(newDbName);
              } else {
                setState(() {
                  error = creationRequest.body;
                });
              }
            }
          },
          child: const Text('Add'),
        )
      ],
    );
  }
}
