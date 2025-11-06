# CI/CD Pipeline Dashboard - Windows Setup (No Docker)

## 🎯 What You'll Set Up

All services running natively on Windows:
- ✅ PostgreSQL database
- ✅ Redis cache
- ✅ Backend API (Node.js)
- ✅ Frontend (React)
- ✅ Worker (Pipeline simulator)
- ✅ Jenkins CI/CD server

## 📋 Prerequisites

- Windows 10/11
- Administrator access
- Internet connection
- 8GB+ RAM recommended

## 🚀 Step-by-Step Installation

### Step 1: Install Node.js (5 minutes)

1. **Download Node.js**
   - Go to: https://nodejs.org/
   - Download: **LTS version** (v20.x or higher)
   - Run the installer

2. **Verify installation**
```powershell
node --version
npm --version
```

Expected output: `v20.x.x` and `10.x.x`

---

### Step 2: Install PostgreSQL (10 minutes)

1. **Download PostgreSQL**
   - Go to: https://www.postgresql.org/download/windows/
   - Click "Download the installer"
   - Download PostgreSQL 15.x

2. **Run installer**
   - Double-click the downloaded file
   - Click "Next" through screens
   - **Important**: Remember your password! (e.g., `postgres123`)
   - Port: `5432` (default)
   - Install all components

3. **Verify installation**
```powershell
# This should open psql
psql --version
```

4. **Create database**
```powershell
# Connect to PostgreSQL (password: your postgres password)
psql -U postgres

# In psql, run:
CREATE DATABASE cicd_dashboard;
\c cicd_dashboard
```

5. **Create tables** (in psql):
```sql
-- Pipelines table
CREATE TABLE pipelines (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    repo VARCHAR(500) NOT NULL,
    branch VARCHAR(100) NOT NULL DEFAULT 'main',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Runs table
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

-- Steps table
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

-- Logs table
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

-- Insert sample pipeline
INSERT INTO pipelines (name, repo, branch) 
VALUES ('Sample Pipeline', 'https://github.com/sample/repo', 'main');

-- Verify
SELECT * FROM pipelines;

-- Exit psql
\q
```

---

### Step 3: Install Redis (5 minutes)

**Option A: Memurai (Recommended for Windows)**

1. **Download Memurai** (Redis for Windows)
   - Go to: https://www.memurai.com/get-memurai
   - Download Memurai Developer Edition (Free)

2. **Install**
   - Run installer
   - Keep default port: `6379`
   - Install as Windows Service

3. **Verify**
```powershell
# Redis should be running as a service
Get-Service Memurai
```

**Option B: WSL + Redis (Alternative)**

```powershell
# Enable WSL
wsl --install

# Install Ubuntu
wsl --install -d Ubuntu

# In WSL terminal:
sudo apt update
sudo apt install redis-server -y
sudo service redis-server start

# Keep WSL terminal open while running the app
```

---

### Step 4: Install Jenkins (10 minutes)

1. **Install Java JDK**
   - Go to: https://adoptium.net/
   - Download: **JDK 17 LTS**
   - Install with defaults

2. **Verify Java**
```powershell
java -version
```

3. **Download Jenkins**
   - Go to: https://www.jenkins.io/download/
   - Click "Generic Java package (.war)"
   - Save to: `C:\Jenkins\jenkins.war`

4. **Create Jenkins directory structure**
```powershell
mkdir C:\Jenkins
mkdir C:\Jenkins\plugins
```

---

### Step 5: Install Project Dependencies (5 minutes)

```powershell
cd "C:\Users\tests\Downloads\cicd project"

# Install backend dependencies
cd backend
npm install

# Install frontend dependencies
cd ..\frontend
npm install

# Install worker dependencies
cd ..\worker
npm install

cd ..
```

---

### Step 6: Configure Environment (5 minutes)

1. **Create backend .env file**
```powershell
cd backend
New-Item -Path ".env" -ItemType File
```

Add this content to `backend/.env`:
```env
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
```

2. **Create worker .env file**
```powershell
cd ..\worker
New-Item -Path ".env" -ItemType File
```

Add this content to `worker/.env`:
```env
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
```

3. **Create frontend .env file**
```powershell
cd ..\frontend
New-Item -Path ".env" -ItemType File
```

Add this content to `frontend/.env`:
```env
VITE_API_URL=http://localhost:4000
VITE_WS_URL=ws://localhost:4000
```

---

### Step 7: Create Startup Scripts (5 minutes)

I'll create PowerShell scripts to start each service.

**1. Backend startup script:**
```powershell
cd "C:\Users\tests\Downloads\cicd project"
```

**2. Frontend startup script:**
(Creating these next...)

**3. Worker startup script:**
(Creating these next...)

**4. Jenkins startup script:**
(Creating these next...)

---

## 🎮 Running the Application

### Start Services in Order:

**Terminal 1 - Backend API:**
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

### Access URLs:

- 📊 **Dashboard**: http://localhost:3000
- 🔧 **Backend API**: http://localhost:4000
- 🏗️ **Jenkins**: http://localhost:8080

---

## 🔧 Service Details

### Backend (Port 4000)
- REST API endpoints
- WebSocket server for real-time updates
- PostgreSQL connection
- Redis pub/sub

### Frontend (Port 3000)
- React + Vite dev server
- Connects to backend API
- Real-time WebSocket updates

### Worker (Background)
- Processes pipeline runs
- Simulates build steps
- Publishes logs to Redis

### Jenkins (Port 8080)
- First startup takes 1-2 minutes
- Initial admin password at: `C:\Users\YOUR_USERNAME\.jenkins\secrets\initialAdminPassword`
- Install suggested plugins

---

## 📝 First Time Jenkins Setup

1. **Access Jenkins**: http://localhost:8080

2. **Unlock Jenkins**
```powershell
# Get initial admin password
Get-Content "$env:USERPROFILE\.jenkins\secrets\initialAdminPassword"
```

3. **Install plugins**:
   - Click "Install suggested plugins"
   - Wait for installation

4. **Create admin user**:
   - Username: `admin`
   - Password: `admin123`
   - Email: your@email.com

5. **Jenkins URL**: http://localhost:8080

---

## 🎯 Test the Setup

### Test 1: Backend Health
```powershell
curl http://localhost:4000/health
```

Expected: `{"status":"ok"}`

### Test 2: Database Connection
```powershell
# Check pipelines
curl http://localhost:4000/api/pipelines
```

Expected: JSON array with sample pipeline

### Test 3: Create a Test Run
```powershell
curl -X POST http://localhost:4000/api/runs `
  -H "Content-Type: application/json" `
  -d '{\"pipelineId\": 1, \"triggeredBy\": \"manual\"}'
```

### Test 4: View Dashboard
- Open: http://localhost:3000
- You should see the pipeline run appear!

---

## 🐛 Troubleshooting

### PostgreSQL Connection Error

```powershell
# Check if PostgreSQL is running
Get-Service postgresql*

# Start if stopped
Start-Service postgresql-x64-15
```

### Redis Connection Error

```powershell
# Check Memurai service
Get-Service Memurai

# Start if stopped
Start-Service Memurai
```

### Port Already in Use

```powershell
# Find what's using port 4000
netstat -ano | findstr :4000

# Kill the process (replace PID)
taskkill /PID <PID> /F
```

### Jenkins Won't Start

```powershell
# Check Java installation
java -version

# Try running with more memory
java -Xmx2g -jar C:\Jenkins\jenkins.war --httpPort=8080
```

### Module Not Found Errors

```powershell
# Reinstall dependencies
cd backend
Remove-Item -Recurse -Force node_modules
npm install

# Repeat for frontend and worker
```

---

## 🎨 Making Life Easier

### Create Master Startup Script

I'll create a script that starts everything in separate windows!

---

## 📚 Next Steps

1. ✅ All services installed
2. ⬜ Create GitHub repository
3. ⬜ Configure Jenkins pipeline
4. ⬜ Test end-to-end flow

See **SETUP-JENKINS-GITHUB.md** for Jenkins integration!

---

## 💡 Tips

1. **Use Windows Terminal** for better experience:
   - Download from Microsoft Store
   - Can split panes for multiple services

2. **Create batch files** for quick startup:
   - One click to start all services

3. **Use VS Code** for development:
   - Integrated terminal
   - Can run all services in one window

4. **Set services to auto-start**:
   - PostgreSQL and Redis run as Windows Services
   - Start automatically with Windows

---

## 🔄 Stopping Services

```powershell
# In each terminal, press Ctrl+C

# Or kill all Node processes
Get-Process node | Stop-Process -Force

# Stop Jenkins
# Just close the terminal or Ctrl+C
```

---

## 📦 What Each Service Does

| Service | Purpose | Port | Required |
|---------|---------|------|----------|
| PostgreSQL | Stores pipeline/run/step data | 5432 | ✅ Yes |
| Redis | Real-time pub/sub messaging | 6379 | ✅ Yes |
| Backend | REST API + WebSocket | 4000 | ✅ Yes |
| Worker | Executes pipeline runs | - | ✅ Yes |
| Frontend | React UI | 3000 | ✅ Yes |
| Jenkins | CI/CD automation | 8080 | ⬜ Optional |

---

Need help? All services have logs showing what's happening!
