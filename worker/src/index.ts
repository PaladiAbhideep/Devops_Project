import { logger } from './logger';
import { redis } from './redis';
import { simulateRun } from './simulator';

async function processQueue() {
  logger.info('Worker started, waiting for jobs...');
  
  while (true) {
    try {
      // Block and wait for a job from the queue
      const result = await redis.brpop('run-queue', 0);
      
      if (!result) {
        continue;
      }
      
      const [, jobData] = result;
      const job = JSON.parse(jobData);
      
      logger.info('Received job', { job });
      
      if (job.type === 'start-run' && job.runId) {
        // Process the run asynchronously (don't block the queue)
        simulateRun(job.runId).catch((error) => {
          logger.error('Error processing run', { runId: job.runId, error });
        });
      } else {
        logger.warn('Unknown job type', { job });
      }
    } catch (error: any) {
      logger.error('Error processing queue', { error: error.message });
      // Wait a bit before retrying
      await new Promise((resolve) => setTimeout(resolve, 1000));
    }
  }
}

// Graceful shutdown
process.on('SIGTERM', () => {
  logger.info('SIGTERM received, shutting down gracefully');
  redis.quit();
  process.exit(0);
});

process.on('SIGINT', () => {
  logger.info('SIGINT received, shutting down gracefully');
  redis.quit();
  process.exit(0);
});

// Start processing
processQueue().catch((error) => {
  logger.error('Fatal error in worker', { error });
  process.exit(1);
});
