# Simple Jenkins + GitHub Connection Script
# This script will help you connect your GitHub repository to Jenkins

Write-Host "`n=====================================" -ForegroundColor Cyan
Write-Host " JENKINS + GITHUB SETUP" -ForegroundColor Cyan
Write-Host "=====================================`n" -ForegroundColor Cyan

# Check Java
Write-Host "[1/6] Checking Java..." -ForegroundColor Yellow
$javaCmd = Get-Command java -ErrorAction SilentlyContinue
if ($javaCmd) {
    Write-Host "      ✓ Java is installed" -ForegroundColor Green
} else {
    Write-Host "      ❌ Java not found! Install from: https://adoptium.net/" -ForegroundColor Red
    exit 1
}

# Check PostgreSQL
Write-Host "`n[2/6] Checking PostgreSQL..." -ForegroundColor Yellow
$pgService = Get-Service postgresql* -ErrorAction SilentlyContinue | Select-Object -First 1
if ($pgService -and $pgService.Status -eq "Running") {
    Write-Host "      ✓ PostgreSQL is running" -ForegroundColor Green
} else {
    Write-Host "      ⚠️  PostgreSQL not running" -ForegroundColor Yellow
}

# Check Redis
Write-Host "`n[3/6] Checking Redis..." -ForegroundColor Yellow
$redisService = Get-Service Memurai -ErrorAction SilentlyContinue
if ($redisService -and $redisService.Status -eq "Running") {
    Write-Host "      ✓ Redis is running" -ForegroundColor Green
} else {
    Write-Host "      ⚠️  Redis not running" -ForegroundColor Yellow
}

# Setup Jenkins directory
Write-Host "`n[4/6] Setting up Jenkins..." -ForegroundColor Yellow
if (-not (Test-Path "C:\Jenkins")) {
    New-Item -Path "C:\Jenkins" -ItemType Directory -Force | Out-Null
    Write-Host "      ✓ Created Jenkins directory" -ForegroundColor Green
}

# Check if Jenkins exists
if (-not (Test-Path "C:\Jenkins\jenkins.war")) {
    Write-Host "      Downloading Jenkins..." -ForegroundColor Gray
    Invoke-WebRequest -Uri "https://get.jenkins.io/war-stable/2.479.1/jenkins.war" -OutFile "C:\Jenkins\jenkins.war"
    Write-Host "      ✓ Jenkins downloaded" -ForegroundColor Green
} else {
    Write-Host "      ✓ Jenkins already exists" -ForegroundColor Green
}

# Start Dashboard services
Write-Host "`n[5/6] Starting Dashboard services..." -ForegroundColor Yellow
$projectPath = "C:\Users\tests\Downloads\cicd project"

Write-Host "      Starting Backend..." -NoNewline
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$projectPath\backend'; npm run dev"
Start-Sleep -Seconds 2
Write-Host " ✓" -ForegroundColor Green

Write-Host "      Starting Worker..." -NoNewline
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$projectPath\worker'; npm run dev"
Start-Sleep -Seconds 2
Write-Host " ✓" -ForegroundColor Green

Write-Host "      Starting Frontend..." -NoNewline
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$projectPath\frontend'; npm run dev"
Start-Sleep -Seconds 2
Write-Host " ✓" -ForegroundColor Green

# Start Jenkins
Write-Host "`n[6/6] Starting Jenkins..." -ForegroundColor Yellow
Write-Host "      Opening Jenkins in new window..." -ForegroundColor Gray
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd C:\Jenkins; Write-Host 'Starting Jenkins on http://localhost:8080' -ForegroundColor Green; java -jar jenkins.war --httpPort=8080"

Write-Host "`n=====================================" -ForegroundColor Green
Write-Host " ✓ ALL SERVICES STARTED!" -ForegroundColor Green
Write-Host "=====================================`n" -ForegroundColor Green

Write-Host "Services:" -ForegroundColor White
Write-Host "  Dashboard:  http://localhost:3000" -ForegroundColor Cyan
Write-Host "  Backend:    http://localhost:4000" -ForegroundColor Cyan
Write-Host "  Jenkins:    http://localhost:8080" -ForegroundColor Cyan

Write-Host "`n=====================================" -ForegroundColor Cyan
Write-Host " CONNECT GITHUB TO JENKINS" -ForegroundColor Cyan
Write-Host "=====================================`n" -ForegroundColor Cyan

Write-Host "Wait 30 seconds for Jenkins to start, then:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Get Jenkins password:" -ForegroundColor White
Write-Host '   Get-Content "C:\Jenkins\jenkins_home\secrets\initialAdminPassword"' -ForegroundColor Yellow
Write-Host ""
Write-Host "2. Open: http://localhost:8080" -ForegroundColor White
Write-Host "   Paste password" -ForegroundColor Gray
Write-Host ""
Write-Host "3. Install suggested plugins" -ForegroundColor White
Write-Host ""
Write-Host "4. Create admin user (admin/admin123)" -ForegroundColor White
Write-Host ""
Write-Host "5. Add GitHub token:" -ForegroundColor White
Write-Host "   a. Get token: https://github.com/settings/tokens" -ForegroundColor Gray
Write-Host "   b. Jenkins → Manage → Credentials → Add" -ForegroundColor Gray
Write-Host "      Username: PaladiAbhideep" -ForegroundColor Gray
Write-Host "      Password: <your GitHub token>" -ForegroundColor Gray
Write-Host "      ID: github-credentials" -ForegroundColor Gray
Write-Host ""
Write-Host "6. Create Pipeline Job:" -ForegroundColor White
Write-Host "   New Item → Pipeline → Name: Devops_Project_Pipeline" -ForegroundColor Gray
Write-Host "   - GitHub project: https://github.com/PaladiAbhideep/Devops_Project" -ForegroundColor Gray
Write-Host "   - Poll SCM: H/5 * * * *" -ForegroundColor Gray
Write-Host "   - Pipeline from SCM → Git" -ForegroundColor Gray
Write-Host "   - Repo: https://github.com/PaladiAbhideep/Devops_Project.git" -ForegroundColor Gray
Write-Host "   - Credentials: github-credentials" -ForegroundColor Gray
Write-Host "   - Branch: */main" -ForegroundColor Gray
Write-Host "   - Script: Jenkinsfile" -ForegroundColor Gray
Write-Host ""
Write-Host "7. Click 'Build Now' and watch it work!" -ForegroundColor White
Write-Host ""
Write-Host "Full guide: CONNECT-GITHUB-TO-JENKINS.md" -ForegroundColor Cyan
Write-Host ""

Start-Sleep -Seconds 5
$openJenkins = Read-Host "Open Jenkins now? (Y/N)"
if ($openJenkins -eq "Y" -or $openJenkins -eq "y") {
    Start-Sleep -Seconds 15
    Start-Process "http://localhost:8080"
    Start-Process "http://localhost:3000"
}
