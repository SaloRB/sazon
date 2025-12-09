import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sazon_recetas/features/features.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocBuilder<FavoritesCubit, FavoritesState>(
      builder: (context, state) {
        Widget body;

        switch (state.status) {
          case FavoritesStatus.initial:
          case FavoritesStatus.loading:
            body = const Center(child: CircularProgressIndicator());
            break;

          case FavoritesStatus.error:
            body = Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('No se pudieron cargar tus favoritos'),
                  const SizedBox(height: 8),
                  Text(
                    state.errorMessage ?? '',
                    style: textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<FavoritesCubit>().loadFavorites();
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
            break;

          case FavoritesStatus.loaded:
          case FavoritesStatus.updating:
            if (state.favoriteRecipes.isEmpty) {
              body = Center(
                child: const Text('Aún no tienes recetas favoritas.'),
              );
            } else {
              body = RefreshIndicator(
                onRefresh: () =>
                    context.read<FavoritesCubit>().refreshFavorites(),
                child: ListView.builder(
                  itemCount: state.favoriteRecipes.length,
                  itemBuilder: (context, index) {
                    final recipe = state.favoriteRecipes[index];
                    return _FavoriteRecipeCard(recipe: recipe);
                  },
                ),
              );
            }
            break;
        }

        return Scaffold(
          appBar: AppBar(title: const Text('Mis favoritos')),
          body: Padding(padding: const EdgeInsets.all(16.0), child: body),
        );
      },
    );
  }
}

class _FavoriteRecipeCard extends StatelessWidget {
  final Recipe recipe;

  const _FavoriteRecipeCard({required this.recipe});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        title: Text(recipe.title),
        subtitle: _buildSubtitle(context),
        onTap: () async {
          final result = await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => RecipeDetailPage(recipeId: recipe.id),
            ),
          );

          if (!context.mounted) return;

          if (result == 'deleted') {
            await context.read<FavoritesCubit>().loadFavorites();

            if (!context.mounted) return;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Receta eliminada de favoritos')),
            );
          }
        },
      ),
    );
  }

  Widget? _buildSubtitle(BuildContext context) {
    final pieces = <String>[];

    pieces.add('Dificultad: ${recipe.difficulty.label}');

    final totalTime =
        (recipe.prepTimeMinutes ?? 0) + (recipe.cookTimeMinutes ?? 0);

    if (totalTime > 0) {
      pieces.add('Tiempo total: $totalTime min');
    }

    if (recipe.servings != null) {
      pieces.add('Porciones: ${recipe.servings}');
    }

    if (pieces.isEmpty) return null;

    return Text(pieces.join(' • '));
  }
}
