part of 'recipe_detail_cubit.dart';

enum RecipeDetailStatus { initial, loading, loaded, error }

class RecipeDetailState extends Equatable {
  final RecipeDetailStatus status;
  final RecipeDetail? detail;
  final String? errorMessage;

  const RecipeDetailState({
    required this.status,
    required this.detail,
    required this.errorMessage,
  });

  factory RecipeDetailState.initial() {
    return const RecipeDetailState(
      status: RecipeDetailStatus.initial,
      detail: null,
      errorMessage: null,
    );
  }

  RecipeDetailState copyWith({
    RecipeDetailStatus? status,
    RecipeDetail? detail,
    String? errorMessage,
  }) {
    return RecipeDetailState(
      status: status ?? this.status,
      detail: detail ?? this.detail,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, detail, errorMessage];
}
