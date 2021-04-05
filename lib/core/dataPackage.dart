import 'dart:math';

import 'package:flutter/material.dart';

/*
Seems like the paged datatable doesnt support loading pages one by one
It needs to have all data up front
*/

class DataPackage extends DataTableSource {
  final int offset;
  final List<Map<String, dynamic>> data;
  int totalRows;
  int sortIndex = 0;
  bool sortAscending = true;
  void Function(Map<String, dynamic>, String)? onCelltap;
  List<DataColumn>? _cachedColumn;
  int get currentRows => data.length;

  DataPackage(this.totalRows, this.offset, this.data) {
    sort();
  }

  void sort() {
    data.sort((a, b) {
      late Map<String, dynamic> element1;
      late Map<String, dynamic> element2;
      final key = a.keys.elementAt(sortIndex);
      if (!sortAscending) {
        element1 = a;
        element2 = b;
      } else {
        element2 = a;
        element1 = b;
      }
      if (_cachedColumn != null && _cachedColumn![sortIndex].numeric) {
        return num.tryParse(element1[key])
                ?.compareTo(num.tryParse(element2[key]) ?? 0) ??
            0;
      } else {
        return element1[key]
                ?.toString()
                .compareTo(element2[key]?.toString() ?? '') ??
            0;
      }
    });
    notifyListeners();
  }

  List<DataColumn> getColumns(Function(int, bool) onSort) {
    if (_cachedColumn == null) {
      //Default implementation for rows based on the first element
      final firstObject = data.first;
      _cachedColumn = firstObject.keys.map((e) {
        final current = firstObject[e];
        if (current is String || current is num) {
          return DataColumn(
            label: Text(e),
            numeric: current is num,
            onSort: onSort,
          );
        }
        return DataColumn(
          label: Text(e),
        );
      }).toList();
      return _cachedColumn!;
    } else {
      return _cachedColumn!;
    }
  }

  @override
  DataRow? getRow(int index) {
    final currentRow = data[index];
    return DataRow(
      cells: currentRow.keys.map((e) {
        final currentCell = currentRow[e];
        if (currentCell is String || currentCell is num) {
          return DataCell(
            Text(
              currentCell.toString(),
            ),
            onTap: () {
              if (onCelltap != null) {
                onCelltap!(currentRow, e);
              }
            },
          );
        } else {
          final content = currentCell.toString();
          return DataCell(
            Text(
              content.substring(
                0,
                min(
                  content.length,
                  35,
                ),
              ),
            ),
            onTap: () {
              if (onCelltap != null) {
                onCelltap!(currentRow, e);
              }
            },
          );
        }
      }).toList(),
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => totalRows - offset;

  @override
  int get selectedRowCount => 0;
}
