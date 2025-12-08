import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sazon_recetas/features/features.dart';

part 'recipe_detail_state.dart';

class RecipeDetailCubit extends Cubit<RecipeDetailState> {
  final RecipesRepository repository;

  RecipeDetailCubit({required this.repository})
    : super(RecipeDetailState.initial());

  Future<void> loadRecipe(int recipeId) async {
    emit(
      state.copyWith(status: RecipeDetailStatus.loading, errorMessage: null),
    );

    try {
      final detail = await repository.getRecipeDetail(recipeId);
      emit(
        state.copyWith(
          status: RecipeDetailStatus.loaded,
          detail: detail,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: RecipeDetailStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
