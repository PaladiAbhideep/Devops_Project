import Redis from 'ioredis';
import { config } from './config';
import { logger } from './logger';

export const redis = new Redis({
  host: config.redis.host,
  port: config.redis.port,
  retryStrategy: (times: number) => {
    const delay = Math.min(times * 50, 2000);
    return delay;
  },
});

redis.on('error', (err) => {
  logger.error('Redis error', { error: err.message });
});

redis.on('connect', () => {
  logger.info('Connected to Redis');
});
