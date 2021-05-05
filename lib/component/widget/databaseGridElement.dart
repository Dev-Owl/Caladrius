import 'package:flutter/material.dart';

typedef DbTapCallback = void Function(String databaseName);

class DatabaseGridElement extends StatelessWidget {
  final DbTapCallback? onTap;
  final String databaseName;
  final bool selected;
  const DatabaseGridElement(
    this.databaseName,
    this.onTap,
    this.selected, {
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap?.call(databaseName),
      child: Container(
        alignment: Alignment.center,
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
            color: selected
                ? Colors.amber[800]
                : Colors.amberAccent,
            borderRadius: BorderRadius.circular(15)),
        child: Text(
          databaseName,
        ),
      ),
    );
  }
}
