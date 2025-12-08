import { Router } from 'express'

import { RecipeController } from './recipe.controller'

import { authMiddleware, optionalAuth } from '../../middlewares/auth.middleware'

const router = Router()
const controller = new RecipeController()

// List all recipes (public, but supports ?mine=true for user-specific recipes)
router.get('/', optionalAuth, controller.list)

// Recipe details by ID (public)
router.get('/:id', controller.getOne)

// Create a new recipe (authenticated)
router.post('/', authMiddleware, controller.create)

// Update an existing recipe by ID (authenticated)
router.put('/:id', authMiddleware, controller.update)

// Delete a recipe by ID (authenticated)
router.delete('/:id', authMiddleware, controller.remove)

export default router
