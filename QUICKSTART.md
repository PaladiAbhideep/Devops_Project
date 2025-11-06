# Quick Start Guide

## 🚀 Get Started in 3 Steps

### Step 1: Start the Application
```powershell
cd "C:\Users\tests\Downloads\cicd project"
docker-compose up -d
```

Wait for all services to start (about 30-60 seconds).

### Step 2: Access the Dashboard
Open your browser and go to: **http://localhost:3000**

### Step 3: Run Your First Pipeline
1. Click one of the pipeline buttons in the header (e.g., "Build and Test")
2. Watch the pipeline stages update in real-time
3. View live logs streaming in the logs panel

## 🎯 What You'll See

### Main Dashboard
- **Left Sidebar**: List of recent pipeline runs
- **Right Panel**: Selected run details with:
  - Pipeline stages visualization
  - Real-time step status updates
  - Live streaming logs

### Status Colors
- 🔵 **Blue** = Running
- 🟢 **Green** = Success
- 🔴 **Red** = Failed
- 🟡 **Yellow** = Cancelled
- ⚪ **Gray** = Pending/Queued

## 🛠️ Common Tasks

### View All Runs
Runs appear automatically in the left sidebar. Click any run to see details.

### Cancel a Running Pipeline
1. Select a running pipeline
2. Click the **Cancel** button in the top-right

### Rerun a Pipeline
1. Select any completed run
2. Click the **Rerun** button to execute it again

### Filter Runs (API)
```powershell
# Get only successful runs
curl "http://localhost:4000/api/runs?status=success"

# Get runs for specific branch
curl "http://localhost:4000/api/runs?branch=main"
```

## 📋 Sample Pipelines Included

1. **Build and Test** - 3 stages, 7 steps
2. **Quick Build** - 1 stage, 2 steps  
3. **Full CI/CD Pipeline** - 5 stages, 15 steps

## 🔍 Monitoring

### Check Service Health
```powershell
# Backend health
curl http://localhost:4000/health

# View logs
docker-compose logs -f
```

### Verify Services Running
```powershell
docker-compose ps
```

All services should show "Up" status.

## 🛑 Stopping the Application

```powershell
# Stop services (keeps data)
docker-compose down

# Stop and remove all data
docker-compose down -v
```

## 💡 Tips

- **Auto-refresh**: The runs list refreshes every 5 seconds
- **WebSocket**: Green indicator shows real-time connection status
- **Log streaming**: Logs appear as the pipeline executes
- **Concurrent runs**: You can start multiple pipelines simultaneously

## ❓ Troubleshooting

### Services not starting?
```powershell
docker-compose down
docker-compose up -d
```

### Can't access frontend?
- Check: http://localhost:3000
- Verify Docker container is running: `docker-compose ps`

### No logs appearing?
- Check WebSocket connection (green indicator in header)
- Verify backend is running: `curl http://localhost:4000/health`

## 📚 Next Steps

- Read the full [README.md](README.md) for detailed documentation
- Explore the API at http://localhost:4000/api
- Customize pipeline templates in the database
- Check worker logs to see simulation details

---

**Need help? Check the full README or open an issue!**
