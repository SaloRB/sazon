part of 'recipe_form_cubit.dart';

enum RecipeFormMode { create, edit }

enum RecipeFormStatus { idle, saving, success, error }

class RecipeFormState extends Equatable {
  final RecipeFormMode mode;
  final RecipeDetail? initialDetail; // only on edit mode
  final RecipeDetail? result; // result after save
  final RecipeFormStatus status;
  final String? errorMessage;

  const RecipeFormState({
    required this.mode,
    required this.status,
    this.initialDetail,
    this.result,
    this.errorMessage,
  });

  factory RecipeFormState.create() {
    return const RecipeFormState(
      mode: RecipeFormMode.create,
      status: RecipeFormStatus.idle,
      initialDetail: null,
      result: null,
      errorMessage: null,
    );
  }

  factory RecipeFormState.edit(RecipeDetail detail) {
    return RecipeFormState(
      mode: RecipeFormMode.edit,
      status: RecipeFormStatus.idle,
      initialDetail: detail,
      result: null,
      errorMessage: null,
    );
  }

  RecipeFormState copyWith({
    RecipeFormMode? mode,
    RecipeDetail? initialDetail,
    RecipeDetail? result,
    RecipeFormStatus? status,
    String? errorMessage,
  }) {
    return RecipeFormState(
      mode: mode ?? this.mode,
      initialDetail: initialDetail ?? this.initialDetail,
      result: result ?? this.result,
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    mode,
    initialDetail,
    result,
    status,
    errorMessage,
  ];
}
