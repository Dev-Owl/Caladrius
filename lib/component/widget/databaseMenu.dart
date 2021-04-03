import 'package:flutter/material.dart';
import 'package:caladrius/core/helper.dart';

class DatabaseMenu extends StatelessWidget {
  final String databaseName;

  final VoidCallback? allDocuments;
  final VoidCallback? views;
  final VoidCallback? designDocuments;
  final VoidCallback? backToDashboard;
  final int activeMenu;

  const DatabaseMenu(this.databaseName,
      {Key? key,
      this.allDocuments,
      this.views,
      this.designDocuments,
      this.activeMenu = 1,
      this.backToDashboard})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        DrawerHeader(
          decoration: BoxDecoration(
            color: Colors.blue,
          ),
          padding: EdgeInsets.all(4),
          child: renderListHeader(context),
        ),
        ListTile(
          selected: activeMenu == 1,
          leading: Icon(Icons.copy),
          title: Text('All documents'),
          onTap: handleMenuTap(context, allDocuments),
        ),
        ListTile(
          selected: activeMenu == 2,
          leading: Icon(Icons.filter_list_alt),
          title: Text('Views'),
          onTap: handleMenuTap(context, views),
        ),
        ListTile(
          selected: activeMenu == 3,
          leading: Icon(Icons.brush_outlined),
          title: Text('Design documents'),
          onTap: handleMenuTap(context, designDocuments),
        )
      ],
    );
  }

  Widget renderListHeader(BuildContext context) {
    final mobileMode = renderMobileMode(context);
    final databaseLabel = Text(
      databaseName,
      overflow: TextOverflow.ellipsis,
      maxLines: 3,
      style: const TextStyle(fontSize: 18),
    );
    if (mobileMode) {
      return databaseLabel;
    } else {
      return IconButton(
        icon: Wrap(
          children: [
            Icon(Icons.chevron_left_rounded),
            databaseLabel,
          ],
        ),
        onPressed: backToDashboard ??
            () {
              if (Navigator.of(context).canPop()) {
                Navigator.of(context).pop();
              } else {
                Navigator.of(context).pushNamed('dashboard');
              }
            },
        padding: EdgeInsets.zero,
        alignment: Alignment.centerLeft,
      );
    }
  }

  VoidCallback? handleMenuTap(
      BuildContext context, VoidCallback? externalCallback) {
    if (externalCallback == null) {
      return null;
    }
    if (renderMobileMode(context)) {
      return () {
        Navigator.of(context).pop();
        externalCallback();
      };
    }
    return externalCallback;
  }
}
