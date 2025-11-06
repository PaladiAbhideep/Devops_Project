# Master Startup Script - Starts All Services
# Opens each service in a separate PowerShell window

$ErrorActionPreference = "Stop"

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  CI/CD PIPELINE DASHBOARD" -ForegroundColor Cyan
Write-Host "  WINDOWS NATIVE SETUP" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

$projectRoot = $PSScriptRoot

# Check prerequisites
Write-Host "[1/6] Checking Prerequisites...`n" -ForegroundColor Yellow

# Check Node.js
Write-Host "   Checking Node.js..." -NoNewline
try {
    $nodeVersion = node --version
    Write-Host " ✓ $nodeVersion" -ForegroundColor Green
} catch {
    Write-Host " ❌ Not found!" -ForegroundColor Red
    Write-Host "`n   Please install Node.js from: https://nodejs.org/`n" -ForegroundColor Yellow
    pause
    exit 1
}

# Check PostgreSQL
Write-Host "   Checking PostgreSQL..." -NoNewline
try {
    $pgService = Get-Service postgresql* -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($pgService) {
        if ($pgService.Status -ne "Running") {
            Write-Host " ⚠️  Found but not running" -ForegroundColor Yellow
            Write-Host "   Starting PostgreSQL..." -NoNewline
            Start-Service $pgService.Name
            Write-Host " ✓ Started" -ForegroundColor Green
        } else {
            Write-Host " ✓ Running" -ForegroundColor Green
        }
    } else {
        Write-Host " ❌ Not found!" -ForegroundColor Red
        Write-Host "`n   Please install PostgreSQL from: https://www.postgresql.org/download/windows/`n" -ForegroundColor Yellow
        Write-Host "   See SETUP-WINDOWS-NO-DOCKER.md for instructions`n" -ForegroundColor Cyan
        pause
        exit 1
    }
} catch {
    Write-Host " ⚠️  Unable to check service status" -ForegroundColor Yellow
}

# Check Redis/Memurai
Write-Host "   Checking Redis..." -NoNewline
try {
    $redisService = Get-Service Memurai -ErrorAction SilentlyContinue
    if ($redisService) {
        if ($redisService.Status -ne "Running") {
            Write-Host " ⚠️  Found but not running" -ForegroundColor Yellow
            Write-Host "   Starting Redis..." -NoNewline
            Start-Service Memurai
            Write-Host " ✓ Started" -ForegroundColor Green
        } else {
            Write-Host " ✓ Running" -ForegroundColor Green
        }
    } else {
        Write-Host " ❌ Not found!" -ForegroundColor Red
        Write-Host "`n   Please install Memurai from: https://www.memurai.com/get-memurai`n" -ForegroundColor Yellow
        Write-Host "   OR use Redis in WSL (see SETUP-WINDOWS-NO-DOCKER.md)`n" -ForegroundColor Cyan
        
        $continue = Read-Host "   Continue anyway? (Y/N)"
        if ($continue -ne "Y" -and $continue -ne "y") {
            exit 1
        }
    }
} catch {
    Write-Host " ⚠️  Unable to check service status" -ForegroundColor Yellow
}

Write-Host "`n[2/6] Checking Project Files...`n" -ForegroundColor Yellow

# Check if all directories exist
$directories = @("backend", "frontend", "worker")
foreach ($dir in $directories) {
    $path = Join-Path $projectRoot $dir
    if (Test-Path $path) {
        Write-Host "   ✓ $dir found" -ForegroundColor Green
    } else {
        Write-Host "   ❌ $dir not found!" -ForegroundColor Red
        pause
        exit 1
    }
}

Write-Host "`n[3/6] Installing Dependencies...`n" -ForegroundColor Yellow

# Install backend dependencies
Write-Host "   Installing backend dependencies..." -NoNewline
cd (Join-Path $projectRoot "backend")
if (-not (Test-Path "node_modules")) {
    Write-Host ""
    npm install --silent
    Write-Host "   ✓ Backend dependencies installed" -ForegroundColor Green
} else {
    Write-Host " ✓ Already installed" -ForegroundColor Green
}

# Install frontend dependencies
Write-Host "   Installing frontend dependencies..." -NoNewline
cd (Join-Path $projectRoot "frontend")
if (-not (Test-Path "node_modules")) {
    Write-Host ""
    npm install --silent
    Write-Host "   ✓ Frontend dependencies installed" -ForegroundColor Green
} else {
    Write-Host " ✓ Already installed" -ForegroundColor Green
}

# Install worker dependencies
Write-Host "   Installing worker dependencies..." -NoNewline
cd (Join-Path $projectRoot "worker")
if (-not (Test-Path "node_modules")) {
    Write-Host ""
    npm install --silent
    Write-Host "   ✓ Worker dependencies installed" -ForegroundColor Green
} else {
    Write-Host " ✓ Already installed" -ForegroundColor Green
}

cd $projectRoot

Write-Host "`n[4/6] Creating Environment Files...`n" -ForegroundColor Yellow

# Create backend .env
$backendEnv = Join-Path $projectRoot "backend\.env"
if (-not (Test-Path $backendEnv)) {
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
"@ | Out-File -FilePath $backendEnv -Encoding UTF8
    Write-Host "   ✓ Created backend/.env" -ForegroundColor Green
} else {
    Write-Host "   ✓ backend/.env exists" -ForegroundColor Green
}

# Create worker .env
$workerEnv = Join-Path $projectRoot "worker\.env"
if (-not (Test-Path $workerEnv)) {
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
"@ | Out-File -FilePath $workerEnv -Encoding UTF8
    Write-Host "   ✓ Created worker/.env" -ForegroundColor Green
} else {
    Write-Host "   ✓ worker/.env exists" -ForegroundColor Green
}

# Create frontend .env
$frontendEnv = Join-Path $projectRoot "frontend\.env"
if (-not (Test-Path $frontendEnv)) {
    @"
VITE_API_URL=http://localhost:4000
VITE_WS_URL=ws://localhost:4000
"@ | Out-File -FilePath $frontendEnv -Encoding UTF8
    Write-Host "   ✓ Created frontend/.env" -ForegroundColor Green
} else {
    Write-Host "   ✓ frontend/.env exists" -ForegroundColor Green
}

Write-Host "`n[5/6] Checking Database...`n" -ForegroundColor Yellow

Write-Host "   ⚠️  Make sure PostgreSQL database 'cicd_dashboard' exists" -ForegroundColor Yellow
Write-Host "   ⚠️  And tables are created (see SETUP-WINDOWS-NO-DOCKER.md)`n" -ForegroundColor Yellow

$dbReady = Read-Host "   Is database set up? (Y/N)"
if ($dbReady -ne "Y" -and $dbReady -ne "y") {
    Write-Host "`n   Please set up the database first:" -ForegroundColor Yellow
    Write-Host "   1. Open psql: psql -U postgres" -ForegroundColor White
    Write-Host "   2. Create database: CREATE DATABASE cicd_dashboard;" -ForegroundColor White
    Write-Host "   3. Run SQL from SETUP-WINDOWS-NO-DOCKER.md`n" -ForegroundColor White
    pause
    exit 1
}

Write-Host "`n[6/6] Starting Services...`n" -ForegroundColor Yellow

# Start Backend
Write-Host "   Starting Backend API..." -ForegroundColor Cyan
Start-Process powershell -ArgumentList "-NoExit", "-File", (Join-Path $projectRoot "backend\start-backend.ps1")
Start-Sleep -Seconds 2

# Start Worker
Write-Host "   Starting Worker..." -ForegroundColor Cyan
Start-Process powershell -ArgumentList "-NoExit", "-File", (Join-Path $projectRoot "worker\start-worker.ps1")
Start-Sleep -Seconds 2

# Start Frontend
Write-Host "   Starting Frontend..." -ForegroundColor Cyan
Start-Process powershell -ArgumentList "-NoExit", "-File", (Join-Path $projectRoot "frontend\start-frontend.ps1")
Start-Sleep -Seconds 3

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "  🎉 ALL SERVICES STARTED! 🎉" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Green

Write-Host "Three PowerShell windows have been opened for:" -ForegroundColor White
Write-Host "  1. Backend API  (Port 4000)" -ForegroundColor Gray
Write-Host "  2. Worker       (Background)" -ForegroundColor Gray
Write-Host "  3. Frontend     (Port 3000)`n" -ForegroundColor Gray

Write-Host "Services will be ready in ~30 seconds...`n" -ForegroundColor Yellow

# Wait for services
Write-Host "Waiting for services to start..." -ForegroundColor Gray
Start-Sleep -Seconds 15

# Check backend
Write-Host "`nChecking Backend..." -NoNewline
$backendReady = $false
for ($i = 0; $i -lt 10; $i++) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:4000/health" -TimeoutSec 2 -UseBasicParsing -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            $backendReady = $true
            Write-Host " ✓ Ready!" -ForegroundColor Green
            break
        }
    } catch {
        Start-Sleep -Seconds 2
    }
}
if (-not $backendReady) {
    Write-Host " ⚠️  Still starting..." -ForegroundColor Yellow
}

# Check frontend
Write-Host "Checking Frontend..." -NoNewline
$frontendReady = $false
for ($i = 0; $i -lt 10; $i++) {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:3000" -TimeoutSec 2 -UseBasicParsing -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            $frontendReady = $true
            Write-Host " ✓ Ready!" -ForegroundColor Green
            break
        }
    } catch {
        Start-Sleep -Seconds 2
    }
}
if (-not $frontendReady) {
    Write-Host " ⚠️  Still starting..." -ForegroundColor Yellow
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  ACCESS YOUR DASHBOARD" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "📊 Dashboard:    " -NoNewline
Write-Host "http://localhost:3000" -ForegroundColor Cyan

Write-Host "🔧 Backend API:  " -NoNewline
Write-Host "http://localhost:4000" -ForegroundColor Cyan

Write-Host "📋 API Health:   " -NoNewline
Write-Host "http://localhost:4000/health" -ForegroundColor Cyan

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  NEXT STEPS" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "1. Open Dashboard: " -NoNewline
Write-Host "http://localhost:3000" -ForegroundColor Cyan

Write-Host "2. Test API: " -NoNewline
Write-Host "http://localhost:4000/api/pipelines" -ForegroundColor Cyan

Write-Host "3. Create a pipeline run:" -ForegroundColor White
Write-Host "   curl -X POST http://localhost:4000/api/runs \`" -ForegroundColor Gray
Write-Host "     -H 'Content-Type: application/json' \`" -ForegroundColor Gray
Write-Host "     -d '{\"pipelineId\": 1, \"triggeredBy\": \"manual\"}'" -ForegroundColor Gray

Write-Host "`n4. Watch it appear in real-time in the dashboard! 🚀`n" -ForegroundColor Green

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  TO STOP ALL SERVICES" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "Close the 3 PowerShell windows, or run:" -ForegroundColor White
Write-Host "  Get-Process node | Stop-Process -Force`n" -ForegroundColor Gray

Write-Host "========================================`n" -ForegroundColor Cyan

# Offer to open browser
$openBrowser = Read-Host "Open Dashboard in browser? (Y/N)"
if ($openBrowser -eq "Y" -or $openBrowser -eq "y") {
    Start-Process "http://localhost:3000"
    Start-Sleep -Seconds 1
    Start-Process "http://localhost:4000/health"
}

Write-Host "`nPress any key to exit..." -ForegroundColor Gray
pause
