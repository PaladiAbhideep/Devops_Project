# Frontend Startup Script
# Starts the React development server

$ErrorActionPreference = "Stop"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  FRONTEND DASHBOARD" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Check if .env exists
if (-not (Test-Path ".env")) {
    Write-Host "❌ .env file not found!" -ForegroundColor Red
    Write-Host "Creating .env file...`n" -ForegroundColor Yellow
    
    @"
VITE_API_URL=http://localhost:4000
VITE_WS_URL=ws://localhost:4000
"@ | Out-File -FilePath ".env" -Encoding UTF8
    
    Write-Host "✓ Created .env file`n" -ForegroundColor Green
}

# Check if node_modules exists
if (-not (Test-Path "node_modules")) {
    Write-Host "📦 Installing dependencies..." -ForegroundColor Yellow
    npm install
    Write-Host "✓ Dependencies installed`n" -ForegroundColor Green
}

# Start development server
Write-Host "🚀 Starting Frontend Dashboard..." -ForegroundColor Green
Write-Host "   Port: 3000" -ForegroundColor Gray
Write-Host "   Dashboard: http://localhost:3000`n" -ForegroundColor Cyan
Write-Host "Press Ctrl+C to stop`n" -ForegroundColor Yellow
Write-Host "========================================`n" -ForegroundColor Cyan

npm run dev
