import 'package:flutter/material.dart';
import 'package:caladrius/core/helper.dart';

class DocumentList extends StatefulWidget {
  final String title;

  const DocumentList({Key? key, this.title = 'Lazy dev'}) : super(key: key);
  @override
  _DocumentListState createState() => _DocumentListState();
}

class _DocumentListState extends State<DocumentList> {
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
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: ConstrainedBox(
              constraints: BoxConstraints.expand(width: constraints.maxWidth),
              child: DataTable(
                sortAscending: true,
                sortColumnIndex: 0,
                columns: <DataColumn>[
                  DataColumn(
                    label: Text(
                      'Name',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                    onSort: (i, d) {},
                  ),
                  DataColumn(
                    label: Text(
                      'Age',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Role',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
                rows: const <DataRow>[
                  DataRow(
                    cells: <DataCell>[
                      DataCell(Text('Sarah')),
                      DataCell(Text('19')),
                      DataCell(Text('Student')),
                    ],
                  ),
                  DataRow(
                    cells: <DataCell>[
                      DataCell(Text('Janine')),
                      DataCell(Text('43')),
                      DataCell(Text('Professor')),
                    ],
                  ),
                  DataRow(
                    cells: <DataCell>[
                      DataCell(Text('William')),
                      DataCell(Text('27')),
                      DataCell(Text('Associate Professor')),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
