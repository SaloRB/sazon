import 'package:sazon_recetas/features/features.dart';

class IngredientInput {
  final String name;
  final String? quantity;
  final int? position;

  IngredientInput({
    required this.name,
    required this.quantity,
    required this.position,
  });

  Map<String, dynamic> toJson() {
    return {'name': name, 'quantity': quantity, 'position': position};
  }
}

class StepInput {
  final int stepNumber;
  final String description;

  StepInput({required this.stepNumber, required this.description});

  Map<String, dynamic> toJson() {
    return {'stepNumber': stepNumber, 'description': description};
  }
}

class CreateRecipeInput {
  final String title;
  final String? description;
  final RecipeDifficulty? difficulty; // 'easy' | 'medium' | 'hard'
  final int? prepTimeMinutes;
  final int? cookTimeMinutes;
  final int? servings;
  final List<IngredientInput> ingredients;
  final List<StepInput> steps;

  CreateRecipeInput({
    required this.title,
    this.description,
    this.difficulty,
    this.prepTimeMinutes,
    this.cookTimeMinutes,
    this.servings,
    this.ingredients = const [],
    this.steps = const [],
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'difficulty': difficulty?.apiValue,
      'prepTimeMinutes': prepTimeMinutes,
      'cookTimeMinutes': cookTimeMinutes,
      'servings': servings,
      'ingredients': ingredients.map((ing) => ing.toJson()).toList(),
      'steps': steps.map((step) => step.toJson()).toList(),
    };
  }
}

class UpdateRecipeInput {
  final String? title;
  final String? description;
  final RecipeDifficulty? difficulty; // 'easy' | 'medium' | 'hard'
  final int? prepTimeMinutes;
  final int? cookTimeMinutes;
  final int? servings;
  final List<IngredientInput>? ingredients;
  final List<StepInput>? steps;

  UpdateRecipeInput({
    this.title,
    this.description,
    this.difficulty,
    this.prepTimeMinutes,
    this.cookTimeMinutes,
    this.servings,
    this.ingredients,
    this.steps,
  });

  Map<String, dynamic> toJson() {
    return {
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (difficulty != null) 'difficulty': difficulty!.apiValue,
      if (prepTimeMinutes != null) 'prepTimeMinutes': prepTimeMinutes,
      if (cookTimeMinutes != null) 'cookTimeMinutes': cookTimeMinutes,
      if (servings != null) 'servings': servings,
      if (ingredients != null)
        'ingredients': ingredients!.map((ing) => ing.toJson()).toList(),
      if (steps != null) 'steps': steps!.map((step) => step.toJson()).toList(),
    };
  }
}
