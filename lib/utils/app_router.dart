// Flutter imports:
import 'package:flutter/material.dart';
import 'package:vehicle_sharing_app/screens/onboarding_page.dart';

import '../main.dart';

class AppRouter {
  static Map<String, WidgetBuilder> routes = {
    AuthenticationWrapper.routeName: (_) => const AuthenticationWrapper(),
    OnboradingPage.routeName: (_) => const OnboradingPage(),
  };
}
