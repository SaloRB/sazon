import { and, desc, eq } from 'drizzle-orm'
import { db, favorites, recipes } from '../../db'
import { title } from 'process'

export class FavoritesRepository {
  /**
   * Adds a recipe to the user's favorites.
   * If the recipe is already favorited by the user, does nothing.
   */
  async addFavorite(userId: number, recipeId: number): Promise<void> {
    await db
      .insert(favorites)
      .values({ userId, recipeId })
      .onConflictDoNothing()
  }

  /**
   * Removes a recipe from the user's favorites.
   */
  async removeFavorite(userId: number, recipeId: number): Promise<void> {
    await db
      .delete(favorites)
      .where(
        and(eq(favorites.userId, userId), eq(favorites.recipeId, recipeId))
      )
  }

  /**
   * Lists all favorite recipes for a given user.
   * Returns recipe data (not the favorite records).
   */
  async listFavoritesForUser(userId: number) {
    const rows = await db
      .select({
        id: recipes.id,
        userId: recipes.userId,
        title: recipes.title,
        description: recipes.description,
        difficulty: recipes.difficulty,
        prepTimeMinutes: recipes.prepTimeMinutes,
        cookTimeMinutes: recipes.cookTimeMinutes,
        servings: recipes.servings,
        createdAt: recipes.createdAt,
      })
      .from(favorites)
      .innerJoin(recipes, eq(favorites.recipeId, recipes.id))
      .where(eq(favorites.userId, userId))
      .orderBy(desc(favorites.createdAt))

    return rows
  }

  /**
   * Checks if a recipe is favorited by a user.
   * Useful to get isFavorite in GET /recipes/:id
   */
  async isFavorite(userId: number, recipeId: number): Promise<boolean> {
    const row = await db
      .select({ id: favorites.id })
      .from(favorites)
      .where(
        and(eq(favorites.userId, userId), eq(favorites.recipeId, recipeId))
      )
      .limit(1)

    return row.length > 0
  }
}
