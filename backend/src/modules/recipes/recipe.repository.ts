import { asc, desc, eq } from 'drizzle-orm'

import { db, recipeIngredients, recipes, recipeSteps } from '../../db'

import type {
  NewRecipe,
  NewRecipeIngredient,
  NewRecipeStep,
  Recipe,
  RecipeIngredient,
  RecipeStep,
} from '../../db'

export type CreateRecipeInput = {
  userId: number
  title: string
  description?: string | null
  difficulty?: 'easy' | 'medium' | 'hard'
  prepTimeMinutes?: number | null
  cookTimeMinutes?: number | null
  servings?: number | null

  ingredients?: Array<{
    name: string
    quantity?: string | null
    position?: number
  }>

  steps?: Array<{
    stepNumber: number
    description: string
  }>
}

export type UpdateRecipeInput = {
  title?: string
  description?: string | null
  difficulty?: 'easy' | 'medium' | 'hard'
  prepTimeMinutes?: number | null
  cookTimeMinutes?: number | null
  servings?: number | null

  ingredients?: Array<{
    name: string
    quantity?: string | null
    position?: number
  }>

  steps?: Array<{
    stepNumber: number
    description: string
  }>
}

export class RecipeRepository {
  async createRecipe(input: CreateRecipeInput): Promise<{
    recipe: Recipe
    ingredients: RecipeIngredient[]
    steps: RecipeStep[]
  }> {
    return db.transaction(async (tx) => {
      const now = new Date()

      // Create the object to be inserted
      const newRecipe: NewRecipe = {
        userId: input.userId,
        title: input.title.trim(),
        description: input.description?.trim() ?? null,
        difficulty: input.difficulty ?? 'easy',
        prepTimeMinutes: input.prepTimeMinutes ?? null,
        cookTimeMinutes: input.cookTimeMinutes ?? null,
        servings: input.servings ?? null,
        createdAt: now,
        updatedAt: now,
      }

      const [recipe] = await tx.insert(recipes).values(newRecipe).returning()

      if (!recipe) {
        throw new Error('RECIPE_CREATE_FAILED')
      }

      // Ingredients
      if (input.ingredients && input.ingredients.length > 0) {
        const ingredientsToInsert: NewRecipeIngredient[] =
          input.ingredients.map((ing, index) => ({
            recipeId: recipe.id,
            name: ing.name.trim(),
            quantity: ing.quantity ?? null,
            position: ing.position ?? index + 1,
          }))

        await tx.insert(recipeIngredients).values(ingredientsToInsert)
      }

      // Steps
      if (input.steps && input.steps.length > 0) {
        const stepsToInsert: NewRecipeStep[] = input.steps.map((step) => ({
          recipeId: recipe.id,
          stepNumber: step.stepNumber,
          description: step.description.trim(),
        }))

        await tx.insert(recipeSteps).values(stepsToInsert)
      }

      // Fetch inserted ingredients and steps
      const ingredients = await tx
        .select()
        .from(recipeIngredients)
        .where(eq(recipeIngredients.recipeId, recipe.id))
        .orderBy(asc(recipeIngredients.position))

      const steps = await tx
        .select()
        .from(recipeSteps)
        .where(eq(recipeSteps.recipeId, recipe.id))
        .orderBy(asc(recipeSteps.stepNumber))

      return { recipe, ingredients, steps }
    })
  }

  async findByIdWithDetails(id: number): Promise<{
    recipe: Recipe
    ingredients: RecipeIngredient[]
    steps: RecipeStep[]
  } | null> {
    const [recipe] = await db.select().from(recipes).where(eq(recipes.id, id))

    if (!recipe) return null

    const ingredients = await db
      .select()
      .from(recipeIngredients)
      .where(eq(recipeIngredients.recipeId, id))
      .orderBy(asc(recipeIngredients.position))

    const steps = await db
      .select()
      .from(recipeSteps)
      .where(eq(recipeSteps.recipeId, id))
      .orderBy(asc(recipeSteps.stepNumber))

    return { recipe, ingredients, steps }
  }

  async findAll(params?: {
    userId?: number
    limit?: number
    offset?: number
  }): Promise<Recipe[]> {
    const limit = params?.limit ?? 20
    const offset = params?.offset ?? 0

    if (params?.userId) {
      return db
        .select()
        .from(recipes)
        .where(eq(recipes.userId, params.userId))
        .orderBy(desc(recipes.createdAt))
        .limit(limit)
        .offset(offset)
    }

    return db
      .select()
      .from(recipes)
      .orderBy(desc(recipes.createdAt))
      .limit(limit)
      .offset(offset)
  }

  async deleteById(id: number): Promise<void> {
    await db.delete(recipes).where(eq(recipes.id, id))
  }

  async findById(id: number): Promise<Recipe | null> {
    const [recipe] = await db.select().from(recipes).where(eq(recipes.id, id))

    return recipe ?? null
  }
}
