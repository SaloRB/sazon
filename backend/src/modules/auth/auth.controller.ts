import type { Request, Response } from 'express'

import { AuthService } from './auth.service'

import { UserRepository } from '../users/user.repository'

import { AuthRequest } from '../../middlewares/auth.middleware'

const authService = new AuthService()
const userRepo = new UserRepository()

export class AuthController {
  async register(req: Request, res: Response) {
    try {
      const { name, email, password } = req.body

      if (!name || !email || !password) {
        return res
          .status(400)
          .json({ message: 'Name, email and password are required' })
      }

      const { user, token } = await authService.register(name, email, password)

      const { passwordHash, ...userData } = user

      return res.status(201).json({ user: userData, token })
    } catch (error: any) {
      if (error.message === 'EMAIL_ALREADY_IN_USER') {
        return res.status(409).json({ message: 'Email is already in use' })
      }
      console.error(error)
      return res.status(500).json({ message: 'Internal server error' })
    }
  }

  async login(req: Request, res: Response) {
    try {
      const { email, password } = req.body

      if (!email || !password) {
        return res
          .status(400)
          .json({ message: 'Email and password are required' })
      }

      const { user, token } = await authService.login(email, password)
      const { passwordHash, ...userData } = user

      return res.json({ user: userData, token })
    } catch (error: any) {
      if (error.message === 'INVALID_CREDENTIALS') {
        return res.status(401).json({ message: 'Invalid email or password' })
      }
      console.error(error)
      return res.status(500).json({ message: 'Internal server error' })
    }
  }

  async me(req: AuthRequest, res: Response) {
    try {
      if (!req.userId) {
        return res.status(401).json({ message: 'Unauthorized' })
      }

      const user = await userRepo.findById(req.userId)

      if (!user) {
        return res.status(404).json({ message: 'User not found' })
      }

      const { passwordHash, ...userData } = user
      return res.json({ user: userData })
    } catch (error) {
      console.error(error)
      return res.status(500).json({ message: 'Internal server error' })
    }
  }
}
