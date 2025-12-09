import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sazon_recetas/core/core.dart';
import 'package:sazon_recetas/features/features.dart';

class RecipeDetailPage extends StatelessWidget {
  final int recipeId;

  const RecipeDetailPage({super.key, required this.recipeId});

  @override
  Widget build(BuildContext context) {
    final apiClient = context.read<ApiClient>();
    final repository = RecipesRepository(apiClient: apiClient);

    return BlocProvider(
      create: (context) =>
          RecipeDetailCubit(repository: repository)..loadRecipe(recipeId),
      child: _RecipeDetailView(),
    );
  }
}

class _RecipeDetailView extends StatelessWidget {
  const _RecipeDetailView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle de receta'),
        actions: [
          BlocBuilder<RecipeDetailCubit, RecipeDetailState>(
            builder: (context, state) {
              if (state.status != RecipeDetailStatus.loaded ||
                  state.detail == null) {
                return const SizedBox.shrink();
              }

              final detail = state.detail!;
              final recipe = detail.recipe;

              final favoritesState = context.watch<FavoritesCubit>().state;
              final isFavorite = favoritesState.favoriteIds.contains(recipe.id);

              return Row(
                children: [
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_outline,
                      color: isFavorite ? Colors.redAccent : null,
                    ),
                    onPressed: () async {
                      await context.read<FavoritesCubit>().toggleFavorite(
                        recipe.id,
                      );
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () async {
                      final result = await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => RecipeFormPage(initialDetail: detail),
                        ),
                      );

                      if (!context.mounted) return;

                      if (result != null) {
                        // Recargar los detalles de la receta después de la edición
                        context.read<RecipeDetailCubit>().loadRecipe(
                          detail.recipe.id,
                        );

                        // Snackbar de confirmación
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Receta actualizada correctamente'),
                          ),
                        );
                      }
                    },
                  ),
                  IconButton(
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Eliminar receta'),
                          content: const Text(
                            '¿Estás seguro de que deseas eliminar esta receta?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(false),
                              child: const Text('Cancelar'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(true),
                              child: const Text('Eliminar'),
                            ),
                          ],
                        ),
                      );

                      if (confirmed != true) return;
                      if (!context.mounted) return;

                      try {
                        final apiClient = context.read<ApiClient>();
                        final repository = RecipesRepository(
                          apiClient: apiClient,
                        );

                        await repository.deleteRecipe(detail.recipe.id);

                        // Return to previous screen
                        if (context.mounted) {
                          Navigator.of(context).pop('deleted');
                        }
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Error al eliminar la receta: ${e.toString()}',
                            ),
                          ),
                        );
                      }
                    },
                    icon: Icon(Icons.delete_outline),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<RecipeDetailCubit, RecipeDetailState>(
          builder: (context, state) {
            switch (state.status) {
              case RecipeDetailStatus.initial:
                return const SizedBox.shrink();

              case RecipeDetailStatus.loading:
                return const Center(child: CircularProgressIndicator());

              case RecipeDetailStatus.error:
                return Center(
                  child: Text(
                    state.errorMessage ?? 'Error al cargar la receta',
                  ),
                );

              case RecipeDetailStatus.loaded:
                if (state.detail == null) {
                  return const Center(child: Text('No se encontró la receta'));
                }

                return _RecipeDetailContent(detail: state.detail!);
            }
          },
        ),
      ),
    );
  }
}

class _RecipeDetailContent extends StatelessWidget {
  final RecipeDetail detail;

  const _RecipeDetailContent({required this.detail});

  @override
  Widget build(BuildContext context) {
    final recipe = detail.recipe;
    final textTheme = Theme.of(context).textTheme;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            recipe.title,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Description
          if (recipe.description != null &&
              recipe.description!.trim().isNotEmpty)
            Text(recipe.description!, style: textTheme.bodyMedium),
          const SizedBox(height: 16),

          // Meta info chips (time, difficulty, servings)
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _MetaChip(icon: Icons.schedule, label: _buildTimeLabel(recipe)),
              _MetaChip(
                icon: Icons.leaderboard,
                label: recipe.difficulty.label,
              ),
              if (recipe.servings != null)
                _MetaChip(
                  icon: Icons.restaurant,
                  label: '${recipe.servings} porciones',
                ),
            ],
          ),
          const SizedBox(height: 24),

          // Ingredients
          Text(
            'Ingredientes',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          if (detail.ingredients.isEmpty)
            Text(
              'No hay ingredientes registrados.',
              style: textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: detail.ingredients.map((ing) {
                final quantity =
                    (ing.quantity != null && ing.quantity!.trim().isNotEmpty)
                    ? ' - ${ing.quantity}'
                    : '';

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      const Text('• '),
                      Expanded(
                        child: Text(
                          '${ing.name}$quantity',
                          style: textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          const SizedBox(height: 24),

          // Pasos
          Text(
            'Pasos',
            style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          if (detail.steps.isEmpty)
            Text(
              'No hay pasos registrados.',
              style: textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: detail.steps.map((step) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${step.stepNumber}. ',
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          step.description,
                          style: textTheme.bodyMedium,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  String _buildTimeLabel(Recipe recipe) {
    final prep = recipe.prepTimeMinutes ?? 0;
    final cook = recipe.cookTimeMinutes ?? 0;
    final total = (prep + cook);

    if (total == 0) return 'Tipo no especificado';
    if (prep > 0 && cook > 0) {
      return '$total min (prep: $prep, cocción: $cook)';
    }
    return '$total min';
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
