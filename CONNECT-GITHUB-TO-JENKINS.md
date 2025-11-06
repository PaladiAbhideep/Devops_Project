# Connect GitHub Repository to Jenkins - Complete Guide

## 🎯 Goal
Connect your GitHub repository (https://github.com/PaladiAbhideep/Devops_Project) to Jenkins to automatically build and run your CI/CD pipeline.

---

## 📋 Prerequisites

Before starting, ensure you have:
- ✅ Jenkins running at http://localhost:8080
- ✅ GitHub repository: https://github.com/PaladiAbhideep/Devops_Project
- ✅ Git installed on Windows
- ✅ Backend, Frontend, Worker services running (for API integration)

---

## 🚀 Step-by-Step Setup

### Step 1: Install Jenkins (If Not Already Installed)

#### Download and Setup Jenkins

1. **Install Java JDK 17**
```powershell
# Download from: https://adoptium.net/
# After installation, verify:
java -version
```

2. **Download Jenkins**
```powershell
# Create Jenkins directory
mkdir C:\Jenkins
cd C:\Jenkins

# Download Jenkins WAR file
Invoke-WebRequest -Uri "https://get.jenkins.io/war-stable/latest/jenkins.war" -OutFile "jenkins.war"
```

3. **Start Jenkins**
```powershell
cd C:\Jenkins
java -jar jenkins.war --httpPort=8080
```

Wait for: `Jenkins is fully up and running`

4. **Access Jenkins**
- Open browser: http://localhost:8080
- Get initial admin password:
```powershell
Get-Content "C:\Jenkins\jenkins_home\secrets\initialAdminPassword"
```

5. **Complete Setup**
- Paste admin password
- Click "Install suggested plugins"
- Create admin user (username: `admin`, password: `admin123`)
- Save Jenkins URL: http://localhost:8080

---

### Step 2: Install Required Jenkins Plugins

1. **Go to Plugin Manager**
   - Dashboard → "Manage Jenkins" → "Plugins"
   - Click "Available plugins"

2. **Search and Install These Plugins:**
   - ✅ **Git** (for Git integration)
   - ✅ **GitHub** (for GitHub integration)
   - ✅ **Pipeline** (for Jenkinsfile support)
   - ✅ **HTTP Request Plugin** (for calling Dashboard API)
   - ✅ **Credentials Binding** (for secure credentials)

3. **Install Plugins**
   - Check all the boxes
   - Click "Install without restart"
   - Wait for installation to complete

---

### Step 3: Configure Git in Jenkins

1. **Set Git Path (if needed)**
   - Go to: "Manage Jenkins" → "Tools"
   - Scroll to "Git"
   - Add Git installation:
     - Name: `Default`
     - Path to Git executable: `C:\Program Files\Git\bin\git.exe`
   - Click "Save"

---

### Step 4: Create GitHub Credentials in Jenkins

#### Option A: Using GitHub Personal Access Token (Recommended)

1. **Create GitHub Personal Access Token**
   - Go to: https://github.com/settings/tokens
   - Click "Generate new token" → "Generate new token (classic)"
   - Name: `Jenkins CI/CD`
   - Expiration: Choose duration (90 days recommended)
   - Scopes: Check **`repo`** (all sub-items)
   - Click "Generate token"
   - **Copy the token** (you won't see it again!)

2. **Add Token to Jenkins**
   - In Jenkins: "Manage Jenkins" → "Credentials"
   - Click "(global)" under "Stores scoped to Jenkins"
   - Click "Add Credentials"
   - Fill in:
     - Kind: **"Username with password"**
     - Scope: `Global`
     - Username: `PaladiAbhideep` (your GitHub username)
     - Password: `<paste your GitHub token>`
     - ID: `github-credentials`
     - Description: `GitHub Personal Access Token`
   - Click "Create"

#### Option B: Using SSH Key (Alternative)

1. **Generate SSH Key**
```powershell
# Generate new SSH key
ssh-keygen -t rsa -b 4096 -C "your.email@example.com"
# Save to: C:\Users\YOUR_USERNAME\.ssh\id_rsa
# Leave passphrase empty for automation

# Copy public key
Get-Content "$env:USERPROFILE\.ssh\id_rsa.pub"
```

2. **Add Public Key to GitHub**
   - Go to: https://github.com/settings/keys
   - Click "New SSH key"
   - Title: `Jenkins Server`
   - Paste the public key
   - Click "Add SSH key"

3. **Add Private Key to Jenkins**
   - In Jenkins: "Manage Jenkins" → "Credentials"
   - Click "Add Credentials"
   - Fill in:
     - Kind: **"SSH Username with private key"**
     - ID: `github-ssh`
     - Username: `git`
     - Private Key: Click "Enter directly" → Paste private key content
   - Click "Create"

---

### Step 5: Create Jenkins Pipeline Job

1. **Create New Job**
   - Jenkins Dashboard → "New Item"
   - Enter name: `Devops_Project_Pipeline`
   - Select: **"Pipeline"**
   - Click "OK"

2. **Configure General Settings**
   - Description: `CI/CD Pipeline for DevOps Project from GitHub`
   - ✅ Check "GitHub project"
   - Project URL: `https://github.com/PaladiAbhideep/Devops_Project/`

3. **Configure Build Triggers**

   Choose one or both:

   **Option A: Poll SCM (Check for changes every 5 minutes)**
   - ✅ Check "Poll SCM"
   - Schedule: `H/5 * * * *`
     - This checks GitHub every 5 minutes for new commits

   **Option B: GitHub Webhook (Instant builds on push)**
   - ✅ Check "GitHub hook trigger for GITScm polling"
   - Note: Requires webhook setup (see Step 6)

4. **Configure Pipeline**
   - Definition: **"Pipeline script from SCM"**
   - SCM: **"Git"**
   
   **Repository URL:**
   - If using HTTPS token: `https://github.com/PaladiAbhideep/Devops_Project.git`
   - If using SSH: `git@github.com:PaladiAbhideep/Devops_Project.git`
   
   **Credentials:**
   - Select: `github-credentials` (or `github-ssh` if using SSH)
   
   **Branches to build:**
   - Branch Specifier: `*/main`
   
   **Script Path:**
   - `Jenkinsfile`

5. **Advanced Settings (Optional)**
   - Click "Advanced" under "Additional Behaviours"
   - Add "Clean before checkout" (recommended)

6. **Save**
   - Click "Save" at the bottom

---

### Step 6: Set Up GitHub Webhook (Optional - For Instant Builds)

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

3. **Copy the ngrok URL**
   - Example: `https://abc123.ngrok.io`

4. **Add Webhook in GitHub**
   - Go to: https://github.com/PaladiAbhideep/Devops_Project/settings/hooks
   - Click "Add webhook"
   - Fill in:
     - Payload URL: `https://abc123.ngrok.io/github-webhook/`
     - Content type: `application/json`
     - Which events: "Just the push event"
     - ✅ Active
   - Click "Add webhook"

#### For Production (Public Jenkins Server):

If Jenkins is publicly accessible:
- Payload URL: `http://your-jenkins-domain.com:8080/github-webhook/`
- Follow same steps as above

---

### Step 7: Configure Dashboard API Integration

Make sure your Jenkinsfile has the correct API URL.

1. **Check Jenkinsfile**

The Jenkinsfile in your repository should have:
```groovy
environment {
    DASHBOARD_API_URL = 'http://localhost:4000'
}
```

2. **Verify Backend is Running**
```powershell
# Test backend API
curl http://localhost:4000/health

# Should return: {"status":"ok"}
```

---

### Step 8: Test the Connection

1. **Trigger First Build**
   - Go to Jenkins Dashboard
   - Click `Devops_Project_Pipeline`
   - Click **"Build Now"**

2. **Watch the Build**
   - Click on build number (e.g., #1)
   - Click "Console Output"
   - Watch the pipeline execute!

3. **Verify in Dashboard**
   - Open: http://localhost:3000
   - You should see the pipeline run appear
   - Watch logs stream in real-time!

4. **Expected Output:**
   ```
   Started by user admin
   Checking out git https://github.com/PaladiAbhideep/Devops_Project.git
   ...
   [Pipeline] stage 'Checkout'
   [Pipeline] stage 'Install Dependencies'
   [Pipeline] stage 'Build'
   ...
   Finished: SUCCESS
   ```

---

## 🎮 Usage

### Automatic Builds

**With Polling (Every 5 minutes):**
1. Make changes to your code
2. Commit and push to GitHub:
```powershell
git add .
git commit -m "Your changes"
git push
```
3. Wait up to 5 minutes
4. Jenkins automatically detects changes and builds

**With Webhook (Instant):**
1. Make changes and push
2. GitHub sends webhook to Jenkins
3. Build starts immediately!
4. Watch in Dashboard: http://localhost:3000

### Manual Builds

1. Go to: http://localhost:8080/job/Devops_Project_Pipeline/
2. Click "Build Now"
3. Watch build execute
4. View in Dashboard

---

## 🔍 Verify Everything Works

### Checklist:

- [ ] Jenkins running at http://localhost:8080
- [ ] Git plugin installed
- [ ] GitHub credentials added
- [ ] Pipeline job created
- [ ] Repository connected (test with "Build Now")
- [ ] Build completes successfully
- [ ] Build appears in Dashboard (http://localhost:3000)
- [ ] Logs stream in real-time
- [ ] Automatic builds work (push to GitHub)

### Test Commands:

```powershell
# 1. Verify Jenkins is running
curl http://localhost:8080/login

# 2. Verify Backend is running
curl http://localhost:4000/health

# 3. Verify Dashboard is accessible
curl http://localhost:3000

# 4. Check Jenkins job exists
# Visit: http://localhost:8080/job/Devops_Project_Pipeline/

# 5. Trigger a build via API (optional)
curl -X POST http://localhost:8080/job/Devops_Project_Pipeline/build --user admin:admin123
```

---

## 🐛 Troubleshooting

### "Failed to connect to repository"

**Issue:** Jenkins can't access GitHub

**Solutions:**
```powershell
# 1. Verify Git is installed
git --version

# 2. Test Git connection manually
git ls-remote https://github.com/PaladiAbhideep/Devops_Project.git

# 3. Check credentials are correct
# Go to: Manage Jenkins → Credentials
# Verify username and token

# 4. Try HTTPS instead of SSH (or vice versa)
```

### "Credentials not found"

**Solution:**
- Go to "Manage Jenkins" → "Credentials"
- Verify credentials ID matches what you selected in job
- Re-create credentials if needed

### "Webhook not working"

**Solutions:**
1. Check webhook deliveries in GitHub:
   - Settings → Webhooks → Click your webhook
   - Check "Recent Deliveries"
   - Should show green checkmarks

2. Verify ngrok is running (for local):
```powershell
# Check ngrok status
curl https://your-ngrok-url.ngrok.io/github-webhook/
```

3. Check Jenkins logs:
```powershell
Get-Content "C:\Jenkins\jenkins_home\jenkins.log" -Tail 50
```

### "Build fails with 'Jenkinsfile not found'"

**Solution:**
- Verify Jenkinsfile exists in repository root
- Check branch name is correct (`main` not `master`)
- Check "Script Path" is exactly: `Jenkinsfile`

### "Can't call Dashboard API"

**Solutions:**
1. Verify backend is running:
```powershell
curl http://localhost:4000/health
```

2. Check Jenkinsfile has correct URL:
```groovy
DASHBOARD_API_URL = 'http://localhost:4000'
```

3. Check CORS settings in backend

### "Permission denied"

**Solution:**
```powershell
# On Windows, run Jenkins as Administrator
# Or adjust security settings in Jenkins
# Go to: Manage Jenkins → Security
```

---

## 🎯 What Happens in a Complete Flow

1. **Developer** pushes code to GitHub
   ```
   git push origin main
   ```

2. **GitHub** sends webhook to Jenkins (if configured)

3. **Jenkins** detects change (webhook or polling)

4. **Jenkins** clones repository

5. **Jenkins** reads Jenkinsfile

6. **Jenkins** executes pipeline stages:
   - Checkout
   - Install Dependencies
   - Build
   - Test
   - Lint
   - Security Scan
   - Package
   - Deploy

7. **Jenkinsfile** calls Dashboard API:
   - Creates run
   - Updates steps
   - Sends logs

8. **Backend** receives updates

9. **Backend** publishes to Redis

10. **Frontend** receives WebSocket updates

11. **User** sees real-time progress at http://localhost:3000

---

## 📊 Monitoring

### View Build Status:

**Jenkins:**
- Dashboard: http://localhost:8080
- Job: http://localhost:8080/job/Devops_Project_Pipeline/
- Build #1: http://localhost:8080/job/Devops_Project_Pipeline/1/console

**Dashboard:**
- Main View: http://localhost:3000
- Shows all pipeline runs
- Real-time log streaming
- Visual stage progress

### Check Logs:

```powershell
# Jenkins console output
# Click build number → Console Output

# Backend logs
# Check backend PowerShell window

# Worker logs
# Check worker PowerShell window
```

---

## 🎓 Next Steps

1. ✅ Jenkins connected to GitHub
2. ⬜ Customize Jenkinsfile for your needs
3. ⬜ Add deployment stages
4. ⬜ Set up email notifications
5. ⬜ Add test result publishing
6. ⬜ Configure build parameters
7. ⬜ Set up multi-branch pipeline
8. ⬜ Add Slack notifications

---

## 📚 Useful Commands

```powershell
# Start Jenkins
cd C:\Jenkins
java -jar jenkins.war --httpPort=8080

# Start Dashboard services
cd "C:\Users\tests\Downloads\cicd project"
.\START-WINDOWS.ps1

# Check Jenkins service (if installed as service)
Get-Service Jenkins

# View Jenkins home directory
explorer C:\Jenkins\jenkins_home

# Restart Jenkins
# Ctrl+C in terminal, then restart

# Check Git configuration in Jenkins
# Manage Jenkins → Tools → Git installations

# Backup Jenkins configuration
Copy-Item "C:\Jenkins\jenkins_home" -Destination "C:\Jenkins\jenkins_home_backup" -Recurse
```

---

## 🎉 Success!

Once everything is set up, you'll have:
- ✅ Automatic builds on every push to GitHub
- ✅ Real-time build monitoring in Dashboard
- ✅ Live log streaming
- ✅ Visual pipeline stages
- ✅ Build history and analytics
- ✅ Complete CI/CD automation!

**Your DevOps pipeline is now live!** 🚀

---

## 📖 Related Documentation

- **Jenkins Setup**: JENKINS-NO-DOCKER.md
- **GitHub Push Guide**: GITHUB-PUSH-GUIDE.md
- **Windows Setup**: SETUP-WINDOWS-NO-DOCKER.md
- **Project Overview**: README.md

---

**Repository**: https://github.com/PaladiAbhideep/Devops_Project

**Jenkins**: http://localhost:8080

**Dashboard**: http://localhost:3000

**Happy Building!** 🎉
