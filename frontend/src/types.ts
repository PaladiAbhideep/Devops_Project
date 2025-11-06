export interface Pipeline {
  id: number;
  name: string;
  config: PipelineConfig;
  created_at: string;
  updated_at?: string;
}

export interface PipelineConfig {
  stages: Stage[];
}

export interface Stage {
  name: string;
  steps: StepConfig[];
}

export interface StepConfig {
  name: string;
  command: string;
}

export interface Run {
  id: number;
  pipeline_id: number;
  pipeline_name?: string;
  pipeline_config?: PipelineConfig;
  repo: string;
  branch: string;
  triggered_by: string;
  status: RunStatus;
  started_at: string | null;
  finished_at: string | null;
  meta: Record<string, any>;
  created_at: string;
  steps?: Step[];
}

export interface Step {
  id: number;
  run_id: number;
  name: string;
  stage: string;
  status: StepStatus;
  started_at: string | null;
  finished_at: string | null;
  meta: Record<string, any>;
  created_at?: string;
}

export interface Log {
  runId: number;
  stepId: number;
  ts: string;
  level: LogLevel;
  message: string;
}

export type RunStatus = 'queued' | 'running' | 'success' | 'failed' | 'cancelled';
export type StepStatus = 'pending' | 'running' | 'success' | 'failed' | 'cancelled';
export type LogLevel = 'info' | 'warn' | 'error' | 'debug';
