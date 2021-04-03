import 'package:flutter/widgets.dart';

extension ViewMode on Widget {
  bool renderMobileMode(BuildContext context) {
    return MediaQuery.of(context).size.width < 600;
  }
}
