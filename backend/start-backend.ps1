# Backend Startup Script
# Starts the Express API server with Socket.IO

$ErrorActionPreference = "Stop"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  BACKEND API SERVER" -ForegroundColor Cyan
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

# Server
PORT=4000
NODE_ENV=development

# CORS
CORS_ORIGIN=http://localhost:3000
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

# Start server
Write-Host "🚀 Starting Backend API Server..." -ForegroundColor Green
Write-Host "   Port: 4000" -ForegroundColor Gray
Write-Host "   API: http://localhost:4000" -ForegroundColor Cyan
Write-Host "   Health: http://localhost:4000/health`n" -ForegroundColor Cyan
Write-Host "Press Ctrl+C to stop`n" -ForegroundColor Yellow
Write-Host "========================================`n" -ForegroundColor Cyan

npm run dev
