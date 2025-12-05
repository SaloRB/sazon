import { Request, Response } from 'express'

import { RecipeService } from './recipe.service'

import { AuthRequest } from '../../middlewares/auth.middleware'
import { parseNumber } from '../../utils'
import { UpdateRecipeInput } from './recipe.repository'

export class RecipeController {
  private service: RecipeService

  constructor(service?: RecipeService) {
    this.service = service ?? new RecipeService()
  }

  // GET /recipes?mine=true&limit=20&offset=0
  list = async (req: Request, res: Response) => {
    try {
      const mine = req.query.mine === 'true'
      const limit = parseNumber(req.query.limit)
      const offset = parseNumber(req.query.offset)

      // optional userId: if auth we use it
      const authReq = req as AuthRequest
      const userId = authReq.userId

      const recipes = await this.service.listRecipes({
        userId,
        mine,
        limit,
        offset,
      })

      return res.json({ recipes })
    } catch (error: any) {
      if (error.message === 'USER_ID_REQUIRED_FOR_MINE') {
        return res
          .status(400)
          .json({ message: 'User ID is required to list your own recipes.' })
      }
      return res.status(500).json({ message: 'Error listing recipes.' })
    }
  }

  // GET /recipes/:id
  getOne = async (req: Request, res: Response) => {
    try {
      const id = Number(req.params.id)
      if (Number.isNaN(id)) {
        return res.status(400).json({ message: 'Invalid recipe ID.' })
      }

      const data = await this.service.getRecipeWithDetails(id)
      return res.json(data)
    } catch (error: any) {
      console.error(error)
      if (error.message === 'RECIPE_NOT_FOUND') {
        return res.status(404).json({ message: 'Recipe not found.' })
      }
      return res.status(500).json({ message: 'Error retrieving recipe.' })
    }
  }

  // POST /recipes
  create = async (req: AuthRequest, res: Response) => {
    try {
      if (!req.userId) {
        return res.status(401).json({ message: 'Authentication required.' })
      }

      const {
        title,
        description,
        difficulty,
        prepTimeMinutes,
        cookTimeMinutes,
        servings,
        ingredients,
        steps,
      } = req.body

      const result = await this.service.createRecipeForUser(req.userId, {
        title,
        description,
        difficulty,
        prepTimeMinutes,
        cookTimeMinutes,
        servings,
        ingredients,
        steps,
      })

      return res.status(201).json(result)
    } catch (error: any) {
      console.error(error)
      if (error.message === 'TITLE_REQUIRED') {
        return res.status(400).json({ message: 'Title is required.' })
      }
      return res.status(500).json({ message: 'Error creating recipe.' })
    }
  }

  // PUT /recipes/:id
  update = async (req: AuthRequest, res: Response) => {
    try {
      if (!req.userId) {
        return res.status(401).json({ message: 'Authentication required.' })
      }

      const id = Number(req.params.id)
      if (Number.isNaN(id)) {
        return res.status(400).json({ message: 'Invalid recipe ID.' })
      }

      const input: UpdateRecipeInput = {
        title: req.body.title,
        description: req.body.description,
        difficulty: req.body.difficulty,
        prepTimeMinutes: req.body.prepTimeMinutes,
        cookTimeMinutes: req.body.cookTimeMinutes,
        servings: req.body.servings,
        ingredients: req.body.ingredients,
        steps: req.body.steps,
      }

      const result = await this.service.updateRecipeForUser(
        req.userId,
        id,
        input
      )
      return res.json(result)
    } catch (error: any) {
      console.error(error)
      if (error.message === 'RECIPE_NOT_FOUND') {
        return res.status(404).json({ message: 'Recipe not found.' })
      }
      if (error.message === 'FORBIDDEN') {
        return res.status(403).json({
          message: 'You do not have permission to update this recipe.',
        })
      }
      return res.status(500).json({ message: 'Error updating recipe.' })
    }
  }

  // DELETE /recipes/:id
  remove = async (req: AuthRequest, res: Response) => {
    try {
      if (!req.userId) {
        return res.status(401).json({ message: 'Authentication required.' })
      }

      const id = Number(req.params.id)
      if (Number.isNaN(id)) {
        return res.status(400).json({ message: 'Invalid recipe ID.' })
      }

      await this.service.deleteRecipeForUser(req.userId, id)
      return res.status(204).send()
    } catch (error: any) {
      console.error(error)
      if (error.message === 'RECIPE_NOT_FOUND') {
        return res.status(404).json({ message: 'Recipe not found.' })
      }
      if (error.message === 'FORBIDDEN') {
        return res.status(403).json({
          message: 'You do not have permission to delete this recipe.',
        })
      }
      return res.status(500).json({ message: 'Error deleting recipe.' })
    }
  }
}
