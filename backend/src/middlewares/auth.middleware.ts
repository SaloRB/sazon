import type { NextFunction, Request, Response } from 'express'

import { AuthService } from '../modules/auth/auth.service'

const authService = new AuthService()

export interface AuthRequest extends Request {
  userId?: number
}

export function authMiddleware(
  req: AuthRequest,
  res: Response,
  next: NextFunction
) {
  const header = req.headers.authorization

  if (!header?.startsWith('Bearer ')) {
    return res.status(401).json({ message: 'UNAUTHORIZED' })
  }

  const token = header.substring(7)

  try {
    const { userId } = authService.verifyToken(token)
    req.userId = userId
    next()
  } catch (error) {
    return res.status(401).json({ message: 'INVALID_TOKEN' })
  }
}

export function optionalAuth(
  req: AuthRequest,
  res: Response,
  next: NextFunction
) {
  const header = req.headers.authorization

  if (!header) {
    // no auth provided, proceed without userId
    return next()
  }

  const token = header.substring(7)

  if (!token) {
    return next()
  }

  try {
    const { userId } = authService.verifyToken(token)
    req.userId = userId
  } catch (error) {
    // invalid token, proceed without userId
  }

  return next()
}
