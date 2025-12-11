import {
  integer,
  pgTable,
  serial,
  timestamp,
  uniqueIndex,
} from 'drizzle-orm/pg-core'

import { users } from './users'
import { recipes } from './recipes'

export const favorites = pgTable(
  'favorites',
  {
    id: serial('id').primaryKey(),
    userId: integer('user_id')
      .notNull()
      .references(() => users.id, { onDelete: 'cascade' }),
    recipeId: integer('recipe_id')
      .notNull()
      .references(() => recipes.id, { onDelete: 'cascade' }),
    createdAt: timestamp('created_at').defaultNow().notNull(),
  },
  (table) => [
    uniqueIndex('favorites_user_recipe_unique').on(
      table.userId,
      table.recipeId
    ),
  ]
)
