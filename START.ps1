# CI/CD Pipeline Dashboard - Startup Script
# Run this after starting Docker Desktop

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  CI/CD PIPELINE DASHBOARD - STARTUP" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Step 1: Check Docker
Write-Host "[1/5] Checking Docker Desktop..." -ForegroundColor Yellow
$dockerRunning = $false
$maxAttempts = 10
$attempt = 0

while (-not $dockerRunning -and $attempt -lt $maxAttempts) {
    $attempt++
    try {
        docker ps > $null 2>&1
        if ($LASTEXITCODE -eq 0) {
            $dockerRunning = $true
            Write-Host "      ✓ Docker Desktop is running!" -ForegroundColor Green
        } else {
            Write-Host "      ⏳ Waiting for Docker Desktop... (Attempt $attempt/$maxAttempts)" -ForegroundColor Gray
            Start-Sleep -Seconds 3
        }
    } catch {
        Write-Host "      ⏳ Waiting for Docker Desktop... (Attempt $attempt/$maxAttempts)" -ForegroundColor Gray
        Start-Sleep -Seconds 3
    }
}

if (-not $dockerRunning) {
    Write-Host "`n      ❌ Docker Desktop is not running!" -ForegroundColor Red
    Write-Host "`n      Please start Docker Desktop and run this script again." -ForegroundColor Yellow
    Write-Host "      1. Press Windows Key" -ForegroundColor White
    Write-Host "      2. Type 'Docker Desktop'" -ForegroundColor White
    Write-Host "      3. Click Docker Desktop" -ForegroundColor White
    Write-Host "      4. Wait for Docker icon to appear in system tray" -ForegroundColor White
    Write-Host "      5. Run this script again`n" -ForegroundColor White
    pause
    exit 1
}

# Step 2: Stop existing containers
Write-Host "`n[2/5] Cleaning up existing containers..." -ForegroundColor Yellow
docker-compose down > $null 2>&1
Write-Host "      ✓ Cleanup complete!" -ForegroundColor Green

# Step 3: Pull images
Write-Host "`n[3/5] Downloading Docker images (this may take 5-10 minutes)..." -ForegroundColor Yellow
Write-Host "      📦 Downloading PostgreSQL..." -ForegroundColor Gray
docker-compose pull db
Write-Host "      📦 Downloading Redis..." -ForegroundColor Gray
docker-compose pull redis
Write-Host "      📦 Downloading Jenkins..." -ForegroundColor Gray
docker-compose pull jenkins
Write-Host "      ✓ All images downloaded!" -ForegroundColor Green

# Step 4: Build custom images
Write-Host "`n[4/5] Building application containers..." -ForegroundColor Yellow
docker-compose build --no-cache
if ($LASTEXITCODE -eq 0) {
    Write-Host "      ✓ Build successful!" -ForegroundColor Green
} else {
    Write-Host "      ❌ Build failed!" -ForegroundColor Red
    pause
    exit 1
}

# Step 5: Start services
Write-Host "`n[5/5] Starting all services..." -ForegroundColor Yellow
docker-compose up -d

Start-Sleep -Seconds 5

# Verify services
Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  SERVICE STATUS" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

docker-compose ps

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  WAITING FOR SERVICES TO BE READY..." -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# Wait for database
Write-Host "⏳ Waiting for PostgreSQL..." -ForegroundColor Gray
Start-Sleep -Seconds 10
Write-Host "   ✓ Database ready!" -ForegroundColor Green

# Wait for Redis
Write-Host "⏳ Waiting for Redis..." -ForegroundColor Gray
Start-Sleep -Seconds 5
Write-Host "   ✓ Redis ready!" -ForegroundColor Green

# Wait for Backend
Write-Host "⏳ Waiting for Backend API..." -ForegroundColor Gray
$backendReady = $false
$attempts = 0
while (-not $backendReady -and $attempts -lt 20) {
    $attempts++
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:4000/health" -TimeoutSec 2 -UseBasicParsing -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            $backendReady = $true
            Write-Host "   ✓ Backend API ready!" -ForegroundColor Green
        }
    } catch {
        Start-Sleep -Seconds 3
    }
}

# Wait for Frontend
Write-Host "⏳ Waiting for Frontend..." -ForegroundColor Gray
Start-Sleep -Seconds 10
Write-Host "   ✓ Frontend ready!" -ForegroundColor Green

# Wait for Jenkins
Write-Host "⏳ Waiting for Jenkins (this takes 30-60 seconds)..." -ForegroundColor Gray
$jenkinsReady = $false
$attempts = 0
while (-not $jenkinsReady -and $attempts -lt 30) {
    $attempts++
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8080/login" -TimeoutSec 2 -UseBasicParsing -ErrorAction SilentlyContinue
        if ($response.StatusCode -eq 200) {
            $jenkinsReady = $true
            Write-Host "   ✓ Jenkins ready!" -ForegroundColor Green
        }
    } catch {
        Start-Sleep -Seconds 3
    }
}

# Success message
Write-Host "`n========================================" -ForegroundColor Green
Write-Host "  🎉 ALL SERVICES ARE RUNNING! 🎉" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Green

Write-Host "📊 Dashboard:    " -NoNewline -ForegroundColor White
Write-Host "http://localhost:3000" -ForegroundColor Cyan

Write-Host "🔧 Backend API:  " -NoNewline -ForegroundColor White
Write-Host "http://localhost:4000" -ForegroundColor Cyan

Write-Host "🏗️  Jenkins:      " -NoNewline -ForegroundColor White
Write-Host "http://localhost:8080" -ForegroundColor Cyan
Write-Host "   Login: " -NoNewline -ForegroundColor Gray
Write-Host "admin / admin123" -ForegroundColor Yellow

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "  NEXT STEPS" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "1. Open Jenkins: " -NoNewline
Write-Host "http://localhost:8080" -ForegroundColor Cyan

Write-Host "2. Login with: " -NoNewline
Write-Host "admin / admin123" -ForegroundColor Yellow

Write-Host "3. Click " -NoNewline
Write-Host "'sample-pipeline'" -ForegroundColor Cyan -NoNewline
Write-Host " → " -NoNewline
Write-Host "'Build Now'" -ForegroundColor Cyan

Write-Host "4. Open Dashboard: " -NoNewline
Write-Host "http://localhost:3000" -ForegroundColor Cyan

Write-Host "5. Watch the build appear in real-time! 🚀`n" -ForegroundColor Green

Write-Host "📚 For GitHub integration, see: " -NoNewline
Write-Host "SETUP-JENKINS-GITHUB.md`n" -ForegroundColor Cyan

Write-Host "========================================`n" -ForegroundColor Cyan

# Offer to open browser
$openBrowser = Read-Host "Open Dashboard in browser? (Y/N)"
if ($openBrowser -eq "Y" -or $openBrowser -eq "y") {
    Start-Process "http://localhost:3000"
    Start-Sleep -Seconds 2
    Start-Process "http://localhost:8080"
}

Write-Host "`nPress any key to exit..." -ForegroundColor Gray
pause
