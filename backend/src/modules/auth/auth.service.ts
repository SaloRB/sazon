import bcrypt from 'bcryptjs'
import jwt from 'jsonwebtoken'

import { UserRepository } from '../users/user.repository'

const JWT_SECRET = process.env.JWT_SECRET || 'dev_secret'
const JWT_EXPIRES_IN = '7d'

export class AuthService {
  private userRepo = new UserRepository()

  async register(name: string, email: string, password: string) {
    const existing = await this.userRepo.findByEmail(email)

    if (existing) {
      throw new Error('EMAIL_ALREADY_IN_USE')
    }

    const passwordHash = await bcrypt.hash(password, 10)
    const user = await this.userRepo.createUser({ name, email, passwordHash })

    if (!user) {
      throw new Error('USER_CREATION_FAILED')
    }

    const token = this.generateToken(user.id)

    return { user, token }
  }

  async login(email: string, password: string) {
    const user = await this.userRepo.findByEmail(email)

    if (!user) {
      throw new Error('INVALID_CREDENTIALS')
    }

    const isValid = await bcrypt.compare(password, user.passwordHash)
    if (!isValid) {
      throw new Error('INVALID_CREDENTIALS')
    }

    const token = this.generateToken(user.id)

    return { user, token }
  }

  generateToken(userId: number) {
    return jwt.sign({ sub: userId }, JWT_SECRET, { expiresIn: JWT_EXPIRES_IN })
  }

  verifyToken(token: string): { userId: number } {
    const payload = jwt.verify(token, JWT_SECRET) as unknown as { sub: number }
    return { userId: payload.sub }
  }
}
