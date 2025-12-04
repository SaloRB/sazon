import 'package:flutter/material.dart';

import 'package:sazon_recetas/routes/routes.dart';
import 'package:sazon_recetas/theme/app_theme.dart';

void main() {
  runApp(const SazonApp());
}

class SazonApp extends StatelessWidget {
  const SazonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sazón',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRoutes.home,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
