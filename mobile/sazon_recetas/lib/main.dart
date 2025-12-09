import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sazon_recetas/core/core.dart';
import 'package:sazon_recetas/features/features.dart';
import 'package:sazon_recetas/theme/app_theme.dart';

void main() {
  Bloc.observer = AppBlocObserver();

  // Initialize base services
  final secureStorageService = SecureStorageService();
  final authTokenStorage = AuthTokenStorage(storage: secureStorageService);
  final apiClient = ApiClient(tokenStorage: authTokenStorage);
  final authRepository = AuthRepository(apiClient: apiClient);
  final recipesRepository = RecipesRepository(apiClient: apiClient);

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ApiClient>.value(value: apiClient),
        RepositoryProvider<RecipesRepository>.value(value: recipesRepository),
      ],
      child: SazonApp(
        authTokenStorage: authTokenStorage,
        authRepository: authRepository,
      ),
    ),
  );
}

class SazonApp extends StatelessWidget {
  final AuthTokenStorage authTokenStorage;
  final AuthRepository authRepository;

  const SazonApp({
    super.key,
    required this.authTokenStorage,
    required this.authRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => AuthCubit(
            authRepository: authRepository,
            tokenStorage: authTokenStorage,
          )..checkSession(),
        ),
        BlocProvider(
          create: (context) =>
              FavoritesCubit(repository: context.read<RecipesRepository>()),
        ),
      ],
      child: MaterialApp(
        title: 'Sazón',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const RootPage(),
      ),
    );
  }
}
