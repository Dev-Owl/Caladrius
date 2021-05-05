import 'package:caladrius/component/bootstrap/bootstrap.dart';
import 'package:caladrius/screens/corsHelp.dart';
import 'package:caladrius/screens/dashboard.dart';
import 'package:caladrius/component/bootstrap/CaladriusBootstrap.dart';
import 'package:caladrius/screens/database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:universal_html/controller.dart';
import 'httpUrlHandler/httpUrlHandler_stub.dart'
    if (dart.library.io) 'httpUrlHandler/httpUrlHandler_app.dart'
    if (dart.library.html) 'httpUrlHandler/httpUrlHandler_web.dart';

class AppRouter {
  //Create a root that ensures a login/session
  static PageRoute bootstrapRoute(BootCompleted call, RoutingData data) =>
      _FadeRoute(
        CaladriusBootstrap(call),
        data.fullRoute,
        data,
      );
  //Create a simple route no login before
  static PageRoute pageRoute(
    Widget child,
    RoutingData data,
  ) =>
      _FadeRoute(
        child,
        data.fullRoute,
        data,
      );

  static Route<dynamic> generateRoute(RouteSettings settings) {
    late RoutingData data;
    if (settings.name == null) {
      data = RoutingData.home(); //Default route to dashboard
    } else {
      data = (settings.name ?? '').getRoutingData; //route to url
    }
    //Only the first segment defines the route
    switch (data.route.first) {
      case 'cors':
        {
          return pageRoute(CorsHelp(), data);
        }
      case 'database':
        {
          //If the database part is missing -> Dashboard
          if (data.route.length == 1) {
            return _default(data);
          } else {
            return bootstrapRoute(() => DatabaseView(), data);
          }
        }
      default:
        {
          //Fallback to the dashboard/login
          return _default(data);
        }
    }
  }

  static PageRoute _default(RoutingData data) {
    return bootstrapRoute(() => Dashboard(), data);
  }

  static void updateUrl(String newURL,{bool pushToHistory=true}){
    if(kIsWeb){
       final window = getWindow();
       if(pushToHistory){
         window.history.pushState(null, 'title', newURL);
       }
       //window.location.hash =newURL;
    }
  }
  static String getCurrentURL() => kIsWeb ? getWindow().location.href : '';

}

class RoutingData {
  @override
  int get hashCode => route.hashCode;

  final List<String> route;
  final Map<String, String> _queryParameters;

  String get fullRoute => Uri(
          pathSegments: route,
          queryParameters: _queryParameters.isEmpty ? null : _queryParameters)
      .toString();

  RoutingData(
    this.route,
    Map<String, String> queryParameters,
  ) : _queryParameters = queryParameters;

  //Our fallback to the dashboard
  RoutingData.home([this.route = const ['dashboard']]) : _queryParameters = {};

  String? operator [](String key) => _queryParameters[key];
}

extension StringExtension on String {
  RoutingData get getRoutingData {
    final uri = Uri.parse(this);

    return RoutingData(
      uri.pathSegments,
      uri.queryParameters,
    );
  }
}

class _FadeRoute extends PageRouteBuilder {
  final Widget child;
  final String routeName;
  final RoutingData data;
  _FadeRoute(
    this.child,
    this.routeName,
    this.data,
  ) : super(
          settings: RouteSettings(
            name: routeName,
            arguments: data,
          ),
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              child,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              FadeTransition(
            opacity: animation,
            child: child,
          ),
        );
}
