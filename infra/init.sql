-- CI/CD Pipeline Dashboard Database Schema

-- Pipelines table (templates)
CREATE TABLE IF NOT EXISTS pipelines (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  config JSONB NOT NULL, -- stages/steps metadata
  created_at TIMESTAMP DEFAULT now(),
  updated_at TIMESTAMP DEFAULT now()
);

-- Runs table (each pipeline invocation)
CREATE TABLE IF NOT EXISTS runs (
  id SERIAL PRIMARY KEY,
  pipeline_id INT REFERENCES pipelines(id) ON DELETE CASCADE,
  repo TEXT,
  branch TEXT,
  triggered_by TEXT,
  status TEXT NOT NULL DEFAULT 'queued', -- queued, running, success, failed, cancelled
  started_at TIMESTAMP,
  finished_at TIMESTAMP,
  meta JSONB DEFAULT '{}', -- e.g., commit sha, env
  created_at TIMESTAMP DEFAULT now()
);

-- Steps table (per run)
CREATE TABLE IF NOT EXISTS steps (
  id SERIAL PRIMARY KEY,
  run_id INT REFERENCES runs(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  stage TEXT NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending', -- pending, running, success, failed, cancelled
  started_at TIMESTAMP,
  finished_at TIMESTAMP,
  meta JSONB DEFAULT '{}',
  created_at TIMESTAMP DEFAULT now()
);

-- Logs table (optionally store logs)
CREATE TABLE IF NOT EXISTS logs (
  id BIGSERIAL PRIMARY KEY,
  run_id INT REFERENCES runs(id) ON DELETE CASCADE,
  step_id INT REFERENCES steps(id) ON DELETE CASCADE,
  ts TIMESTAMP DEFAULT now(),
  level TEXT NOT NULL DEFAULT 'info', -- info, warn, error, debug
  message TEXT NOT NULL,
  meta JSONB DEFAULT '{}'
);

-- Create indexes for better query performance
CREATE INDEX IF NOT EXISTS idx_runs_status ON runs(status);
CREATE INDEX IF NOT EXISTS idx_runs_pipeline_id ON runs(pipeline_id);
CREATE INDEX IF NOT EXISTS idx_runs_created_at ON runs(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_steps_run_id ON steps(run_id);
CREATE INDEX IF NOT EXISTS idx_logs_run_id ON logs(run_id);
CREATE INDEX IF NOT EXISTS idx_logs_step_id ON logs(step_id);
CREATE INDEX IF NOT EXISTS idx_logs_ts ON logs(ts);

-- Insert sample pipeline templates
INSERT INTO pipelines (name, config) VALUES
('Build and Test', '{
  "stages": [
    {
      "name": "Build",
      "steps": [
        {"name": "Checkout Code", "command": "git checkout"},
        {"name": "Install Dependencies", "command": "npm install"},
        {"name": "Build Application", "command": "npm run build"}
      ]
    },
    {
      "name": "Test",
      "steps": [
        {"name": "Run Unit Tests", "command": "npm run test:unit"},
        {"name": "Run Integration Tests", "command": "npm run test:integration"}
      ]
    },
    {
      "name": "Deploy",
      "steps": [
        {"name": "Deploy to Staging", "command": "npm run deploy:staging"},
        {"name": "Smoke Tests", "command": "npm run test:smoke"}
      ]
    }
  ]
}'),
('Quick Build', '{
  "stages": [
    {
      "name": "Build",
      "steps": [
        {"name": "Checkout Code", "command": "git checkout"},
        {"name": "Build", "command": "npm run build"}
      ]
    }
  ]
}'),
('Full CI/CD Pipeline', '{
  "stages": [
    {
      "name": "Prepare",
      "steps": [
        {"name": "Checkout", "command": "git checkout"},
        {"name": "Setup Environment", "command": "setup env"}
      ]
    },
    {
      "name": "Build",
      "steps": [
        {"name": "Install Dependencies", "command": "npm install"},
        {"name": "Compile", "command": "npm run build"},
        {"name": "Build Docker Image", "command": "docker build"}
      ]
    },
    {
      "name": "Test",
      "steps": [
        {"name": "Lint", "command": "npm run lint"},
        {"name": "Unit Tests", "command": "npm run test:unit"},
        {"name": "Integration Tests", "command": "npm run test:integration"},
        {"name": "E2E Tests", "command": "npm run test:e2e"}
      ]
    },
    {
      "name": "Security",
      "steps": [
        {"name": "Security Scan", "command": "npm audit"},
        {"name": "SAST Analysis", "command": "sast scan"}
      ]
    },
    {
      "name": "Deploy",
      "steps": [
        {"name": "Deploy to Staging", "command": "deploy staging"},
        {"name": "Health Check", "command": "health check"},
        {"name": "Deploy to Production", "command": "deploy prod"}
      ]
    }
  ]
}');
