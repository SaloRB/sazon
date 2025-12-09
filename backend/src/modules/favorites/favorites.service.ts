import { RecipeRepository } from '../recipes/recipe.repository'
import { FavoritesRepository } from './favorites.repository'

export class FavoritesService {
  constructor(
    private readonly favoritesRepo: FavoritesRepository,
    private readonly recipesRepo: RecipeRepository
  ) {}

  /**
   * Mark a recipe as favorite for a user.
   */
  async markAsFavorite(userId: number, recipeId: number): Promise<void> {
    // 1. Check if the recipe exists
    const recipe = await this.recipesRepo.findById(recipeId)
    if (!recipe) {
      throw new Error('RECIPE_NOT_FOUND')
    }

    //2. Add to favorites (idempotent because of unique constraint)
    await this.favoritesRepo.addFavorite(userId, recipeId)
  }

  /**
   * Unmark a recipe as favorite for a user.
   */
  async unmarkFavorite(userId: number, recipeId: number): Promise<void> {
    // Optionally, check if the favorite exists before deletion
    // but it's not strictly necessary if the repository handles it gracefully
    await this.favoritesRepo.removeFavorite(userId, recipeId)
  }

  /**
   * Get all favorite recipes for a user.
   */
  async getUserFavorites(userId: number) {
    const recipes = await this.favoritesRepo.listFavoritesForUser(userId)
    return recipes
  }
}
