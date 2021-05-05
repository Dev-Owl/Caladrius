import 'package:flutter/material.dart';

class EmptyWidget extends StatelessWidget {
  final String title;
  final String? subTitle;
  final IconData? icon;
  final String? assetImage;

  const EmptyWidget(this.title,
      {Key? key, this.subTitle, this.icon, this.assetImage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    late final Widget child;
    if (icon != null) {
      final size = MediaQuery.of(context).size;
      child = Icon(
        icon,
        size: size.width * 0.1,
      );
    } else if (assetImage != null) {
    } else {}

    return buildContainter(context, child);
  }

/*
  Widget buildIconVersion() {}
  Widget buildAssetVersion() {}
  Widget buildTextVersion() {}
*/
  Widget buildContainter(
    BuildContext context,
    Widget child,
  ) {
    final size = MediaQuery.of(context).size;
    return Container(
      width: size.width * 0.35,
      height: size.height * 0.35,
      decoration: BoxDecoration(boxShadow: <BoxShadow>[
        BoxShadow(
          offset: Offset(0, 0),
          color: Color(0xffe2e5ed),
        ),
        BoxShadow(
            blurRadius: 30,
            offset: Offset(20, 0),
            color: Color(0xffffffff),
            spreadRadius: -5),
      ], shape: BoxShape.circle),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          child,
          Text(
            title,
            style: TextStyle(
              color: Color(0xffa3a6ad),
              fontSize: 25,
            ),
          ),
        ],
      ),
    );
  }
}
