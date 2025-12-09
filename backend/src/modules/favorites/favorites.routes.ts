import { Router } from 'express'

import { FavoritesController } from './favorites.controller'
import { authMiddleware } from '../../middlewares/auth.middleware'

const router = Router()
const controller = new FavoritesController()

// Mark a recipe as favorite (authenticated)
// POST /recipes/:id/favorite
router.post('/recipes/:id/favorite', authMiddleware, controller.markFavorite)

// Unmark a recipe as favorite (authenticated)
// DELETE /recipes/:id/favorite
router.delete(
  '/recipes/:id/favorite',
  authMiddleware,
  controller.unmarkFavorite
)

// List all favorite recipes of the authenticated user
// GET /auth/me/favorites
router.get('/auth/me/favorites', authMiddleware, controller.listMyFavorites)

export default router
