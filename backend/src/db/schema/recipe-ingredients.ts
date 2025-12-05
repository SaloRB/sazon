import { integer, pgTable, serial, text } from 'drizzle-orm/pg-core'

import { recipes } from './recipes'

export const recipeIngredients = pgTable('recipe_ingredients', {
  id: serial('id').primaryKey(),
  recipeId: integer('recipe_id')
    .notNull()
    .references(() => recipes.id, { onDelete: 'cascade' }),
  name: text('name').notNull(),
  quantity: text('quantity'),
  position: integer('position').notNull().default(1),
})
