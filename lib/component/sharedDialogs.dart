import 'package:caladrius/component/widget/addNewDbForm.dart';
import 'package:flutter/material.dart';

Future<String?> showDatabaseAddDialog(BuildContext context) async {
  return showDialog<String>(
    context: context,
    builder: (_) => AlertDialog(
      title: Text('New database'),
      content: AddNewDB(),
    ),
  );
}
