-- CI/CD Dashboard Database Setup
-- Run this in PostgreSQL (psql)

-- Create database (if not exists)
-- Run this as postgres user:
-- CREATE DATABASE cicd_dashboard;

-- Connect to database
\c cicd_dashboard;

-- Drop existing tables (if any)
DROP TABLE IF EXISTS logs CASCADE;
DROP TABLE IF EXISTS steps CASCADE;
DROP TABLE IF EXISTS runs CASCADE;
DROP TABLE IF EXISTS pipelines CASCADE;

-- Create pipelines table
CREATE TABLE pipelines (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    repo VARCHAR(500) NOT NULL,
    branch VARCHAR(100) NOT NULL DEFAULT 'main',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create runs table
CREATE TABLE runs (
    id SERIAL PRIMARY KEY,
    pipeline_id INTEGER REFERENCES pipelines(id),
    status VARCHAR(50) NOT NULL DEFAULT 'pending',
    started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    finished_at TIMESTAMP,
    triggered_by VARCHAR(100),
    commit_sha VARCHAR(100),
    CONSTRAINT fk_pipeline FOREIGN KEY (pipeline_id) REFERENCES pipelines(id) ON DELETE CASCADE
);

-- Create steps table
CREATE TABLE steps (
    id SERIAL PRIMARY KEY,
    run_id INTEGER REFERENCES runs(id),
    name VARCHAR(255) NOT NULL,
    status VARCHAR(50) NOT NULL DEFAULT 'pending',
    started_at TIMESTAMP,
    finished_at TIMESTAMP,
    order_index INTEGER NOT NULL,
    CONSTRAINT fk_run FOREIGN KEY (run_id) REFERENCES runs(id) ON DELETE CASCADE
);

-- Create logs table
CREATE TABLE logs (
    id SERIAL PRIMARY KEY,
    run_id INTEGER REFERENCES runs(id),
    step_id INTEGER REFERENCES steps(id),
    message TEXT NOT NULL,
    level VARCHAR(20) DEFAULT 'info',
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_run_logs FOREIGN KEY (run_id) REFERENCES runs(id) ON DELETE CASCADE,
    CONSTRAINT fk_step_logs FOREIGN KEY (step_id) REFERENCES steps(id) ON DELETE CASCADE
);

-- Create indexes for better performance
CREATE INDEX idx_runs_pipeline_id ON runs(pipeline_id);
CREATE INDEX idx_runs_status ON runs(status);
CREATE INDEX idx_steps_run_id ON steps(run_id);
CREATE INDEX idx_logs_run_id ON logs(run_id);
CREATE INDEX idx_logs_step_id ON logs(step_id);
CREATE INDEX idx_logs_timestamp ON logs(timestamp);

-- Insert sample data
INSERT INTO pipelines (name, repo, branch) VALUES
('Sample Pipeline', 'https://github.com/sample/repo', 'main'),
('Frontend Build', 'https://github.com/company/frontend', 'main'),
('Backend API', 'https://github.com/company/backend', 'develop');

-- Verify tables created
\dt

-- Show sample data
SELECT * FROM pipelines;

-- Success message
\echo ''
\echo '✓ Database setup complete!'
\echo ''
\echo 'Tables created:'
\echo '  - pipelines'
\echo '  - runs'
\echo '  - steps'
\echo '  - logs'
\echo ''
\echo 'Sample pipelines inserted:'
SELECT id, name, repo FROM pipelines;
\echo ''
\echo 'You can now start the application!'
\echo ''
