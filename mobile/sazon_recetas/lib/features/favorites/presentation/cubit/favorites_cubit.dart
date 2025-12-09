import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sazon_recetas/features/features.dart';

part 'favorites_state.dart';

class FavoritesCubit extends Cubit<FavoritesState> {
  final RecipesRepository _repository;

  FavoritesCubit({required RecipesRepository repository})
    : _repository = repository,
      super(FavoritesState.initial());

  /// Loads favorite recipes from backend.
  Future<void> loadFavorites() async {
    emit(state.copyWith(status: FavoritesStatus.loading, errorMessage: null));

    try {
      final favorites = await _repository.getMyFavorites();
      final ids = favorites.map((r) => r.id).toSet();

      emit(
        state.copyWith(
          status: FavoritesStatus.loaded,
          favoriteIds: ids,
          favoriteRecipes: favorites,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: FavoritesStatus.error,
          errorMessage: 'No se pudieron cargar las recetas favoritas.',
        ),
      );
    }
  }

  /// Check if a recipe is in favorites based on current state.
  bool isFavorite(int recipeId) {
    return state.favoriteIds.contains(recipeId);
  }

  /// Mark favorite
  Future<void> addFavorite(int recipeId) async {
    // Optimistic: update state before backend call
    final newIds = {...state.favoriteIds, recipeId};

    emit(
      state.copyWith(
        status: FavoritesStatus.updating,
        favoriteIds: newIds,
        errorMessage: null,
      ),
    );

    try {
      await _repository.markFavorite(recipeId);

      // Optionally, reload full favorites list
      // final favorites = await _repository.getMyFavorites();
      // emit(
      //   state.copyWith(
      //     status: FavoritesStatus.loaded,
      //     favoriteIds: favorites.map((r) => r.id).toSet(),
      //     favoriteRecipes: favorites,
      //     errorMessage: null,
      //   ),
      // );

      emit(state.copyWith(status: FavoritesStatus.loaded, errorMessage: null));
    } catch (e) {
      // In case of error, revert state
      final reverted = {...state.favoriteIds}..remove(recipeId);

      emit(
        state.copyWith(
          status: FavoritesStatus.error,
          favoriteIds: reverted,
          errorMessage: 'No se pudo agregar a favoritos.',
        ),
      );
    }
  }

  /// Unmark favorite (internally)
  Future<void> removeFavorite(int recipeId) async {
    final newIds = {...state.favoriteIds}..remove(recipeId);

    emit(
      state.copyWith(
        status: FavoritesStatus.updating,
        favoriteIds: newIds,
        errorMessage: null,
      ),
    );

    try {
      await _repository.unmarkFavorite(recipeId);

      emit(state.copyWith(status: FavoritesStatus.loaded, errorMessage: null));
    } catch (e) {
      // In case of error, revert state
      final reverted = {...state.favoriteIds}..add(recipeId);

      emit(
        state.copyWith(
          status: FavoritesStatus.error,
          favoriteIds: reverted,
          errorMessage: 'No se pudo remover de favoritos.',
        ),
      );
    }
  }

  /// Toggle favorite status
  Future<void> toggleFavorite(int recipeId) async {
    final isFav = isFavorite(recipeId);

    if (isFav) {
      await removeFavorite(recipeId);
    } else {
      await addFavorite(recipeId);
    }
  }

  /// Refresh favorites list from backend.
  ///
  /// Useful for pull-to-refresh.
  ///
  Future<void> refreshFavorites() => loadFavorites();
}
