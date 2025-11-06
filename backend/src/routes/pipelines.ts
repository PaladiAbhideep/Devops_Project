import { Router, Request, Response } from 'express';
import db from '../db';
import { redis } from '../redis';
import { logger } from '../logger';

const router = Router();

interface Pipeline {
  id: number;
  name: string;
  config: any;
  created_at: Date;
  updated_at: Date;
}

// GET /api/pipelines - list all pipeline templates
router.get('/', async (req: Request, res: Response) => {
  try {
    const result = await db.query<Pipeline>(
      'SELECT * FROM pipelines ORDER BY created_at DESC'
    );
    res.json(result.rows);
  } catch (error) {
    logger.error('Error fetching pipelines', error);
    res.status(500).json({ error: 'Failed to fetch pipelines' });
  }
});

// GET /api/pipelines/:id - get pipeline by ID
router.get('/:id', async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const result = await db.query<Pipeline>(
      'SELECT * FROM pipelines WHERE id = $1',
      [id]
    );
    
    if (result.rows.length === 0) {
      return res.status(404).json({ error: 'Pipeline not found' });
    }
    
    res.json(result.rows[0]);
  } catch (error) {
    logger.error('Error fetching pipeline', error);
    res.status(500).json({ error: 'Failed to fetch pipeline' });
  }
});

// POST /api/pipelines - create new pipeline template
router.post('/', async (req: Request, res: Response) => {
  try {
    const { name, config } = req.body;
    
    if (!name || !config) {
      return res.status(400).json({ error: 'Name and config are required' });
    }
    
    const result = await db.query<Pipeline>(
      'INSERT INTO pipelines (name, config) VALUES ($1, $2) RETURNING *',
      [name, JSON.stringify(config)]
    );
    
    logger.info('Pipeline created', { pipelineId: result.rows[0].id });
    res.status(201).json(result.rows[0]);
  } catch (error) {
    logger.error('Error creating pipeline', error);
    res.status(500).json({ error: 'Failed to create pipeline' });
  }
});

// DELETE /api/pipelines/:id - delete pipeline
router.delete('/:id', async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const result = await db.query(
      'DELETE FROM pipelines WHERE id = $1 RETURNING id',
      [id]
    );
    
    if (result.rowCount === 0) {
      return res.status(404).json({ error: 'Pipeline not found' });
    }
    
    logger.info('Pipeline deleted', { pipelineId: id });
    res.json({ message: 'Pipeline deleted successfully' });
  } catch (error) {
    logger.error('Error deleting pipeline', error);
    res.status(500).json({ error: 'Failed to delete pipeline' });
  }
});

export default router;
