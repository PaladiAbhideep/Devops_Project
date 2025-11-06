import { Router, Request, Response } from 'express';
import db from '../db';
import { redis } from '../redis';
import { logger } from '../logger';

const router = Router();

interface Run {
  id: number;
  pipeline_id: number;
  repo: string;
  branch: string;
  triggered_by: string;
  status: string;
  started_at: Date | null;
  finished_at: Date | null;
  meta: any;
  created_at: Date;
}

interface Step {
  id: number;
  run_id: number;
  name: string;
  stage: string;
  status: string;
  started_at: Date | null;
  finished_at: Date | null;
  meta: any;
}

// GET /api/runs - list runs with optional filters
router.get('/', async (req: Request, res: Response) => {
  try {
    const { status, repo, branch, limit = '50', offset = '0' } = req.query;
    
    let query = `
      SELECT r.*, p.name as pipeline_name 
      FROM runs r 
      JOIN pipelines p ON r.pipeline_id = p.id 
      WHERE 1=1
    `;
    const params: any[] = [];
    let paramIndex = 1;
    
    if (status) {
      query += ` AND r.status = $${paramIndex++}`;
      params.push(status);
    }
    
    if (repo) {
      query += ` AND r.repo = $${paramIndex++}`;
      params.push(repo);
    }
    
    if (branch) {
      query += ` AND r.branch = $${paramIndex++}`;
      params.push(branch);
    }
    
    query += ` ORDER BY r.created_at DESC LIMIT $${paramIndex++} OFFSET $${paramIndex}`;
    params.push(limit, offset);
    
    const result = await db.query(query, params);
    res.json(result.rows);
  } catch (error) {
    logger.error('Error fetching runs', error);
    res.status(500).json({ error: 'Failed to fetch runs' });
  }
});

// GET /api/runs/:id - get run details with steps
router.get('/:id', async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    
    const runResult = await db.query<Run>(
      `SELECT r.*, p.name as pipeline_name, p.config as pipeline_config
       FROM runs r 
       JOIN pipelines p ON r.pipeline_id = p.id 
       WHERE r.id = $1`,
      [id]
    );
    
    if (runResult.rows.length === 0) {
      return res.status(404).json({ error: 'Run not found' });
    }
    
    const stepsResult = await db.query<Step>(
      'SELECT * FROM steps WHERE run_id = $1 ORDER BY id',
      [id]
    );
    
    const run = {
      ...runResult.rows[0],
      steps: stepsResult.rows,
    };
    
    res.json(run);
  } catch (error) {
    logger.error('Error fetching run details', error);
    res.status(500).json({ error: 'Failed to fetch run details' });
  }
});

// POST /api/runs - create and start a new run
router.post('/', async (req: Request, res: Response) => {
  try {
    const { pipelineId, repo, branch, triggeredBy, params: runParams } = req.body;
    
    if (!pipelineId) {
      return res.status(400).json({ error: 'pipelineId is required' });
    }
    
    // Fetch pipeline config
    const pipelineResult = await db.query(
      'SELECT * FROM pipelines WHERE id = $1',
      [pipelineId]
    );
    
    if (pipelineResult.rows.length === 0) {
      return res.status(404).json({ error: 'Pipeline not found' });
    }
    
    const pipeline = pipelineResult.rows[0];
    
    // Create run
    const runResult = await db.query<Run>(
      `INSERT INTO runs (pipeline_id, repo, branch, triggered_by, status, meta) 
       VALUES ($1, $2, $3, $4, 'queued', $5) 
       RETURNING *`,
      [pipelineId, repo, branch, triggeredBy, JSON.stringify(runParams || {})]
    );
    
    const run = runResult.rows[0];
    
    // Create steps based on pipeline config
    const stages = pipeline.config.stages || [];
    for (const stage of stages) {
      for (const step of stage.steps) {
        await db.query(
          `INSERT INTO steps (run_id, name, stage, status, meta) 
           VALUES ($1, $2, $3, 'pending', $4)`,
          [run.id, step.name, stage.name, JSON.stringify(step)]
        );
      }
    }
    
    // Enqueue job for worker
    const job = {
      type: 'start-run',
      runId: run.id,
      pipelineId,
      timestamp: new Date().toISOString(),
    };
    
    await redis.lpush('run-queue', JSON.stringify(job));
    
    logger.info('Run created and enqueued', { runId: run.id, pipelineId });
    res.status(201).json(run);
  } catch (error) {
    logger.error('Error creating run', error);
    res.status(500).json({ error: 'Failed to create run' });
  }
});

// POST /api/runs/:id/cancel - cancel a running pipeline
router.post('/:id/cancel', async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    
    const result = await db.query<Run>(
      `UPDATE runs 
       SET status = 'cancelled', finished_at = NOW() 
       WHERE id = $1 AND status IN ('queued', 'running') 
       RETURNING *`,
      [id]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Run not found or already completed' });
    }
    
    // Update all pending/running steps to cancelled
    await db.query(
      `UPDATE steps 
       SET status = 'cancelled', finished_at = NOW() 
       WHERE run_id = $1 AND status IN ('pending', 'running')`,
      [id]
    );
    
    // Publish cancel event
    await redis.publish(
      `run:${id}`,
      JSON.stringify({
        event: 'run:cancelled',
        data: { runId: id, timestamp: new Date() },
      })
    );
    
    logger.info('Run cancelled', { runId: id });
    res.json(result.rows[0]);
  } catch (error) {
    logger.error('Error cancelling run', error);
    res.status(500).json({ error: 'Failed to cancel run' });
  }
});

// POST /api/runs/:id/rerun - rerun a pipeline with same parameters
router.post('/:id/rerun', async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    
    const runResult = await db.query<Run>(
      'SELECT * FROM runs WHERE id = $1',
      [id]
    );
    
    if (runResult.rows.length === 0) {
      return res.status(404).json({ error: 'Run not found' });
    }
    
    const originalRun = runResult.rows[0];
    
    // Create new run with same parameters
    const newRunResult = await db.query<Run>(
      `INSERT INTO runs (pipeline_id, repo, branch, triggered_by, status, meta) 
       VALUES ($1, $2, $3, $4, 'queued', $5) 
       RETURNING *`,
      [
        originalRun.pipeline_id,
        originalRun.repo,
        originalRun.branch,
        originalRun.triggered_by,
        originalRun.meta,
      ]
    );
    
    const newRun = newRunResult.rows[0];
    
    // Copy steps from original run
    await db.query(
      `INSERT INTO steps (run_id, name, stage, status, meta)
       SELECT $1, name, stage, 'pending', meta FROM steps WHERE run_id = $2`,
      [newRun.id, id]
    );
    
    // Enqueue job
    await redis.lpush(
      'run-queue',
      JSON.stringify({ type: 'start-run', runId: newRun.id })
    );
    
    logger.info('Run restarted', { originalRunId: id, newRunId: newRun.id });
    res.status(201).json(newRun);
  } catch (error) {
    logger.error('Error rerunning pipeline', error);
    res.status(500).json({ error: 'Failed to rerun pipeline' });
  }
});

export default router;
