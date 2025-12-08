import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sazon_recetas/core/core.dart';
import 'package:sazon_recetas/features/features.dart';

class RecipesHomePage extends StatefulWidget {
  const RecipesHomePage({super.key});

  @override
  State<RecipesHomePage> createState() => _RecipesHomePageState();
}

class _RecipesHomePageState extends State<RecipesHomePage> {
  @override
  Widget build(BuildContext context) {
    final apiClient = context.read<ApiClient>();
    final repository = RecipesRepository(apiClient: apiClient);

    return BlocProvider(
      create: (context) =>
          RecipesListCubit(recipesRepository: repository)..loadRecipes(),
      child: _RecipesHomeView(),
    );
  }
}

class _RecipesHomeView extends StatelessWidget {
  const _RecipesHomeView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sazón'),
        actions: [
          BlocBuilder<RecipesListCubit, RecipesListState>(
            builder: (context, state) {
              return PopupMenuButton(
                initialValue: state.mine,
                onSelected: (value) {
                  context.read<RecipesListCubit>().toggleMine(value);
                },
                itemBuilder: (context) => [
                  CheckedPopupMenuItem(
                    value: false,
                    checked: state.mine == false,
                    child: const Text('Todas'),
                  ),
                  CheckedPopupMenuItem(
                    value: true,
                    checked: state.mine == true,
                    child: const Text('Mis recetas'),
                  ),
                ],
                icon: const Icon(Icons.filter_list),
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<RecipesListCubit, RecipesListState>(
        builder: (context, state) {
          switch (state.status) {
            case RecipesListStatus.initial:
              return const SizedBox.shrink();
            case RecipesListStatus.loading:
              return const Center(child: CircularProgressIndicator());
            case RecipesListStatus.error:
              return Center(
                child: Text(state.errorMessage ?? 'Error al cargar recetas'),
              );
            case RecipesListStatus.loaded:
              if (state.recipes.isEmpty) {
                return const Center(child: Text('No hay recetas todavía'));
              }

              return RefreshIndicator(
                onRefresh: () => context.read<RecipesListCubit>().loadRecipes(),

                child: SafeArea(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    itemCount: state.recipes.length,
                    itemBuilder: (context, index) {
                      final recipe = state.recipes[index];
                      return _RecipeCard(recipe: recipe);
                    },
                  ),
                ),
              );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.background,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _RecipeCard extends StatelessWidget {
  final Recipe recipe;

  const _RecipeCard({required this.recipe});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => RecipeDetailPage(recipeId: recipe.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.restaurant_menu),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (recipe.description != null &&
                        recipe.description!.trim().isNotEmpty)
                      Text(
                        recipe.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[700],
                        ),
                      ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          _buildTimeLabel(recipe),
                          style: textTheme.bodySmall?.copyWith(
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.leaderboard,
                          size: 16,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          recipe.difficulty.label,
                          style: textTheme.bodySmall?.copyWith(
                            color: Colors.grey[700],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _buildTimeLabel(Recipe recipe) {
    final prep = recipe.prepTimeMinutes ?? 0;
    final cook = recipe.cookTimeMinutes ?? 0;
    final total = (prep + cook);

    if (total == 0) return 'Sin tiempo';
    return '$total min';
  }
}
