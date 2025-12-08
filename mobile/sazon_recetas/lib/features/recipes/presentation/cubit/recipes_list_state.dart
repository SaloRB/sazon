part of 'recipes_list_cubit.dart';

enum RecipesListStatus { initial, loading, loaded, error }

class RecipesListState extends Equatable {
  final RecipesListStatus status;
  final List<Recipe> recipes;
  final bool mine;
  final String? errorMessage;

  const RecipesListState({
    required this.status,
    required this.recipes,
    required this.mine,
    this.errorMessage,
  });

  factory RecipesListState.initial({bool mine = false}) {
    return RecipesListState(
      status: RecipesListStatus.initial,
      recipes: const [],
      mine: mine,
      errorMessage: null,
    );
  }

  RecipesListState copyWith({
    RecipesListStatus? status,
    List<Recipe>? recipes,
    bool? mine,
    String? errorMessage,
  }) {
    return RecipesListState(
      status: status ?? this.status,
      recipes: recipes ?? this.recipes,
      mine: mine ?? this.mine,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, recipes, errorMessage, mine];
}
