import 'package:sazon_recetas/features/features.dart';

class Recipe {
  final int id;
  final int userId;
  final String title;
  final String? description;
  final RecipeDifficulty difficulty; // 'easy' | 'medium' | 'hard'
  final int? prepTimeMinutes;
  final int? cookTimeMinutes;
  final int? servings;
  final DateTime createdAt;
  final DateTime updatedAt;

  Recipe({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.difficulty,
    required this.prepTimeMinutes,
    required this.cookTimeMinutes,
    required this.servings,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      id: json['id'] as int,
      userId: json['userId'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      difficulty: RecipeDifficultyExt.fromApi(json['difficulty'] as String),
      prepTimeMinutes: json['prepTimeMinutes'] as int?,
      cookTimeMinutes: json['cookTimeMinutes'] as int?,
      servings: json['servings'] as int?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  @override
  String toString() => 'Recipe{id: $id, userId: $userId, title: $title}';
}

class RecipeIngredient {
  final int id;
  final int recipeId;
  final String name;
  final String? quantity;
  final int position;

  RecipeIngredient({
    required this.id,
    required this.recipeId,
    required this.name,
    required this.quantity,
    required this.position,
  });

  factory RecipeIngredient.fromJson(Map<String, dynamic> json) {
    return RecipeIngredient(
      id: json['id'] as int,
      recipeId: json['recipeId'] as int,
      name: json['name'] as String,
      quantity: json['quantity'] as String?,
      position: json['position'] as int,
    );
  }
}

class RecipeStep {
  final int id;
  final int recipeId;
  final int stepNumber;
  final String description;

  RecipeStep({
    required this.id,
    required this.recipeId,
    required this.stepNumber,
    required this.description,
  });

  factory RecipeStep.fromJson(Map<String, dynamic> json) {
    return RecipeStep(
      id: json['id'] as int,
      recipeId: json['recipeId'] as int,
      stepNumber: json['stepNumber'] as int,
      description: json['description'] as String,
    );
  }
}

/// For detailed recipe view: recipe + ingredients + steps
class RecipeDetail {
  final Recipe recipe;
  final List<RecipeIngredient> ingredients;
  final List<RecipeStep> steps;

  RecipeDetail({
    required this.recipe,
    required this.ingredients,
    required this.steps,
  });

  factory RecipeDetail.fromJson(Map<String, dynamic> json) {
    final recipeJson = json['recipe'] as Map<String, dynamic>;
    final ingredientsJson = (json['ingredients'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();
    final stepsJson = (json['steps'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();

    return RecipeDetail(
      recipe: Recipe.fromJson(recipeJson),
      ingredients: ingredientsJson
          .map((item) => RecipeIngredient.fromJson(item))
          .toList(),
      steps: stepsJson.map((item) => RecipeStep.fromJson(item)).toList(),
    );
  }
}
