import 'package:flutter/material.dart';

import 'package:sazon_recetas/features/features.dart';
import 'package:sazon_recetas/routes/routes.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (_) => const RootPage(),
          settings: settings,
        );
      case AppRoutes.login:
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
          settings: settings,
        );
      case AppRoutes.register:
        return MaterialPageRoute(
          builder: (_) => const RegisterPage(),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const RootPage(),
          settings: settings,
        );
    }
  }
}
