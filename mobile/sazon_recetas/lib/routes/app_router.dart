import 'package:flutter/material.dart';
import 'package:sazon_recetas/features/recipes/presentation/home_recipes_page.dart';
import 'package:sazon_recetas/routes/app_routes.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.home:
      default:
        return MaterialPageRoute(
          builder: (_) => const HomeRecipesPage(),
          settings: settings,
        );
    }
  }
}
