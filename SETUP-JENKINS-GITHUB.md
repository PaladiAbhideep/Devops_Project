# Jenkins + GitHub Integration - Complete Setup Guide

## 🎯 What You'll Achieve

By following this guide, you'll have:
- ✅ Jenkins running and integrated with the dashboard
- ✅ A GitHub repository monitored by Jenkins
- ✅ Automatic builds triggered by code pushes
- ✅ Real-time build status in the dashboard

## 📋 Prerequisites

- Docker Desktop installed and running
- GitHub account
- Git installed locally
- Text editor (VS Code recommended)

## 🚀 Step-by-Step Setup

### Part 1: Start the Services (5 minutes)

1. **Navigate to project directory**
```powershell
cd "C:\Users\tests\Downloads\cicd project"
```

2. **Start all services**
```powershell
docker-compose up -d
```

3. **Wait for services to start** (30-60 seconds)
```powershell
# Watch the logs
docker-compose logs -f

# Or check status
docker-compose ps
```

4. **Verify services are running**
- ✅ Dashboard: http://localhost:3000
- ✅ Backend API: http://localhost:4000/health
- ✅ Jenkins: http://localhost:8080

### Part 2: Setup Jenkins (5 minutes)

1. **Access Jenkins**
   - Open: http://localhost:8080
   - Login: `admin` / `admin123`

2. **Verify Jenkins is configured**
   - You should see: "CI/CD Pipeline Dashboard - Jenkins Integration"
   - Sample pipeline job should be visible

3. **Test the sample pipeline**
   - Click "sample-pipeline"
   - Click "Build Now"
   - Open Dashboard: http://localhost:3000
   - Watch the build appear in real-time! 🎉

### Part 3: Create GitHub Repository (10 minutes)

#### Option A: Use the Sample Project (Quickest)

1. **Create a new GitHub repository**
   - Go to: https://github.com/new
   - Name: `cicd-dashboard-test` (or any name)
   - Visibility: Public
   - Don't initialize with README
   - Click "Create repository"

2. **Push sample project to GitHub**
```powershell
cd "C:\Users\tests\Downloads\cicd project\sample-project"

git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/YOUR-USERNAME/cicd-dashboard-test.git
git push -u origin main
```

3. **Copy Jenkinsfile**
```powershell
# Copy the Jenkinsfile to your sample project
copy "..\Jenkinsfile" "Jenkinsfile"
git add Jenkinsfile
git commit -m "Add Jenkinsfile"
git push
```

#### Option B: Use Your Existing Project

1. **Add Jenkinsfile to your project**
```powershell
cd "path\to\your\project"

# Copy our Jenkinsfile
copy "C:\Users\tests\Downloads\cicd project\Jenkinsfile" "Jenkinsfile"

git add Jenkinsfile
git commit -m "Add CI/CD pipeline"
git push
```

### Part 4: Configure Jenkins Job (5 minutes)

1. **Create new Pipeline job**
   - Open Jenkins: http://localhost:8080
   - Click "New Item"
   - Name: `github-project`
   - Type: "Pipeline"
   - Click "OK"

2. **Configure pipeline**

   **General Section:**
   - ✅ Check "GitHub project"
   - Project URL: `https://github.com/YOUR-USERNAME/YOUR-REPO`

   **Build Triggers:**
   - ✅ Check "Poll SCM"
   - Schedule: `H/5 * * * *` (poll every 5 minutes)
   - For webhooks: ✅ Check "GitHub hook trigger for GITScm polling"

   **Pipeline Section:**
   - Definition: "Pipeline script from SCM"
   - SCM: "Git"
   - Repository URL: `https://github.com/YOUR-USERNAME/YOUR-REPO.git`
   - Branch Specifier: `*/main` (or your default branch)
   - Script Path: `Jenkinsfile`

3. **Save the configuration**

4. **Test it!**
   - Click "Build Now"
   - Watch build in Jenkins console
   - See it appear in Dashboard: http://localhost:3000
   - Real-time logs streaming! 🔥

### Part 5: Setup GitHub Webhooks (Optional - 10 minutes)

For instant builds (not just polling):

#### If Jenkins is Publicly Accessible:

1. **Get your Jenkins URL**
   - Production: `https://your-jenkins-domain.com`
   - Development: Use ngrok (see below)

2. **Configure GitHub webhook**
   - Go to your GitHub repo
   - Settings → Webhooks → Add webhook
   - Payload URL: `http://YOUR-JENKINS-URL:8080/github-webhook/`
   - Content type: `application/json`
   - Events: "Just the push event"
   - Active: ✅
   - Click "Add webhook"

#### For Local Development (Using ngrok):

1. **Install ngrok**
```powershell
# Download from: https://ngrok.com/download
# Or use chocolatey:
choco install ngrok
```

2. **Start ngrok**
```powershell
ngrok http 8080
```

3. **Copy ngrok URL**
   - Example: `https://abc123.ngrok.io`

4. **Add webhook in GitHub**
   - Payload URL: `https://abc123.ngrok.io/github-webhook/`
   - Content type: `application/json`
   - Events: "Just the push event"
   - Click "Add webhook"

5. **Test webhook**
```powershell
# Make a change
echo "test" >> README.md
git add README.md
git commit -m "Test webhook"
git push
```

Watch the build start automatically in Jenkins AND the dashboard! 🚀

## 🎮 Usage

### Trigger Builds

**Method 1: Push to GitHub**
```powershell
# Make any change
echo "# Test" >> README.md
git add .
git commit -m "Trigger build"
git push
```

**Method 2: Manual in Jenkins**
- Open Jenkins
- Click your job
- Click "Build Now"

**Method 3: Dashboard API**
```powershell
curl -X POST http://localhost:4000/api/runs `
  -H "Content-Type: application/json" `
  -d '{\"pipelineId\": 1, \"repo\": \"your-repo\", \"branch\": \"main\", \"triggeredBy\": \"api\"}'
```

### Monitor Builds

**Jenkins Console:**
- http://localhost:8080/job/github-project/

**Dashboard:**
- http://localhost:3000
- Real-time updates
- Live logs
- Visual pipeline stages

## 🎯 What Happens in a Build

1. **GitHub**: You push code
2. **Jenkins**: Detects change (webhook or polling)
3. **Jenkins**: Starts build, executes Jenkinsfile
4. **Jenkinsfile**: Calls Dashboard API
5. **Dashboard**: Creates run record
6. **Jenkins**: Executes stages (Checkout, Build, Test, etc.)
7. **Jenkinsfile**: Updates Dashboard after each step
8. **Dashboard**: Shows live progress via WebSocket
9. **Frontend**: You see real-time updates! 🎉

## 🔍 Verify Everything Works

### Checklist:

- [ ] All services running: `docker-compose ps`
- [ ] Dashboard accessible: http://localhost:3000
- [ ] Backend healthy: http://localhost:4000/health
- [ ] Jenkins accessible: http://localhost:8080
- [ ] Sample pipeline exists in Jenkins
- [ ] GitHub repo created
- [ ] Jenkinsfile in repo
- [ ] Jenkins job configured
- [ ] Build triggered successfully
- [ ] Build appears in Dashboard
- [ ] Logs stream in real-time

### Test Commands:

```powershell
# Check all containers
docker-compose ps

# Check backend logs
docker-compose logs backend | Select-String -Pattern "jenkins"

# Check Jenkins logs
docker-compose logs jenkins | Select-String -Pattern "SUCCESS"

# Test API
curl http://localhost:4000/api/jenkins/health
```

## 🐛 Troubleshooting

### Services Won't Start

```powershell
# Stop everything
docker-compose down

# Remove volumes
docker-compose down -v

# Start fresh
docker-compose up -d

# Watch logs
docker-compose logs -f
```

### Jenkins Can't Access Dashboard

```powershell
# Check network connectivity
docker-compose exec jenkins ping backend

# Check environment variable
docker-compose exec jenkins env | grep DASHBOARD

# Restart backend
docker-compose restart backend
```

### Build Doesn't Appear in Dashboard

1. Check Jenkins console output for errors
2. Verify `DASHBOARD_API_URL` in Jenkins
3. Check backend logs: `docker-compose logs backend`
4. Verify Jenkinsfile has API calls

### GitHub Webhook Not Working

1. Check webhook deliveries in GitHub Settings
2. Verify webhook URL is accessible
3. Check Jenkins logs for webhook events
4. For local: verify ngrok is running

### Permission Errors

```powershell
# Windows: Run PowerShell as Administrator
# Or give Docker permissions to your user

# Check Docker is running
docker ps

# Restart Docker Desktop
```

## 📚 Next Steps

### Beginner:
1. ✅ Complete this setup
2. ⬜ Run your first build
3. ⬜ Watch logs in dashboard
4. ⬜ Make a code change and push

### Intermediate:
1. ⬜ Customize Jenkinsfile for your project
2. ⬜ Add more stages (deploy, integration tests)
3. ⬜ Configure GitHub webhooks
4. ⬜ Add environment-specific configs

### Advanced:
1. ⬜ Multi-branch pipeline
2. ⬜ Parallel stage execution
3. ⬜ Docker builds in pipeline
4. ⬜ Deploy to production
5. ⬜ Add Slack/Email notifications

## 📖 Documentation

- **Jenkins Integration**: [JENKINS.md](JENKINS.md)
- **Full Documentation**: [README.md](README.md)
- **Development Guide**: [DEVELOPMENT.md](DEVELOPMENT.md)
- **Quick Start**: [QUICKSTART.md](QUICKSTART.md)

## 🎓 Learn More

- Jenkins Pipeline Syntax: https://www.jenkins.io/doc/book/pipeline/syntax/
- GitHub Webhooks: https://docs.github.com/en/webhooks
- Docker Compose: https://docs.docker.com/compose/

## 💡 Tips

1. **Use Blue Ocean UI** for prettier Jenkins interface:
   - http://localhost:8080/blue

2. **View build artifacts** in Jenkins:
   - Each build saves `application.tar.gz`

3. **Clean workspace** between builds:
   - Already configured in Jenkinsfile

4. **Use build parameters** for flexibility:
   - Add to Jenkinsfile: `parameters { ... }`

5. **Monitor from mobile**:
   - Dashboard is responsive!

## 🎉 Success!

If you made it here, you now have:
- ✅ Full CI/CD pipeline running
- ✅ Jenkins executing real builds
- ✅ GitHub integration working
- ✅ Real-time monitoring dashboard
- ✅ Production-ready setup

**Congratulations! You're ready to build amazing things! 🚀**

---

Need help? Check the documentation or review the logs!
