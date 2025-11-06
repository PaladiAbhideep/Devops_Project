import db from './db';
import { redis } from './redis';
import { logger } from './logger';
import { config } from './config';

interface Step {
  id: number;
  run_id: number;
  name: string;
  stage: string;
  status: string;
  meta: any;
}

interface Run {
  id: number;
  pipeline_id: number;
  status: string;
  steps: Step[];
}

const sleep = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms));

const random = (min: number, max: number) => Math.floor(Math.random() * (max - min + 1)) + min;

const LOG_TEMPLATES = [
  'Installing dependencies...',
  'Checking environment configuration',
  'Running pre-build scripts',
  'Compiling source files',
  'Running linter',
  'Generating build artifacts',
  'Running test suite',
  'Code coverage: {coverage}%',
  'All tests passed',
  'Packaging application',
  'Uploading to artifact repository',
  'Deployment in progress',
  'Health check passed',
  'Rollout complete',
];

async function publishEvent(runId: number, event: string, data: any) {
  const channel = `run:${runId}`;
  const payload = JSON.stringify({ event, data });
  await redis.publish(channel, payload);
  logger.debug('Published event', { runId, event, channel });
}

async function simulateStep(run: Run, step: Step): Promise<boolean> {
  const { runId } = { runId: run.id };
  
  // Update step to running
  await db.query(
    'UPDATE steps SET status = $1, started_at = NOW() WHERE id = $2',
    ['running', step.id]
  );
  
  await publishEvent(runId, 'run:step:update', {
    runId,
    stepId: step.id,
    name: step.name,
    stage: step.stage,
    status: 'running',
    startedAt: new Date(),
  });
  
  // Generate logs
  const numLogs = random(config.worker.minLogLines, config.worker.maxLogLines);
  const stepDuration = random(config.worker.minStepDuration, config.worker.maxStepDuration);
  const logInterval = stepDuration / numLogs;
  
  for (let i = 0; i < numLogs; i++) {
    await sleep(logInterval + Math.random() * 200);
    
    const template = LOG_TEMPLATES[Math.floor(Math.random() * LOG_TEMPLATES.length)];
    const message = template.replace('{coverage}', String(random(75, 98)));
    const level = Math.random() < 0.1 ? 'warn' : 'info';
    const timestamp = new Date();
    
    // Store log in database (optional)
    await db.query(
      'INSERT INTO logs (run_id, step_id, ts, level, message) VALUES ($1, $2, $3, $4, $5)',
      [runId, step.id, timestamp, level, message]
    );
    
    // Publish log event
    await publishEvent(runId, 'run:log', {
      runId,
      stepId: step.id,
      ts: timestamp,
      level,
      message,
    });
  }
  
  // Determine outcome (success or failure based on configured rate)
  const failed = Math.random() < config.worker.failureRate;
  const finalStatus = failed ? 'failed' : 'success';
  
  if (failed) {
    const errorMsg = 'Step failed: Exit code 1';
    await db.query(
      'INSERT INTO logs (run_id, step_id, ts, level, message) VALUES ($1, $2, $3, $4, $5)',
      [runId, step.id, new Date(), 'error', errorMsg]
    );
    await publishEvent(runId, 'run:log', {
      runId,
      stepId: step.id,
      ts: new Date(),
      level: 'error',
      message: errorMsg,
    });
  }
  
  // Update step status
  await db.query(
    'UPDATE steps SET status = $1, finished_at = NOW() WHERE id = $2',
    [finalStatus, step.id]
  );
  
  await publishEvent(runId, 'run:step:update', {
    runId,
    stepId: step.id,
    name: step.name,
    stage: step.stage,
    status: finalStatus,
    finishedAt: new Date(),
  });
  
  return !failed;
}

async function simulateRun(runId: number) {
  logger.info('Starting run simulation', { runId });
  
  try {
    // Fetch run and steps
    const runResult = await db.query('SELECT * FROM runs WHERE id = $1', [runId]);
    
    if (runResult.rows.length === 0) {
      logger.error('Run not found', { runId });
      return;
    }
    
    const stepsResult = await db.query<Step>(
      'SELECT * FROM steps WHERE run_id = $1 ORDER BY id',
      [runId]
    );
    
    const run: Run = {
      ...runResult.rows[0],
      steps: stepsResult.rows,
    };
    
    // Update run status to running
    await db.query(
      'UPDATE runs SET status = $1, started_at = NOW() WHERE id = $2',
      ['running', runId]
    );
    
    await publishEvent(runId, 'run:status', {
      runId,
      status: 'running',
      startedAt: new Date(),
    });
    
    let allSuccess = true;
    
    // Execute steps sequentially
    for (const step of run.steps) {
      // Check if run was cancelled
      const cancelCheck = await db.query('SELECT status FROM runs WHERE id = $1', [runId]);
      if (cancelCheck.rows[0]?.status === 'cancelled') {
        logger.info('Run was cancelled', { runId });
        return;
      }
      
      const success = await simulateStep(run, step);
      
      if (!success) {
        allSuccess = false;
        // Fail remaining steps
        await db.query(
          'UPDATE steps SET status = $1 WHERE run_id = $2 AND status = $3',
          ['failed', runId, 'pending']
        );
        break;
      }
    }
    
    // Update run status
    const finalStatus = allSuccess ? 'success' : 'failed';
    await db.query(
      'UPDATE runs SET status = $1, finished_at = NOW() WHERE id = $2',
      [finalStatus, runId]
    );
    
    await publishEvent(runId, 'run:status', {
      runId,
      status: finalStatus,
      finishedAt: new Date(),
    });
    
    logger.info('Run completed', { runId, status: finalStatus });
  } catch (error: any) {
    logger.error('Error simulating run', { runId, error: error.message });
    
    // Mark run as failed
    await db.query(
      'UPDATE runs SET status = $1, finished_at = NOW() WHERE id = $2',
      ['failed', runId]
    );
    
    await publishEvent(runId, 'run:status', {
      runId,
      status: 'failed',
      finishedAt: new Date(),
      error: error.message,
    });
  }
}

export { simulateRun };
