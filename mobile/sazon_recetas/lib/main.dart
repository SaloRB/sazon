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
    RepositoryProvider<ApiClient>.value(
      value: apiClient,
      child: SazonApp(
        apiClient: apiClient,
        authTokenStorage: authTokenStorage,
        authRepository: authRepository,
        recipesRepository: recipesRepository,
      ),
    ),
  );
}

class SazonApp extends StatelessWidget {
  final ApiClient apiClient;
  final AuthTokenStorage authTokenStorage;
  final AuthRepository authRepository;
  final RecipesRepository recipesRepository;

  const SazonApp({
    super.key,
    required this.apiClient,
    required this.authTokenStorage,
    required this.authRepository,
    required this.recipesRepository,
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
        BlocProvider<FavoritesCubit>(
          create: (_) =>
              FavoritesCubit(repository: recipesRepository)..loadFavorites(),
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
