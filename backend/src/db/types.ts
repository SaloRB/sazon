import { recipeIngredients, recipes, recipeSteps, users } from './schema'

// ----- USERS -----
export type User = typeof users.$inferSelect
export type NewUser = typeof users.$inferInsert

// ----- RECIPES -----
export type Recipe = typeof recipes.$inferSelect
export type NewRecipe = typeof recipes.$inferInsert

// ----- RECIPE INGREDIENTS -----
export type RecipeIngredient = typeof recipeIngredients.$inferSelect
export type NewRecipeIngredient = typeof recipeIngredients.$inferInsert

// ----- RECIPE STEPS -----
export type RecipeStep = typeof recipeSteps.$inferSelect
export type NewRecipeStep = typeof recipeSteps.$inferInsert
