import { Pool } from 'pg'
import { drizzle } from 'drizzle-orm/node-postgres'
import dotenv from 'dotenv'

dotenv.config()

const connectionString = process.env.DATABASE_URL

if (!connectionString) {
  throw new Error('DATABASE_URL is not defined in environment variables')
}

const pool = new Pool({ connectionString })

export const db = drizzle(pool)

export { pool }
