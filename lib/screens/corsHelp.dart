import 'package:flutter/material.dart';

class CorsHelp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final firstRoute = ModalRoute.of(context)?.isFirst ?? true;
    List<Widget>? actions = [];
    if (firstRoute) {
      actions.add(IconButton(
          icon: Icon(Icons.login),
          onPressed: () {
            Navigator.of(context).pushReplacementNamed('dashboard');
          }));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('How to setup CORS'),
        actions: actions,
      ),
      body: ListView(
        padding: EdgeInsets.all(20),
        children: [
          ListTile(
            title: Text('!NOTE!'),
            subtitle: Text(
                'CORS is needed if Caladrius is running on a different domain as CouchDB. If you use the same no changes are required'),
          ),
          ListTile(
            title: Text('1. Enable CORS'),
            subtitle: Text(
                'Login to Fauxton as an admin user and select the Config menu. Within the menu select CORS. Click the enable button'),
          ),
          ListTile(
            title: Text('2. Set Origin Domains'),
            subtitle: Text(
                'Please add the Caldrius domain to the white list. A value of * will NOT work!'),
          ),
        ],
      ),
    );
  }
}
