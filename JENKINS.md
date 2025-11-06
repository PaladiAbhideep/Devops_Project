# Jenkins Integration Guide

## 📖 Overview

This CI/CD Pipeline Dashboard is now integrated with **Jenkins** to run real pipelines triggered by GitHub repositories. Jenkins executes the actual build/test/deploy steps and sends real-time updates to the dashboard.

## 🏗️ Architecture

```
GitHub Repository
       ↓ (push/webhook)
   Jenkins Server
       ↓ (executes Jenkinsfile)
   Pipeline Stages
       ↓ (API calls)
   Dashboard Backend
       ↓ (WebSocket)
   Dashboard Frontend
```

## 🚀 Quick Start

### 1. Start All Services

```powershell
cd "C:\Users\tests\Downloads\cicd project"
docker-compose up -d
```

This will start:
- PostgreSQL (Database)
- Redis (Pub/Sub)
- Backend (API + WebSocket)
- Worker (Simulator - optional now)
- Frontend (Dashboard UI)
- **Jenkins** (CI/CD Server)

### 2. Access Jenkins

**URL**: http://localhost:8080

**Default Credentials**:
- Username: `admin`
- Password: `admin123`

### 3. Verify Setup

1. Jenkins should be running at http://localhost:8080
2. Sample pipeline job should be created: "sample-pipeline"
3. Dashboard is accessible at http://localhost:3000

## 🔧 Configuration

### Jenkins Auto-Configuration

Jenkins is pre-configured with:
- ✅ Admin user (admin/admin123)
- ✅ Required plugins installed
- ✅ Sample pipeline job
- ✅ GitHub integration ready
- ✅ Dashboard API connection

Configuration files:
- `jenkins/casc.yaml` - Configuration as Code
- `jenkins/plugins.txt` - Plugin list
- `jenkins/init.groovy.d/` - Initialization scripts

### Environment Variables

Jenkins has access to:
- `DASHBOARD_API_URL` - Points to backend API (http://backend:4000)

## 📝 Setting Up a GitHub Repository

### 1. Create/Use a GitHub Repository

You need a GitHub repository with:
- A `Jenkinsfile` in the root (or use the one provided in this project)
- A Node.js project (package.json) - or any project type

### 2. Add Jenkinsfile to Your Repo

Copy the `Jenkinsfile` from this project to your repository root:

```powershell
# Copy Jenkinsfile to your repo
copy Jenkinsfile "path\to\your\repo\Jenkinsfile"
cd "path\to\your\repo"
git add Jenkinsfile
git commit -m "Add Jenkinsfile for CI/CD pipeline"
git push
```

### 3. Create Jenkins Pipeline Job

**Option A: Using Jenkins UI**

1. Open Jenkins: http://localhost:8080
2. Click "New Item"
3. Enter name: `my-project-pipeline`
4. Select "Pipeline" and click OK
5. Under "Pipeline" section:
   - Definition: "Pipeline script from SCM"
   - SCM: Git
   - Repository URL: `https://github.com/your-username/your-repo.git`
   - Branch: `*/main` (or your default branch)
   - Script Path: `Jenkinsfile`
6. Click "Save"

**Option B: Using Job DSL (Automated)**

Edit `jenkins/casc.yaml` and update the GitHub URL:

```yaml
branchSources {
  git {
    remote('https://github.com/YOUR-USERNAME/YOUR-REPO.git')
  }
}
```

Then restart Jenkins:
```powershell
docker-compose restart jenkins
```

### 4. Configure GitHub Webhooks (Optional but Recommended)

For automatic builds on push:

1. Go to your GitHub repository
2. Settings → Webhooks → Add webhook
3. Payload URL: `http://YOUR-PUBLIC-IP:8080/github-webhook/`
4. Content type: `application/json`
5. Events: Select "Just the push event"
6. Click "Add webhook"

**Note**: For local testing, use a service like ngrok:
```powershell
ngrok http 8080
# Use the ngrok URL for webhook
```

## 🎮 Running Your First Pipeline

### Method 1: Manual Trigger

1. Open Jenkins: http://localhost:8080
2. Click on your pipeline job
3. Click "Build Now"
4. Open Dashboard: http://localhost:3000
5. Watch the pipeline execute in real-time!

### Method 2: GitHub Push

```powershell
cd your-repo
# Make any change
echo "test" >> README.md
git add README.md
git commit -m "Trigger pipeline"
git push
```

Watch the pipeline automatically start in both Jenkins and the Dashboard!

### Method 3: API Trigger

```powershell
# Trigger via Dashboard API
curl -X POST http://localhost:4000/api/runs `
  -H "Content-Type: application/json" `
  -d '{\"pipelineId\": 1, \"repo\": \"your-repo\", \"branch\": \"main\", \"triggeredBy\": \"manual\"}'
```

## 📊 Understanding the Jenkinsfile

The provided `Jenkinsfile` includes:

### Stages

1. **Initialize** - Set up environment, create dashboard run
2. **Checkout** - Clone repository
3. **Install Dependencies** - Run `npm install`
4. **Build** - Run `npm run build`
5. **Test** - Run `npm test`
6. **Lint** - Run `npm run lint`
7. **Security Scan** - Run `npm audit`
8. **Package** - Create deployment artifact
9. **Deploy** - Deploy to staging (main branch only)

### Dashboard Integration

The Jenkinsfile automatically:
- Creates a run in the dashboard
- Updates step status in real-time
- Sends logs to the dashboard
- Updates final run status (success/failed)

### Helper Functions

```groovy
createDashboardRun()       // Creates new run
updateDashboardRun(status) // Updates run status
updateDashboardStep(name, status) // Updates step status
```

## 🔌 API Endpoints

### Jenkins-Specific Endpoints

```
POST /api/jenkins/runs/:runId/status
  - Update run status from Jenkins
  Body: { status, timestamp, jenkinsUrl }

POST /api/jenkins/steps
  - Create/update pipeline step
  Body: { runId, stepName, status, stage, timestamp }

POST /api/jenkins/logs
  - Send log message
  Body: { runId, stepName, level, message, timestamp }

POST /api/jenkins/webhook
  - Receive GitHub webhooks
  Body: GitHub webhook payload

GET /api/jenkins/health
  - Health check
```

## 🛠️ Customizing Your Pipeline

### Add Custom Stages

Edit your `Jenkinsfile`:

```groovy
stage('Custom Stage') {
    steps {
        script {
            updateDashboardStep('Custom Stage', 'running')
        }
        
        sh '''
            echo "Running custom commands..."
            # Your commands here
        '''
        
        script {
            updateDashboardStep('Custom Stage', 'success')
        }
    }
}
```

### Add Notifications

```groovy
post {
    success {
        emailext (
            to: 'team@example.com',
            subject: "Pipeline Success: ${env.JOB_NAME}",
            body: "Build ${env.BUILD_NUMBER} completed successfully"
        )
    }
}
```

### Add Docker Build

```groovy
stage('Docker Build') {
    steps {
        script {
            updateDashboardStep('Docker Build', 'running')
            docker.build("myapp:${env.BUILD_NUMBER}")
            updateDashboardStep('Docker Build', 'success')
        }
    }
}
```

## 🔍 Monitoring & Debugging

### View Jenkins Logs

```powershell
# Jenkins container logs
docker-compose logs -f jenkins

# Specific build logs
# Access via Jenkins UI: http://localhost:8080
```

### View Dashboard Logs

```powershell
# Backend logs (API calls from Jenkins)
docker-compose logs -f backend

# Check if Jenkins webhook reached backend
docker-compose logs backend | grep jenkins
```

### Database Queries

```sql
-- View runs triggered by Jenkins
SELECT * FROM runs WHERE triggered_by LIKE 'jenkins%';

-- View Jenkins-specific metadata
SELECT id, meta->>'jenkinsUrl' as jenkins_url 
FROM runs 
WHERE meta ? 'jenkinsUrl';
```

## 🚨 Troubleshooting

### Jenkins Can't Reach Dashboard API

**Problem**: Jenkins shows errors connecting to dashboard

**Solution**:
```powershell
# Verify backend is running
docker-compose ps backend

# Check network connectivity
docker-compose exec jenkins ping backend

# Verify environment variable
docker-compose exec jenkins env | grep DASHBOARD_API
```

### Pipeline Not Creating Dashboard Run

**Problem**: Jenkins runs but doesn't appear in dashboard

**Check**:
1. Verify Jenkinsfile has `createDashboardRun()` in Initialize stage
2. Check backend logs for API errors
3. Verify `DASHBOARD_API` environment variable in Jenkins

### GitHub Webhook Not Working

**Problem**: Push to GitHub doesn't trigger Jenkins

**Solutions**:
1. Check webhook delivery in GitHub Settings
2. Verify Jenkins URL is publicly accessible
3. Check Jenkins has GitHub plugin installed
4. Review webhook payload in GitHub

### Permissions Issues

**Problem**: Jenkins can't execute Docker commands

**Solution**:
```powershell
# Jenkins runs as root in container
# Docker socket is mounted
# If issues persist, check socket permissions
docker-compose exec jenkins ls -l /var/run/docker.sock
```

## 📚 Advanced Topics

### Multi-Branch Pipelines

Configure automatic pipeline for each branch:

```groovy
// In casc.yaml
multibranchPipelineJob('my-project') {
  branchSources {
    git {
      remote('https://github.com/user/repo.git')
    }
  }
}
```

### Parallel Execution

Run stages in parallel:

```groovy
stage('Parallel Tests') {
    parallel {
        stage('Unit Tests') {
            steps { /* ... */ }
        }
        stage('Integration Tests') {
            steps { /* ... */ }
        }
    }
}
```

### Credentials Management

Add credentials in Jenkins UI or via CasC:

```yaml
credentials:
  system:
    domainCredentials:
      - credentials:
          - string:
              scope: GLOBAL
              id: "github-token"
              secret: "${GITHUB_TOKEN}"
```

### Custom Plugins

Add to `jenkins/plugins.txt`:

```
email-ext:latest
slack:latest
docker-workflow:latest
```

## 🔐 Security Best Practices

### Change Default Password

1. Edit `jenkins/casc.yaml`
2. Change admin password
3. Restart Jenkins

```yaml
users:
  - id: "admin"
    password: "YOUR-SECURE-PASSWORD"
```

### Use Credentials for GitHub

Don't hardcode tokens in Jenkinsfile:

```groovy
withCredentials([string(credentialsId: 'github-token', variable: 'GITHUB_TOKEN')]) {
    sh 'git clone https://${GITHUB_TOKEN}@github.com/user/repo.git'
}
```

### Enable HTTPS

For production:
1. Configure reverse proxy (nginx)
2. Add SSL certificate
3. Update webhook URLs

## 📈 Performance Optimization

### Resource Limits

Edit `docker-compose.yml`:

```yaml
jenkins:
  deploy:
    resources:
      limits:
        cpus: '2'
        memory: 4G
```

### Build Caching

Use Docker layer caching:

```groovy
docker.build("myapp", "--cache-from myapp:latest .")
```

### Cleanup Old Builds

Automatic cleanup configured in Jenkinsfile:

```groovy
options {
    buildDiscarder(logRotator(numToKeepStr: '10'))
}
```

## 🎯 Next Steps

1. ✅ Start Jenkins and verify it's running
2. ✅ Create a pipeline job for your GitHub repo
3. ✅ Push code and watch it build automatically
4. ✅ Monitor builds in the Dashboard
5. ⬜ Add GitHub webhooks for instant triggers
6. ⬜ Customize pipeline for your project needs
7. ⬜ Add tests and quality gates
8. ⬜ Configure deployment to your environment

## 📞 Support

**Documentation**:
- Jenkins Official: https://www.jenkins.io/doc/
- Pipeline Syntax: https://www.jenkins.io/doc/book/pipeline/syntax/
- Dashboard API: See DEVELOPMENT.md

**Common Issues**:
- Check docker-compose logs
- Verify network connectivity
- Review Jenkins console output
- Check database for run records

---

**Congratulations! Your CI/CD Dashboard is now powered by real Jenkins pipelines! 🎉**
