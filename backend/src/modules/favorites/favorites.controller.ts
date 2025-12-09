import { Response } from 'express'

import { FavoritesService } from './favorites.service'

import { AuthRequest } from '../../middlewares/auth.middleware'

export class FavoritesController {
  private favoritesService: FavoritesService

  constructor(favoritesService?: FavoritesService) {
    this.favoritesService = favoritesService ?? new FavoritesService()
  }

  // POST /recipes/:id/favorite
  markFavorite = async (req: AuthRequest, res: Response) => {
    try {
      if (!req.userId) {
        return res.status(401).json({ message: 'Authentication required.' })
      }

      const recipeId = Number(req.params.id)
      if (Number.isNaN(recipeId)) {
        return res.status(400).json({ message: 'Invalid recipe ID.' })
      }

      await this.favoritesService.markAsFavorite(req.userId, recipeId)

      return res
        .status(200)
        .json({ success: true, message: 'Recipe marked as favorite.' })
    } catch (error: any) {
      console.error(error)
      if (error.message === 'RECIPE_NOT_FOUND') {
        return res.status(404).json({ message: 'Recipe not found.' })
      }
      return res
        .status(500)
        .json({ message: 'Error marking recipe as favorite.' })
    }
  }

  // DELETE /recipes/:id/favorite
  unmarkFavorite = async (req: AuthRequest, res: Response) => {
    try {
      if (!req.userId) {
        return res.status(401).json({ message: 'Authentication required.' })
      }

      const recipeId = Number(req.params.id)
      if (Number.isNaN(recipeId)) {
        return res.status(400).json({ message: 'Invalid recipe ID.' })
      }

      await this.favoritesService.unmarkFavorite(req.userId, recipeId)

      return res
        .status(200)
        .json({ success: true, message: 'Recipe unmarked as favorite.' })
    } catch (error: any) {
      console.error(error)
      return res
        .status(500)
        .json({ message: 'Error unmarking recipe as favorite.' })
    }
  }

  // GET /users/me/favorites
  listMyFavorites = async (req: AuthRequest, res: Response) => {
    try {
      if (!req.userId) {
        return res.status(401).json({ message: 'Authentication required.' })
      }

      const recipes = await this.favoritesService.getUserFavorites(req.userId)

      // Mimic GET /recipes shape: { recipes: [...] }
      return res.json({ recipes })
    } catch (error: any) {
      console.error(error)
      return res
        .status(500)
        .json({ message: 'Error retrieving favorite recipes.' })
    }
  }
}
