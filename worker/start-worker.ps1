# Worker Startup Script
# Starts the pipeline execution worker

$ErrorActionPreference = "Stop"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  PIPELINE WORKER" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Check if .env exists
if (-not (Test-Path ".env")) {
    Write-Host "❌ .env file not found!" -ForegroundColor Red
    Write-Host "Creating .env file...`n" -ForegroundColor Yellow
    
    @"
# Database
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=postgres123
DB_NAME=cicd_dashboard

# Redis
REDIS_HOST=localhost
REDIS_PORT=6379

NODE_ENV=development
"@ | Out-File -FilePath ".env" -Encoding UTF8
    
    Write-Host "✓ Created .env file" -ForegroundColor Green
    Write-Host "⚠️  Please update DB_PASSWORD in .env if needed`n" -ForegroundColor Yellow
}

# Check if node_modules exists
if (-not (Test-Path "node_modules")) {
    Write-Host "📦 Installing dependencies..." -ForegroundColor Yellow
    npm install
    Write-Host "✓ Dependencies installed`n" -ForegroundColor Green
}

# Start worker
Write-Host "🚀 Starting Pipeline Worker..." -ForegroundColor Green
Write-Host "   Listening for pipeline runs" -ForegroundColor Gray
Write-Host "   Connected to Redis pub/sub`n" -ForegroundColor Gray
Write-Host "Press Ctrl+C to stop`n" -ForegroundColor Yellow
Write-Host "========================================`n" -ForegroundColor Cyan

npm run dev
