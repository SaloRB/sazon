import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:sazon_recetas/features/features.dart';

part 'recipes_list_state.dart';

class RecipesListCubit extends Cubit<RecipesListState> {
  final RecipesRepository _recipesRepository;

  RecipesListCubit({
    required RecipesRepository recipesRepository,
    bool mine = false,
  }) : _recipesRepository = recipesRepository,
       super(RecipesListState.initial(mine: mine));

  Future<void> loadRecipes() async {
    emit(state.copyWith(status: RecipesListStatus.loading, errorMessage: null));

    try {
      final recipes = await _recipesRepository.getRecipes(mine: state.mine);
      emit(
        state.copyWith(
          status: RecipesListStatus.loaded,
          recipes: recipes,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: RecipesListStatus.error,
          errorMessage: 'No se pudieron cargar las recetas.',
        ),
      );
    }
  }

  void toggleMine(bool mine) {
    emit(state.copyWith(mine: mine));
    loadRecipes();
  }
}
