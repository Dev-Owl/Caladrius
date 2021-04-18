import 'dart:math';

import 'package:advanced_datatable/advancedDataTableSource.dart';
import 'package:flutter/material.dart';

typedef LoadGenericDataCallBack
    = Future<RemoteDataSourceDetails<Map<String, dynamic>>> Function(
        int pageSize, int offset, bool asc);

class DataPackage extends AdvancedDataTableSource<Map<String, dynamic>> {
  int sortIndex = 1;
  bool sortAscending = true;
  void Function(Map<String, dynamic>, String)? onCelltap;
  final LoadGenericDataCallBack loadDataCallBack;

  DataPackage(this.loadDataCallBack,
      {this.onCelltap, this.sortAscending = false, this.sortIndex = 1});

  void sort(index, bool asc) {
    sortIndex = index;
    sortAscending = asc;
    notifyListeners();
    /*  data.sort((a, b) {
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
    */
  }

  @override
  DataRow? getRow(int index) {
    final currentRow = lastDetails!.rows[index];

    final row = DataRow(
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
    return row;
  }

  @override
  int get selectedRowCount => 0;

  @override
  Future<RemoteDataSourceDetails<Map<String, dynamic>>> getNextPage(
      int pagesize, int offset) async {
    return loadDataCallBack(pagesize, offset, sortAscending);
  }
}
