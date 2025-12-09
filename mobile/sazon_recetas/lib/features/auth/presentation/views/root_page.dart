import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sazon_recetas/features/features.dart';

class RootPage extends StatelessWidget {
  const RootPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        final favoritesCubit = context.read<FavoritesCubit>();

        switch (state.status) {
          case AuthStatus.authenticated:
            favoritesCubit.loadFavorites();
            break;
          case AuthStatus.unauthenticated:
          case AuthStatus.unknown:
            favoritesCubit.clear();
            break;
        }
      },
      child: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          switch (state.status) {
            case AuthStatus.unknown:
              return const _SplashScreen();
            case AuthStatus.authenticated:
              return const RecipesHomePage();
            case AuthStatus.unauthenticated:
              return const AuthShellPage();
          }
        },
      ),
    );
  }
}

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
