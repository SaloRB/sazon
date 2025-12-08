enum RecipeDifficulty { easy, medium, hard }

extension RecipeDifficultyExt on RecipeDifficulty {
  String get label {
    switch (this) {
      case RecipeDifficulty.easy:
        return 'Fácil';
      case RecipeDifficulty.medium:
        return 'Media';
      case RecipeDifficulty.hard:
        return 'Difícil';
    }
  }

  /// Converts an enum -> value for API (e.g., RecipeDifficulty.easy -> 'easy')
  String get apiValue {
    switch (this) {
      case RecipeDifficulty.easy:
        return 'easy';
      case RecipeDifficulty.medium:
        return 'medium';
      case RecipeDifficulty.hard:
        return 'hard';
    }
  }

  /// Converts a value from API -> enum (e.g., 'easy' -> RecipeDifficulty.easy)
  static RecipeDifficulty fromApi(String value) {
    switch (value) {
      case 'easy':
        return RecipeDifficulty.easy;
      case 'medium':
        return RecipeDifficulty.medium;
      case 'hard':
        return RecipeDifficulty.hard;
      default:
        throw ArgumentError('Invalid RecipeDifficulty value: $value');
    }
  }
}
