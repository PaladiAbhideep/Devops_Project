import express from 'express';
import http from 'http';
import cors from 'cors';
import { Server } from 'socket.io';
import { config } from './config';
import { logger } from './logger';
import { redis, redisSub } from './redis';
import pipelinesRouter from './routes/pipelines';
import runsRouter from './routes/runs';
import jenkinsRouter from './routes/jenkins';

const app = express();
const server = http.createServer(app);

// Socket.IO setup
const io = new Server(server, {
  path: '/ws',
  cors: {
    origin: '*',
    methods: ['GET', 'POST'],
  },
});

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// Request logging
app.use((req, res, next) => {
  logger.info(`${req.method} ${req.path}`);
  next();
});

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'ok', timestamp: new Date().toISOString() });
});

// API routes
app.use('/api/pipelines', pipelinesRouter);
app.use('/api/runs', runsRouter);
app.use('/api/jenkins', jenkinsRouter);

// Error handling
app.use((err: any, req: express.Request, res: express.Response, next: express.NextFunction) => {
  logger.error('Unhandled error', err);
  res.status(500).json({ error: 'Internal server error' });
});

// Redis pub/sub to Socket.IO forwarding
redisSub.psubscribe('run:*');

redisSub.on('pmessage', (pattern, channel, message) => {
  try {
    const payload = JSON.parse(message);
    const runId = channel.split(':')[1];
    
    logger.debug('Forwarding event to clients', {
      channel,
      event: payload.event,
      runId,
    });
    
    // Emit to all clients subscribed to this run
    io.to(`run-${runId}`).emit(payload.event, payload.data);
  } catch (error) {
    logger.error('Error processing Redis message', { channel, error });
  }
});

// Socket.IO connection handling
io.on('connection', (socket) => {
  logger.info('Client connected', { socketId: socket.id });
  
  socket.on('subscribe', ({ runId }: { runId: number }) => {
    const room = `run-${runId}`;
    socket.join(room);
    logger.info('Client subscribed to run', { socketId: socket.id, runId, room });
  });
  
  socket.on('unsubscribe', ({ runId }: { runId: number }) => {
    const room = `run-${runId}`;
    socket.leave(room);
    logger.info('Client unsubscribed from run', { socketId: socket.id, runId, room });
  });
  
  socket.on('disconnect', () => {
    logger.info('Client disconnected', { socketId: socket.id });
  });
});

// Start server
server.listen(config.port, () => {
  logger.info(`Server running on port ${config.port}`);
  logger.info(`Environment: ${config.nodeEnv}`);
  logger.info(`WebSocket path: /ws`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  logger.info('SIGTERM received, shutting down gracefully');
  server.close(() => {
    logger.info('Server closed');
    redis.quit();
    redisSub.quit();
    process.exit(0);
  });
});

process.on('SIGINT', () => {
  logger.info('SIGINT received, shutting down gracefully');
  server.close(() => {
    logger.info('Server closed');
    redis.quit();
    redisSub.quit();
    process.exit(0);
  });
});
