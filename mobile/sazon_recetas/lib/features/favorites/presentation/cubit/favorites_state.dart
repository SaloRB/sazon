part of 'favorites_cubit.dart';

enum FavoritesStatus { initial, loading, loaded, updating, error }

class FavoritesState extends Equatable {
  final FavoritesStatus status;
  final Set<int> favoriteIds;
  // final List<Recipe> favoriteRecipes;
  final String? errorMessage;

  const FavoritesState({
    required this.status,
    required this.favoriteIds,
    // required this.favoriteRecipes,
    required this.errorMessage,
  });

  factory FavoritesState.initial() {
    return FavoritesState(
      status: FavoritesStatus.initial,
      favoriteIds: <int>{},
      // favoriteRecipes: <Recipe>[],
      errorMessage: null,
    );
  }

  FavoritesState copyWith({
    FavoritesStatus? status,
    Set<int>? favoriteIds,
    // List<Recipe>? favoriteRecipes,
    String? errorMessage,
  }) {
    return FavoritesState(
      status: status ?? this.status,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      // favoriteRecipes: favoriteRecipes ?? this.favoriteRecipes,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    favoriteIds,
    // favoriteRecipes,
    errorMessage,
  ];
}
