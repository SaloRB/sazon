import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sazon_recetas/core/core.dart';
import 'package:sazon_recetas/features/auth/auth.dart';
import 'package:sazon_recetas/routes/routes.dart';
import 'package:sazon_recetas/theme/app_theme.dart';

void main() {
  Bloc.observer = AppBlocObserver();

  // Initialize base services
  final secureStorageService = SecureStorageService();
  final authTokenStorage = AuthTokenStorage(storage: secureStorageService);
  final apiClient = ApiClient(tokenStorage: authTokenStorage);
  final authRepository = AuthRepository(apiClient: apiClient);

  runApp(
    SazonApp(
      apiClient: apiClient,
      authTokenStorage: authTokenStorage,
      authRepository: authRepository,
    ),
  );
}

class SazonApp extends StatelessWidget {
  final ApiClient apiClient;
  final AuthTokenStorage authTokenStorage;
  final AuthRepository authRepository;

  const SazonApp({
    super.key,
    required this.apiClient,
    required this.authTokenStorage,
    required this.authRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (_) => AuthCubit(
            authRepository: authRepository,
            tokenStorage: authTokenStorage,
          )..checkSession(),
        ),
      ],
      child: MaterialApp(
        title: 'Sazón',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        initialRoute: AppRoutes.home,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}
