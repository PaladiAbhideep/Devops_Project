import axios from 'axios';
import { config } from './config';
import { Pipeline, Run } from './types';

const api = axios.create({
  baseURL: config.apiUrl,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Pipelines
export const fetchPipelines = async (): Promise<Pipeline[]> => {
  const { data } = await api.get('/api/pipelines');
  return data;
};

export const fetchPipeline = async (id: number): Promise<Pipeline> => {
  const { data } = await api.get(`/api/pipelines/${id}`);
  return data;
};

export const createPipeline = async (pipeline: Partial<Pipeline>): Promise<Pipeline> => {
  const { data } = await api.post('/api/pipelines', pipeline);
  return data;
};

// Runs
export const fetchRuns = async (params?: {
  status?: string;
  repo?: string;
  branch?: string;
  limit?: number;
  offset?: number;
}): Promise<Run[]> => {
  const { data } = await api.get('/api/runs', { params });
  return data;
};

export const fetchRun = async (id: number): Promise<Run> => {
  const { data } = await api.get(`/api/runs/${id}`);
  return data;
};

export const createRun = async (run: {
  pipelineId: number;
  repo?: string;
  branch?: string;
  triggeredBy?: string;
  params?: Record<string, any>;
}): Promise<Run> => {
  const { data } = await api.post('/api/runs', run);
  return data;
};

export const cancelRun = async (id: number): Promise<Run> => {
  const { data } = await api.post(`/api/runs/${id}/cancel`);
  return data;
};

export const rerunPipeline = async (id: number): Promise<Run> => {
  const { data } = await api.post(`/api/runs/${id}/rerun`);
  return data;
};
