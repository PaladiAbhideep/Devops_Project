# Automated Jenkins Setup and GitHub Connection Script
# Run this script to set up Jenkins and connect to GitHub repository

$ErrorActionPreference = "Continue"

Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "  JENKINS + GITHUB SETUP AUTOMATION" -ForegroundColor Cyan
Write-Host "============================================`n" -ForegroundColor Cyan

# Step 1: Check Java
Write-Host "[1/8] Checking Java..." -ForegroundColor Yellow
$javaCheck = Get-Command java -ErrorAction SilentlyContinue
if ($javaCheck) {
    $javaVersion = java -version 2>&1 | Select-String "version" | Select-Object -First 1
    Write-Host "      ✓ Java installed: $javaVersion" -ForegroundColor Green
} else {
    Write-Host "      ❌ Java not found!" -ForegroundColor Red
    Write-Host "      Please install Java JDK from: https://adoptium.net/" -ForegroundColor Yellow
    pause
    exit 1
}

# Step 2: Check PostgreSQL
Write-Host "`n[2/8] Checking PostgreSQL..." -ForegroundColor Yellow
$pgService = Get-Service postgresql* -ErrorAction SilentlyContinue | Select-Object -First 1
if ($pgService) {
    if ($pgService.Status -eq "Running") {
        Write-Host "      ✓ PostgreSQL is running" -ForegroundColor Green
    } else {
        Write-Host "      Starting PostgreSQL..." -NoNewline
        Start-Service $pgService.Name
        Write-Host " ✓" -ForegroundColor Green
    }
} else {
    Write-Host "      ⚠️  PostgreSQL not found - install from: https://www.postgresql.org/download/windows/" -ForegroundColor Yellow
}

# Step 3: Check Redis/Memurai
Write-Host "`n[3/8] Checking Redis..." -ForegroundColor Yellow
$redisService = Get-Service Memurai -ErrorAction SilentlyContinue
if ($redisService) {
    if ($redisService.Status -eq "Running") {
        Write-Host "      ✓ Redis (Memurai) is running" -ForegroundColor Green
    } else {
        Write-Host "      Starting Redis..." -NoNewline
        Start-Service Memurai
        Write-Host " ✓" -ForegroundColor Green
    }
} else {
    Write-Host "      ⚠️  Redis not found - install from: https://www.memurai.com/get-memurai" -ForegroundColor Yellow
}

# Step 4: Setup Jenkins
Write-Host "`n[4/8] Setting up Jenkins..." -ForegroundColor Yellow

if (-not (Test-Path "C:\Jenkins")) {
    Write-Host "      Creating Jenkins directory..." -NoNewline
    New-Item -Path "C:\Jenkins" -ItemType Directory -Force | Out-Null
    Write-Host " ✓" -ForegroundColor Green
}

if (-not (Test-Path "C:\Jenkins\jenkins.war")) {
    Write-Host "      Downloading Jenkins (this may take a few minutes)..." -ForegroundColor Gray
    $downloadSuccess = $true
    try {
        Invoke-WebRequest -Uri "https://get.jenkins.io/war-stable/2.479.1/jenkins.war" -OutFile "C:\Jenkins\jenkins.war" -ErrorAction Stop
        Write-Host "      ✓ Jenkins downloaded" -ForegroundColor Green
    } catch {
        $downloadSuccess = $false
        Write-Host "      ❌ Download failed. Please download manually from: https://www.jenkins.io/download/" -ForegroundColor Red
    }
} else {
    Write-Host "      ✓ Jenkins already downloaded" -ForegroundColor Green
}

# Step 5: Check if Dashboard services are ready
Write-Host "`n[5/8] Checking Dashboard services..." -ForegroundColor Yellow

$projectPath = "C:\Users\tests\Downloads\cicd project"
if (Test-Path $projectPath) {
    Write-Host "      ✓ Project found" -ForegroundColor Green
    
    # Check if node_modules exist
    $needsInstall = $false
    foreach ($dir in @("backend", "frontend", "worker")) {
        if (-not (Test-Path "$projectPath\$dir\node_modules")) {
            $needsInstall = $true
            break
        }
    }
    
    if ($needsInstall) {
        Write-Host "      Installing npm dependencies..." -ForegroundColor Gray
        Write-Host "      (This may take 5-10 minutes)" -ForegroundColor Gray
        
        # Backend
        Write-Host "      - Installing backend..." -NoNewline
        cd "$projectPath\backend"
        npm install --silent 2>&1 | Out-Null
        Write-Host " ✓" -ForegroundColor Green
        
        # Frontend
        Write-Host "      - Installing frontend..." -NoNewline
        cd "$projectPath\frontend"
        npm install --silent 2>&1 | Out-Null
        Write-Host " ✓" -ForegroundColor Green
        
        # Worker
        Write-Host "      - Installing worker..." -NoNewline
        cd "$projectPath\worker"
        npm install --silent 2>&1 | Out-Null
        Write-Host " ✓" -ForegroundColor Green
        
        cd $projectPath
    } else {
        Write-Host "      ✓ Dependencies already installed" -ForegroundColor Green
    }
} else {
    Write-Host "      ❌ Project not found at: $projectPath" -ForegroundColor Red
}

# Step 6: Start Dashboard Services
Write-Host "`n[6/8] Starting Dashboard services..." -ForegroundColor Yellow

Write-Host "      Starting Backend..." -NoNewline
Start-Process powershell -ArgumentList "-NoExit", "-File", "$projectPath\backend\start-backend.ps1" -WindowStyle Minimized
Start-Sleep -Seconds 3
Write-Host " ✓" -ForegroundColor Green

Write-Host "      Starting Worker..." -NoNewline
Start-Process powershell -ArgumentList "-NoExit", "-File", "$projectPath\worker\start-worker.ps1" -WindowStyle Minimized
Start-Sleep -Seconds 2
Write-Host " ✓" -ForegroundColor Green

Write-Host "      Starting Frontend..." -NoNewline
Start-Process powershell -ArgumentList "-NoExit", "-File", "$projectPath\frontend\start-frontend.ps1" -WindowStyle Minimized
Start-Sleep -Seconds 3
Write-Host " ✓" -ForegroundColor Green

# Step 7: Start Jenkins
Write-Host "`n[7/8] Starting Jenkins..." -ForegroundColor Yellow
Write-Host "      Jenkins will open in a new window" -ForegroundColor Gray
Write-Host "      Initial startup takes 30-60 seconds`n" -ForegroundColor Gray

Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd C:\Jenkins; Write-Host 'Starting Jenkins...' -ForegroundColor Green; Write-Host 'Wait for: Jenkins is fully up and running' -ForegroundColor Yellow; Write-Host '`n'; java -jar jenkins.war --httpPort=8080"

# Wait for Jenkins to start
Write-Host "      Waiting for Jenkins to start..." -ForegroundColor Gray
Start-Sleep -Seconds 20

# Step 8: Instructions
Write-Host "`n[8/8] Setup Complete!" -ForegroundColor Green

Write-Host "`n============================================" -ForegroundColor Green
Write-Host "  🎉 SERVICES STARTED!" -ForegroundColor Green
Write-Host "============================================`n" -ForegroundColor Green

Write-Host "Services are running in minimized windows." -ForegroundColor White
Write-Host "You can restore them from the taskbar if needed.`n" -ForegroundColor Gray

Write-Host "📊 Dashboard:    " -NoNewline
Write-Host "http://localhost:3000" -ForegroundColor Cyan

Write-Host "🔧 Backend API:  " -NoNewline
Write-Host "http://localhost:4000" -ForegroundColor Cyan

Write-Host "🏗️  Jenkins:      " -NoNewline
Write-Host "http://localhost:8080" -ForegroundColor Cyan

Write-Host "`n============================================" -ForegroundColor Cyan
Write-Host "  NEXT: CONNECT GITHUB TO JENKINS" -ForegroundColor Cyan
Write-Host "============================================`n" -ForegroundColor Cyan

Write-Host "Step 1: Wait for Jenkins to be ready (30-60 seconds)" -ForegroundColor White
Write-Host "        Check Jenkins window for: 'Jenkins is fully up and running'`n" -ForegroundColor Gray

Write-Host "Step 2: Get Jenkins Initial Password" -ForegroundColor White
Write-Host "        Run this command:" -ForegroundColor Gray
Write-Host "        Get-Content `"C:\Jenkins\jenkins_home\secrets\initialAdminPassword`"`n" -ForegroundColor Yellow

Write-Host "Step 3: Open Jenkins in browser" -ForegroundColor White
Write-Host "        http://localhost:8080" -ForegroundColor Cyan
Write-Host "        Paste the password from Step 2`n" -ForegroundColor Gray

Write-Host "Step 4: Install Plugins" -ForegroundColor White
Write-Host "        - Click 'Install suggested plugins'" -ForegroundColor Gray
Write-Host "        - Wait for installation to complete`n" -ForegroundColor Gray

Write-Host "Step 5: Create Admin User" -ForegroundColor White
Write-Host "        Username: admin" -ForegroundColor Gray
Write-Host "        Password: admin123`n" -ForegroundColor Gray

Write-Host "Step 6: Install Additional Plugins" -ForegroundColor White
Write-Host "        Manage Jenkins → Plugins → Available plugins" -ForegroundColor Gray
Write-Host "        Search and install:" -ForegroundColor Gray
Write-Host "        - Git" -ForegroundColor Yellow
Write-Host "        - GitHub" -ForegroundColor Yellow
Write-Host "        - Pipeline" -ForegroundColor Yellow
Write-Host "        - HTTP Request Plugin`n" -ForegroundColor Yellow

Write-Host "Step 7: Create GitHub Personal Access Token" -ForegroundColor White
Write-Host "        Go to: https://github.com/settings/tokens" -ForegroundColor Cyan
Write-Host "        - Generate new token (classic)" -ForegroundColor Gray
Write-Host "        - Check 'repo' scope" -ForegroundColor Gray
Write-Host "        - Copy the token`n" -ForegroundColor Gray

Write-Host "Step 8: Add Credentials to Jenkins" -ForegroundColor White
Write-Host "        Manage Jenkins → Credentials → Add Credentials" -ForegroundColor Gray
Write-Host "        - Kind: Username with password" -ForegroundColor Gray
Write-Host "        - Username: PaladiAbhideep" -ForegroundColor Gray
Write-Host "        - Password: <your GitHub token>" -ForegroundColor Gray
Write-Host "        - ID: github-credentials`n" -ForegroundColor Gray

Write-Host "Step 9: Create Pipeline Job" -ForegroundColor White
Write-Host "        New Item → Pipeline" -ForegroundColor Gray
Write-Host "        Name: Devops_Project_Pipeline" -ForegroundColor Gray
Write-Host "        - Check 'GitHub project'" -ForegroundColor Gray
Write-Host "        - URL: https://github.com/PaladiAbhideep/Devops_Project" -ForegroundColor Gray
Write-Host "        - Check 'Poll SCM' → Schedule: H/5 * * * *" -ForegroundColor Gray
Write-Host "        - Pipeline from SCM → Git" -ForegroundColor Gray
Write-Host "        - Repository: https://github.com/PaladiAbhideep/Devops_Project.git" -ForegroundColor Gray
Write-Host "        - Credentials: github-credentials" -ForegroundColor Gray
Write-Host "        - Branch: */main" -ForegroundColor Gray
Write-Host "        - Script Path: Jenkinsfile`n" -ForegroundColor Gray

Write-Host "Step 10: Test!" -ForegroundColor White
Write-Host "        Click 'Build Now'" -ForegroundColor Gray
Write-Host "        Watch the build in Jenkins" -ForegroundColor Gray
Write-Host "        See it appear in Dashboard: http://localhost:3000`n" -ForegroundColor Cyan

Write-Host "============================================`n" -ForegroundColor Cyan

Write-Host "📚 Detailed guides available:" -ForegroundColor White
Write-Host "   - SETUP-CHECKLIST.md" -ForegroundColor Yellow
Write-Host "   - CONNECT-GITHUB-TO-JENKINS.md`n" -ForegroundColor Yellow

$openBrowser = Read-Host "Open Jenkins in browser? (Y/N)"
if ($openBrowser -eq "Y" -or $openBrowser -eq "y") {
    Start-Sleep -Seconds 10
    Start-Process "http://localhost:8080"
    Start-Sleep -Seconds 2
    Start-Process "http://localhost:3000"
}

Write-Host "`nPress any key to exit (services will keep running)..." -ForegroundColor Gray
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
