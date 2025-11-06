import { Router, Request, Response } from 'express';
import db from '../db';
import { redis } from '../redis';
import { logger } from '../logger';

const router = Router();

// POST /api/jenkins/runs/:runId/status - Update run status from Jenkins
router.post('/runs/:runId/status', async (req: Request, res: Response) => {
  try {
    const { runId } = req.params;
    const { status, timestamp, jenkinsUrl } = req.body;
    
    logger.info('Jenkins run status update', { runId, status });
    
    // Update run status
    const result = await db.query(
      `UPDATE runs 
       SET status = $1, 
           finished_at = CASE WHEN $1 IN ('success', 'failed', 'cancelled') THEN NOW() ELSE finished_at END,
           meta = jsonb_set(COALESCE(meta, '{}'), '{jenkinsUrl}', $2)
       WHERE id = $3 
       RETURNING *`,
      [status, JSON.stringify(jenkinsUrl), runId]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Run not found' });
    }
    
    // Publish status update
    await redis.publish(
      `run:${runId}`,
      JSON.stringify({
        event: 'run:status',
        data: {
          runId: parseInt(runId),
          status,
          finishedAt: timestamp,
          jenkinsUrl,
        },
      })
    );
    
    res.json({ success: true, run: result.rows[0] });
  } catch (error) {
    logger.error('Error updating Jenkins run status', error);
    res.status(500).json({ error: 'Failed to update run status' });
  }
});

// POST /api/jenkins/steps - Update step status from Jenkins
router.post('/steps', async (req: Request, res: Response) => {
  try {
    const { runId, stepName, status, timestamp, stage } = req.body;
    
    logger.info('Jenkins step update', { runId, stepName, status });
    
    // Find or create step
    let stepResult = await db.query(
      'SELECT * FROM steps WHERE run_id = $1 AND name = $2',
      [runId, stepName]
    );
    
    let step;
    if (stepResult.rows.length === 0) {
      // Create new step
      stepResult = await db.query(
        `INSERT INTO steps (run_id, name, stage, status, started_at, meta) 
         VALUES ($1, $2, $3, $4, NOW(), '{}') 
         RETURNING *`,
        [runId, stepName, stage || 'Jenkins', status]
      );
      step = stepResult.rows[0];
    } else {
      // Update existing step
      stepResult = await db.query(
        `UPDATE steps 
         SET status = $1, 
             started_at = CASE WHEN started_at IS NULL THEN NOW() ELSE started_at END,
             finished_at = CASE WHEN $1 IN ('success', 'failed', 'cancelled') THEN NOW() ELSE finished_at END
         WHERE id = $2 
         RETURNING *`,
        [status, stepResult.rows[0].id]
      );
      step = stepResult.rows[0];
    }
    
    // Publish step update
    await redis.publish(
      `run:${runId}`,
      JSON.stringify({
        event: 'run:step:update',
        data: {
          runId: parseInt(runId),
          stepId: step.id,
          name: stepName,
          stage: step.stage,
          status,
          startedAt: step.started_at,
          finishedAt: step.finished_at,
        },
      })
    );
    
    res.json({ success: true, step });
  } catch (error) {
    logger.error('Error updating Jenkins step', error);
    res.status(500).json({ error: 'Failed to update step' });
  }
});

// POST /api/jenkins/logs - Receive logs from Jenkins
router.post('/logs', async (req: Request, res: Response) => {
  try {
    const { runId, stepName, level, message, timestamp } = req.body;
    
    // Find step
    const stepResult = await db.query(
      'SELECT id FROM steps WHERE run_id = $1 AND name = $2',
      [runId, stepName]
    );
    
    const stepId = stepResult.rows.length > 0 ? stepResult.rows[0].id : null;
    
    // Insert log
    await db.query(
      'INSERT INTO logs (run_id, step_id, ts, level, message) VALUES ($1, $2, $3, $4, $5)',
      [runId, stepId, timestamp || new Date(), level || 'info', message]
    );
    
    // Publish log event
    await redis.publish(
      `run:${runId}`,
      JSON.stringify({
        event: 'run:log',
        data: {
          runId: parseInt(runId),
          stepId,
          ts: timestamp || new Date(),
          level: level || 'info',
          message,
        },
      })
    );
    
    res.json({ success: true });
  } catch (error) {
    logger.error('Error storing Jenkins log', error);
    res.status(500).json({ error: 'Failed to store log' });
  }
});

// POST /api/jenkins/webhook - GitHub webhook receiver
router.post('/webhook', async (req: Request, res: Response) => {
  try {
    const event = req.headers['x-github-event'];
    const payload = req.body;
    
    logger.info('GitHub webhook received', { event });
    
    if (event === 'push') {
      const { repository, ref, pusher } = payload;
      const branch = ref?.replace('refs/heads/', '') || 'main';
      
      logger.info('Push event detected', {
        repo: repository?.full_name,
        branch,
        pusher: pusher?.name,
      });
      
      // Create a pipeline run
      const runResult = await db.query(
        `INSERT INTO runs (pipeline_id, repo, branch, triggered_by, status, meta) 
         VALUES (1, $1, $2, $3, 'queued', $4) 
         RETURNING *`,
        [
          repository?.full_name || 'unknown',
          branch,
          `github:${pusher?.name || 'unknown'}`,
          JSON.stringify({
            commit: payload.head_commit?.id,
            message: payload.head_commit?.message,
            url: payload.head_commit?.url,
          }),
        ]
      );
      
      const run = runResult.rows[0];
      
      // Create steps (will be updated by Jenkins)
      const stages = [
        { name: 'Initialize', stage: 'Setup' },
        { name: 'Checkout', stage: 'Build' },
        { name: 'Install Dependencies', stage: 'Build' },
        { name: 'Build', stage: 'Build' },
        { name: 'Test', stage: 'Test' },
        { name: 'Lint', stage: 'Test' },
        { name: 'Security Scan', stage: 'Security' },
        { name: 'Package', stage: 'Package' },
        { name: 'Deploy', stage: 'Deploy' },
      ];
      
      for (const step of stages) {
        await db.query(
          `INSERT INTO steps (run_id, name, stage, status, meta) 
           VALUES ($1, $2, $3, 'pending', '{}')`,
          [run.id, step.name, step.stage]
        );
      }
      
      logger.info('Pipeline run created from webhook', { runId: run.id });
      
      res.json({
        success: true,
        message: 'Pipeline run created',
        runId: run.id,
      });
    } else {
      res.json({ success: true, message: 'Event acknowledged but not processed' });
    }
  } catch (error) {
    logger.error('Error processing GitHub webhook', error);
    res.status(500).json({ error: 'Failed to process webhook' });
  }
});

// GET /api/jenkins/health - Jenkins health check
router.get('/health', async (req: Request, res: Response) => {
  res.json({
    status: 'ok',
    service: 'jenkins-integration',
    timestamp: new Date().toISOString(),
  });
});

export default router;
