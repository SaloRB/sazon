import cors from 'cors'
import dotenv from 'dotenv'
import express from 'express'

import { db } from './db/client'
import { users } from './db/schema'
import authRoutes from './modules/auth/auth.routes'

dotenv.config()

const app = express()

// Middleware
app.use(cors())
app.use(express.json())

// Routes
app.use('/auth', authRoutes)

// Health check endpoint
app.get('/health', async (_req, res) => {
  try {
    const result = await db.select().from(users).limit(1)

    res.json({
      status: 'ok',
      message: 'Sazon backend running',
      db: 'ok',
      sampleUsersCount: result.length,
    })
  } catch (error) {
    console.error('DB healthcheck error:', error)
    res
      .status(500)
      .json({ status: 'error', message: 'Error connecting to the database' })
  }
})

// Read port from environment or default to 3000
const PORT = process.env.PORT || 3000

app.listen(PORT, () => {
  console.log(`Server is running on port ${PORT}`)
})
