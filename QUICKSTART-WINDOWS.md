# Quick Start Guide - Windows (No Docker)

## 🚀 Super Quick Start (5 Steps)

### Step 1: Install Software (One-Time Setup - 30 minutes)

**Download and install these:**

1. **Node.js** - https://nodejs.org/ (LTS version)
2. **PostgreSQL** - https://www.postgresql.org/download/windows/ (v15+)
3. **Memurai** (Redis for Windows) - https://www.memurai.com/get-memurai

### Step 2: Setup Database (One-Time - 2 minutes)

Open PowerShell and run:

```powershell
# Connect to PostgreSQL
psql -U postgres

# Password: (enter your postgres password)
```

In psql, run:

```sql
# Create database
CREATE DATABASE cicd_dashboard;

# Exit
\q
```

Then run setup script:

```powershell
cd "C:\Users\tests\Downloads\cicd project"
psql -U postgres -d cicd_dashboard -f setup-database.sql
```

### Step 3: Start Everything (30 seconds)

```powershell
cd "C:\Users\tests\Downloads\cicd project"
.\START-WINDOWS.ps1
```

That's it! The script will:
- ✅ Check all prerequisites
- ✅ Install npm dependencies
- ✅ Create .env files
- ✅ Start all services
- ✅ Open your browser

### Step 4: Access Dashboard

Open in browser: **http://localhost:3000**

### Step 5: Test It!

**Option 1: Use the Dashboard**
- Click "Trigger Run" button

**Option 2: Use PowerShell**
```powershell
curl -X POST http://localhost:4000/api/runs `
  -H "Content-Type: application/json" `
  -d '{\"pipelineId\": 1, \"triggeredBy\": \"manual\"}'
```

Watch the pipeline run in real-time! 🎉

---

## 📋 What You Get

| Service | URL | Status |
|---------|-----|--------|
| **Dashboard** | http://localhost:3000 | ✅ |
| **Backend API** | http://localhost:4000 | ✅ |
| **Health Check** | http://localhost:4000/health | ✅ |
| **Pipelines API** | http://localhost:4000/api/pipelines | ✅ |

---

## 🛠️ Manual Steps (If Script Fails)

### Start Backend
```powershell
cd "C:\Users\tests\Downloads\cicd project\backend"
.\start-backend.ps1
```

### Start Worker
```powershell
cd "C:\Users\tests\Downloads\cicd project\worker"
.\start-worker.ps1
```

### Start Frontend
```powershell
cd "C:\Users\tests\Downloads\cicd project\frontend"
.\start-frontend.ps1
```

---

## 🐛 Troubleshooting

### "Cannot be loaded because running scripts is disabled"

Run this in PowerShell as Administrator:
```powershell
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### "PostgreSQL service not found"

Start PostgreSQL manually:
```powershell
Start-Service postgresql-x64-15
```

### "Memurai service not found"

Either:
1. Install Memurai from https://www.memurai.com/get-memurai
2. Or use WSL with Redis (see SETUP-WINDOWS-NO-DOCKER.md)

### "Port 4000 already in use"

Kill the process:
```powershell
$process = Get-NetTCPConnection -LocalPort 4000 -ErrorAction SilentlyContinue
if ($process) {
    Stop-Process -Id $process.OwningProcess -Force
}
```

### Database connection error

1. Check PostgreSQL is running:
```powershell
Get-Service postgresql*
```

2. Verify credentials in `backend/.env`:
```
DB_PASSWORD=your_postgres_password
```

3. Test connection:
```powershell
psql -U postgres -d cicd_dashboard -c "SELECT 1;"
```

---

## 🔄 Stop All Services

**Option 1: Close the windows**
- Close the 3 PowerShell windows that opened

**Option 2: Kill all Node processes**
```powershell
Get-Process node | Stop-Process -Force
```

---

## 📚 Full Documentation

- **Complete Setup Guide**: `SETUP-WINDOWS-NO-DOCKER.md`
- **Project Overview**: `README.md`
- **Development Guide**: `DEVELOPMENT.md`

---

## 💡 Tips

1. **Use Windows Terminal** for better experience
   - Download from Microsoft Store
   - Can split panes

2. **First time?** Setup takes ~30 minutes
   - After that, starting is < 1 minute!

3. **PostgreSQL & Redis** run as Windows Services
   - Start automatically with Windows
   - No need to start them manually

4. **Keep terminals open**
   - Each service runs in its own window
   - You can see logs in real-time

---

## ✅ Success Checklist

- [ ] Node.js installed
- [ ] PostgreSQL installed & running
- [ ] Memurai/Redis installed & running
- [ ] Database created (`cicd_dashboard`)
- [ ] Tables created (ran `setup-database.sql`)
- [ ] Ran `START-WINDOWS.ps1`
- [ ] 3 PowerShell windows opened
- [ ] Dashboard accessible at http://localhost:3000
- [ ] Created a test pipeline run
- [ ] Saw real-time updates! 🎉

---

## 🎓 Next Steps

1. ✅ Basic setup complete
2. ⬜ Explore the dashboard
3. ⬜ Create custom pipelines
4. ⬜ Install Jenkins (optional)
5. ⬜ Connect GitHub repository

See `SETUP-JENKINS-GITHUB.md` for Jenkins integration!

---

## 📞 Need Help?

Check the detailed guide: **SETUP-WINDOWS-NO-DOCKER.md**

It has:
- Step-by-step screenshots
- Detailed troubleshooting
- Alternative methods
- Configuration options

---

**You're ready to build! 🚀**
