import Redis from 'ioredis';
import { config } from './config';
import { logger } from './logger';

export const redis = new Redis({
  host: config.redis.host,
  port: config.redis.port,
  retryStrategy: (times) => {
    const delay = Math.min(times * 50, 2000);
    return delay;
  },
});

export const redisSub = new Redis({
  host: config.redis.host,
  port: config.redis.port,
});

redis.on('error', (err) => {
  logger.error('Redis error', err);
});

redis.on('connect', () => {
  logger.info('Redis connected');
});

redisSub.on('error', (err) => {
  logger.error('Redis subscriber error', err);
});

redisSub.on('connect', () => {
  logger.info('Redis subscriber connected');
});
