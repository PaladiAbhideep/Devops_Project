# Jenkins Setup Without Docker - Complete Guide

## 🎯 Goal: Run Everything with Jenkins (No Docker)

This guide shows you how to set up Jenkins natively on Windows to run your CI/CD pipelines, without using Docker at all.

---

## 📋 What You'll Set Up

1. ✅ **Jenkins** - Running natively on Windows
2. ✅ **PostgreSQL** - Windows service for database
3. ✅ **Redis** (Memurai) - Windows service for caching
4. ✅ **Backend API** - Node.js service
5. ✅ **Frontend** - React development server
6. ✅ **Worker** - Pipeline execution service

---

## 🚀 Step-by-Step Installation

### Step 1: Install Java JDK (Required for Jenkins)

1. **Download Java JDK 17**
   - Go to: https://adoptium.net/
   - Download: **JDK 17 LTS (Windows x64 installer)**

2. **Install Java**
   - Run the installer
   - Keep default options
   - Note installation path (e.g., `C:\Program Files\Eclipse Adoptium\jdk-17.0.x.x`)

3. **Verify Installation**
```powershell
java -version
```

Expected output:
```
openjdk version "17.0.x"
```

---

### Step 2: Install PostgreSQL

1. **Download PostgreSQL 15**
   - Go to: https://www.postgresql.org/download/windows/
   - Download: **PostgreSQL 15.x Windows installer**

2. **Install PostgreSQL**
   - Run installer
   - **Password**: Set to `postgres123` (or remember your own)
   - **Port**: 5432 (default)
   - Install all components
   - Keep "Stack Builder" unchecked

3. **Create Database**
```powershell
# Open PowerShell and run:
psql -U postgres

# In psql (enter your password):
CREATE DATABASE cicd_dashboard;
\q
```

4. **Setup Tables**
```powershell
cd "C:\Users\tests\Downloads\cicd project"
psql -U postgres -d cicd_dashboard -f setup-database.sql
```

---

### Step 3: Install Redis (Memurai)

1. **Download Memurai** (Redis for Windows)
   - Go to: https://www.memurai.com/get-memurai
   - Download: **Memurai Developer Edition** (Free)

2. **Install Memurai**
   - Run installer
   - Keep default port: 6379
   - Install as Windows Service: ✅ Yes

3. **Verify Service**
```powershell
Get-Service Memurai
# Should show "Running"
```

---

### Step 4: Install Jenkins

1. **Download Jenkins WAR**
```powershell
# Create Jenkins directory
mkdir C:\Jenkins
cd C:\Jenkins

# Download Jenkins WAR file
Invoke-WebRequest -Uri "https://get.jenkins.io/war-stable/latest/jenkins.war" -OutFile "jenkins.war"
```

2. **Create Jenkins Home Directory**
```powershell
# Create directory for Jenkins data
mkdir C:\Jenkins\jenkins_home

# Set environment variable
[System.Environment]::SetEnvironmentVariable('JENKINS_HOME', 'C:\Jenkins\jenkins_home', 'User')
```

3. **Start Jenkins**
```powershell
cd C:\Jenkins
java -jar jenkins.war --httpPort=8080
```

Wait for: `Jenkins is fully up and running`

4. **Access Jenkins**
   - Open browser: http://localhost:8080
   - You'll see "Unlock Jenkins" screen

5. **Get Initial Admin Password**
```powershell
# In a NEW PowerShell window:
Get-Content "C:\Jenkins\jenkins_home\secrets\initialAdminPassword"
```

Copy this password and paste it in the browser.

6. **Install Plugins**
   - Select: **"Install suggested plugins"**
   - Wait for installation (5-10 minutes)

7. **Create Admin User**
   - Username: `admin`
   - Password: `admin123` (or your choice)
   - Full name: `Your Name`
   - Email: `your@email.com`
   - Click: **"Save and Continue"**

8. **Jenkins URL**
   - Keep: `http://localhost:8080/`
   - Click: **"Save and Finish"**

---

### Step 5: Configure Jenkins for CI/CD Dashboard

#### Install Additional Plugins

1. **Go to Jenkins Dashboard**
   - Click: **"Manage Jenkins"** → **"Plugins"**
   - Click: **"Available plugins"**

2. **Search and Install:**
   - ✅ Pipeline
   - ✅ Git
   - ✅ GitHub
   - ✅ HTTP Request Plugin
   - ✅ Credentials Binding

3. **Click**: "Download now and install after restart"
4. **Check**: "Restart Jenkins when installation is complete"

---

### Step 6: Install Node.js Dependencies

```powershell
cd "C:\Users\tests\Downloads\cicd project"

# Backend
cd backend
npm install
cd ..

# Frontend
cd frontend
npm install
cd ..

# Worker
cd worker
npm install
cd ..
```

---

### Step 7: Create Environment Files

All environment files should already exist (created by previous scripts), but verify:

**backend/.env**
```env
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=postgres123
DB_NAME=cicd_dashboard

REDIS_HOST=localhost
REDIS_PORT=6379

PORT=4000
NODE_ENV=development
CORS_ORIGIN=http://localhost:3000
```

**frontend/.env**
```env
VITE_API_URL=http://localhost:4000
VITE_WS_URL=ws://localhost:4000
```

**worker/.env**
```env
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=postgres123
DB_NAME=cicd_dashboard

REDIS_HOST=localhost
REDIS_PORT=6379
NODE_ENV=development
```

---

## 🎮 Running the Application

### Option 1: Use the Master Script

```powershell
cd "C:\Users\tests\Downloads\cicd project"
.\START-WINDOWS.ps1
```

This will:
- ✅ Start Backend (Port 4000)
- ✅ Start Worker (Background)
- ✅ Start Frontend (Port 3000)

### Option 2: Start Services Manually

**Terminal 1 - Backend:**
```powershell
cd "C:\Users\tests\Downloads\cicd project\backend"
npm run dev
```

**Terminal 2 - Worker:**
```powershell
cd "C:\Users\tests\Downloads\cicd project\worker"
npm run dev
```

**Terminal 3 - Frontend:**
```powershell
cd "C:\Users\tests\Downloads\cicd project\frontend"
npm run dev
```

**Terminal 4 - Jenkins:**
```powershell
cd C:\Jenkins
java -jar jenkins.war --httpPort=8080
```

---

## 🏗️ Create Jenkins Pipeline Job

### Step 1: Create New Job

1. **Go to Jenkins**: http://localhost:8080
2. **Click**: "New Item"
3. **Name**: `dashboard-pipeline`
4. **Type**: "Pipeline"
5. **Click**: "OK"

### Step 2: Configure Pipeline

**General Section:**
- Description: `CI/CD Dashboard Pipeline`

**Build Triggers:**
- ✅ Check: "Poll SCM"
- Schedule: `H/5 * * * *` (every 5 minutes)

**Pipeline Section:**
- Definition: **"Pipeline script from SCM"**
- SCM: **"Git"**
- Repository URL: `https://github.com/PaladiAbhideep/Devops_Project.git`
- Branch: `*/main`
- Script Path: `Jenkinsfile`

**Click**: "Save"

---

## 🎯 Testing Your Setup

### Test 1: Run Jenkins Pipeline

1. Go to Jenkins: http://localhost:8080
2. Click: `dashboard-pipeline`
3. Click: **"Build Now"**
4. Watch the build execute!

### Test 2: Check Dashboard

1. Open: http://localhost:3000
2. You should see the pipeline run appear!
3. Watch logs stream in real-time!

### Test 3: Manual API Test

```powershell
# Create a pipeline run
curl -X POST http://localhost:4000/api/runs `
  -H "Content-Type: application/json" `
  -d '{\"pipelineId\": 1, \"triggeredBy\": \"manual\"}'

# Check Dashboard - should appear immediately!
```

---

## 🔄 Daily Workflow

### Starting Your Day:

```powershell
# 1. Start Jenkins
cd C:\Jenkins
java -jar jenkins.war --httpPort=8080

# 2. Start Dashboard Services (in new window)
cd "C:\Users\tests\Downloads\cicd project"
.\START-WINDOWS.ps1

# 3. Open Dashboard
start http://localhost:3000

# 4. Open Jenkins
start http://localhost:8080
```

### Ending Your Day:

```powershell
# Stop Node.js processes
Get-Process node | Stop-Process -Force

# Stop Jenkins (Ctrl+C in Jenkins terminal)
```

---

## 📊 Service URLs

| Service | URL | Status |
|---------|-----|--------|
| Dashboard | http://localhost:3000 | ✅ |
| Backend API | http://localhost:4000 | ✅ |
| Jenkins | http://localhost:8080 | ✅ |
| PostgreSQL | localhost:5432 | ✅ |
| Redis | localhost:6379 | ✅ |

---

## 🐛 Troubleshooting

### Jenkins Won't Start

```powershell
# Check Java version
java -version

# Run with more memory
java -Xmx2g -jar C:\Jenkins\jenkins.war --httpPort=8080

# Check logs
Get-Content "C:\Jenkins\jenkins_home\jenkins.log" -Tail 50
```

### PostgreSQL Not Running

```powershell
# Check service
Get-Service postgresql*

# Start service
Start-Service postgresql-x64-15
```

### Redis/Memurai Not Running

```powershell
# Check service
Get-Service Memurai

# Start service
Start-Service Memurai
```

### Port Already in Use

```powershell
# Check what's using port 8080 (Jenkins)
Get-NetTCPConnection -LocalPort 8080

# Kill process
Stop-Process -Id <PID> -Force
```

### Backend Can't Connect to Database

1. Check PostgreSQL is running
2. Verify password in `backend/.env`
3. Test connection:
```powershell
psql -U postgres -d cicd_dashboard -c "SELECT 1;"
```

---

## 🎨 Making Jenkins Run as Windows Service (Optional)

To run Jenkins automatically when Windows starts:

### Using NSSM (Non-Sucking Service Manager)

1. **Download NSSM**
```powershell
# Download from: https://nssm.cc/download
# Or use chocolatey:
choco install nssm
```

2. **Install Jenkins as Service**
```powershell
# Open PowerShell as Administrator
nssm install Jenkins "C:\Program Files\Eclipse Adoptium\jdk-17.0.x.x\bin\java.exe" "-jar C:\Jenkins\jenkins.war --httpPort=8080"

# Set working directory
nssm set Jenkins AppDirectory "C:\Jenkins"

# Set environment
nssm set Jenkins AppEnvironmentExtra "JENKINS_HOME=C:\Jenkins\jenkins_home"

# Start service
nssm start Jenkins
```

3. **Verify Service**
```powershell
Get-Service Jenkins
```

Now Jenkins will start automatically with Windows!

---

## ✅ Success Checklist

- [ ] Java JDK 17 installed
- [ ] PostgreSQL installed and running
- [ ] Redis (Memurai) installed and running
- [ ] Node.js installed
- [ ] Jenkins downloaded and running
- [ ] Jenkins plugins installed
- [ ] Database created and tables setup
- [ ] npm dependencies installed
- [ ] Environment files created
- [ ] Backend running on port 4000
- [ ] Frontend running on port 3000
- [ ] Worker running in background
- [ ] Jenkins accessible at http://localhost:8080
- [ ] Dashboard accessible at http://localhost:3000
- [ ] Jenkins pipeline job created
- [ ] Test build successful

---

## 🎓 Next Steps

1. ✅ Setup complete without Docker
2. ⬜ Configure GitHub webhooks for automatic builds
3. ⬜ Add more pipeline jobs
4. ⬜ Customize Jenkinsfile for your needs
5. ⬜ Set up email notifications
6. ⬜ Add deployment stages

---

## 📚 Documentation

- **This Guide**: JENKINS.md (Jenkins without Docker)
- **Windows Setup**: SETUP-WINDOWS-NO-DOCKER.md
- **Quick Start**: QUICKSTART-WINDOWS.md
- **Project Overview**: README.md

---

**You're now running a complete CI/CD pipeline with Jenkins - NO DOCKER NEEDED!** 🚀
