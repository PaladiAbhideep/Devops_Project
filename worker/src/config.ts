import dotenv from 'dotenv';

dotenv.config();

export const config = {
  nodeEnv: process.env.NODE_ENV || 'development',
  db: {
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT || '5432', 10),
    user: process.env.DB_USER || 'postgres',
    password: process.env.DB_PASSWORD || 'postgres',
    database: process.env.DB_NAME || 'cicd_dashboard',
  },
  redis: {
    host: process.env.REDIS_HOST || 'localhost',
    port: parseInt(process.env.REDIS_PORT || '6379', 10),
  },
  worker: {
    failureRate: parseFloat(process.env.FAILURE_RATE || '0.1'),
    minLogLines: parseInt(process.env.MIN_LOG_LINES || '5', 10),
    maxLogLines: parseInt(process.env.MAX_LOG_LINES || '15', 10),
    minStepDuration: parseInt(process.env.MIN_STEP_DURATION || '2000', 10),
    maxStepDuration: parseInt(process.env.MAX_STEP_DURATION || '8000', 10),
  },
};
