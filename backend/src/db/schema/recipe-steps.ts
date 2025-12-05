import { integer, pgTable, serial, text } from 'drizzle-orm/pg-core'

import { recipes } from './recipes'

export const recipeSteps = pgTable('recipe_steps', {
  id: serial('id').primaryKey(),
  recipeId: integer('recipe_id')
    .notNull()
    .references(() => recipes.id, { onDelete: 'cascade' }),
  stepNumber: integer('step_number').notNull(),
  description: text('description').notNull(),
})
