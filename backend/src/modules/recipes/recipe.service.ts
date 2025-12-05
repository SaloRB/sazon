import { asc, eq } from 'drizzle-orm'

import {
  CreateRecipeInput,
  RecipeRepository,
  UpdateRecipeInput,
} from './recipe.repository'

import {
  db,
  Recipe,
  RecipeIngredient,
  recipeIngredients,
  recipes,
  RecipeStep,
  recipeSteps,
} from '../../db'

export class RecipeService {
  private repo: RecipeRepository

  constructor(repo?: RecipeRepository) {
    this.repo = repo ?? new RecipeRepository()
  }

  /**
   * Create a new recipe
   */
  async createRecipeForUser(
    userId: number,
    input: Omit<CreateRecipeInput, 'userId'>
  ): Promise<{
    recipe: Recipe
    ingredients: RecipeIngredient[]
    steps: RecipeStep[]
  }> {
    if (!input.title || input.title.trim().length === 0) {
      throw new Error('TITLE_REQUIRED')
    }

    const payload: CreateRecipeInput = {
      userId,
      title: input.title.trim(),
      description: input.description,
      difficulty: input.difficulty,
      prepTimeMinutes: input.prepTimeMinutes,
      cookTimeMinutes: input.cookTimeMinutes,
      servings: input.servings,
      ingredients: input.ingredients,
      steps: input.steps,
    }

    return this.repo.createRecipe(payload)
  }

  /**
   * Fetch a recipe with details (publicly accessible)
   */
  async getRecipeWithDetails(recipeId: number) {
    const data = await this.repo.findByIdWithDetails(recipeId)

    if (!data) {
      throw new Error('RECIPE_NOT_FOUND')
    }

    return data
  }

  /**
   * List recipes. If userId is provided and mine=true, fetch only recipes created by that user.
   */
  async listRecipes(params?: {
    userId?: number
    mine?: boolean
    limit?: number
    offset?: number
  }) {
    const { userId, mine, limit, offset } = params ?? {}

    if (mine && !userId) {
      throw new Error('USER_ID_REQUIRED_FOR_MINE')
    }

    if (mine && userId) {
      return this.repo.findAll({ userId, limit, offset })
    }

    // Public recipes
    return this.repo.findAll({ limit, offset })
  }

  /**
   * Update a recipe (only by its owner)
   */
  async updateRecipeForUser(
    userId: number,
    recipeId: number,
    input: UpdateRecipeInput
  ): Promise<{
    recipe: Recipe
    ingredients: RecipeIngredient[]
    steps: RecipeStep[]
  }> {
    // Verify existence
    const existing = await this.repo.findById(recipeId)
    if (!existing) {
      throw new Error('RECIPE_NOT_FOUND')
    }

    // Verify ownership
    if (existing.userId !== userId) {
      throw new Error('FORBIDDEN')
    }

    // Simple strategy: update metadata + replace ingredients/steps
    await db.transaction(async (tx) => {
      const updatedRecipe: Partial<Recipe> = {
        title: input.title?.trim() ?? existing.title,
        description: input.description ?? existing.description,
        difficulty: input.difficulty ?? existing.difficulty,
        prepTimeMinutes:
          input.prepTimeMinutes !== undefined
            ? input.prepTimeMinutes
            : existing.prepTimeMinutes,
        cookTimeMinutes:
          input.cookTimeMinutes !== undefined
            ? input.cookTimeMinutes
            : existing.cookTimeMinutes,
        servings:
          input.servings !== undefined ? input.servings : existing.servings,
      }

      // Update recipe metadata
      await tx
        .update(recipes)
        .set(updatedRecipe)
        .where(eq(recipes.id, recipeId))

      // Replace ingredients (if provided)
      if (input.ingredients) {
        await tx
          .delete(recipeIngredients)
          .where(eq(recipeIngredients.recipeId, recipeId))

        if (input.ingredients.length > 0) {
          const ingredientsToInsert = input.ingredients.map((ing, index) => ({
            recipeId,
            name: ing.name.trim(),
            quantity: ing.quantity ?? null,
            position: ing.position ?? index + 1,
          }))

          await tx.insert(recipeIngredients).values(ingredientsToInsert)
        }
      }

      // Replace steps (if provided)
      if (input.steps) {
        await tx.delete(recipeSteps).where(eq(recipeSteps.recipeId, recipeId))

        if (input.steps.length > 0) {
          const stepsToInsert = input.steps.map((step) => ({
            recipeId,
            stepNumber: step.stepNumber,
            description: step.description.trim(),
          }))

          await tx.insert(recipeSteps).values(stepsToInsert)
        }
      }
    })

    const full = await this.repo.findByIdWithDetails(recipeId)
    if (!full) {
      throw new Error('RECIPE_NOT_FOUND_AFTER_UPDATE')
    }

    return full
  }

  /**
   * Delete a recipe (only by its owner)
   */
  async deleteRecipeForUser(userId: number, recipeId: number): Promise<void> {
    const existing = await this.repo.findById(recipeId)
    if (!existing) {
      throw new Error('RECIPE_NOT_FOUND')
    }

    if (existing.userId !== userId) {
      throw new Error('FORBIDDEN')
    }

    await this.repo.deleteById(recipeId)
  }
}
