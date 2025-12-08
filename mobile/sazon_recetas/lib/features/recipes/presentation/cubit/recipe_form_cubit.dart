import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sazon_recetas/features/features.dart';

part 'recipe_form_state.dart';

class RecipeFormCubit extends Cubit<RecipeFormState> {
  final RecipesRepository repository;

  RecipeFormCubit.create({required this.repository})
    : super(RecipeFormState.create());

  RecipeFormCubit.edit({
    required this.repository,
    required RecipeDetail initialDetail,
  }) : super(RecipeFormState.edit(initialDetail));

  Future<void> submitCreate(CreateRecipeInput input) async {
    emit(state.copyWith(status: RecipeFormStatus.saving, errorMessage: null));

    try {
      final detail = await repository.createRecipe(input);
      emit(
        state.copyWith(
          status: RecipeFormStatus.success,
          result: detail,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: RecipeFormStatus.error,
          errorMessage: 'No se pudo crear la receta. Inténtalo de nuevo.',
        ),
      );
    }
  }

  Future<void> submitUpdate(UpdateRecipeInput input) async {
    if (state.initialDetail == null) {
      emit(
        state.copyWith(
          status: RecipeFormStatus.error,
          errorMessage: 'No hay receta para actualizar.',
        ),
      );
      return;
    }

    emit(state.copyWith(status: RecipeFormStatus.saving, errorMessage: null));

    try {
      final recipeId = state.initialDetail!.recipe.id;
      final detail = await repository.updateRecipe(recipeId, input);
      emit(
        state.copyWith(
          status: RecipeFormStatus.success,
          result: detail,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: RecipeFormStatus.error,
          errorMessage: 'No se pudo actualizar la receta. Inténtalo de nuevo.',
        ),
      );
    }
  }
}
