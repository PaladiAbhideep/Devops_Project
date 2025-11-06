# 🚀 Quick Setup Checklist - Connect GitHub to Jenkins

## ✅ Follow These Steps in Order

### Phase 1: Install Prerequisites (30 minutes)

- [ ] **Install Java JDK 17**
  - Download: https://adoptium.net/
  - Verify: `java -version`

- [ ] **Download Jenkins**
  ```powershell
  mkdir C:\Jenkins
  cd C:\Jenkins
  Invoke-WebRequest -Uri "https://get.jenkins.io/war-stable/latest/jenkins.war" -OutFile "jenkins.war"
  ```

- [ ] **Install PostgreSQL 15**
  - Download: https://www.postgresql.org/download/windows/
  - Password: `postgres123` (or your choice)

- [ ] **Install Memurai (Redis)**
  - Download: https://www.memurai.com/get-memurai

### Phase 2: Setup Database (5 minutes)

- [ ] **Create database**
  ```powershell
  psql -U postgres
  CREATE DATABASE cicd_dashboard;
  \q
  ```

- [ ] **Run setup script**
  ```powershell
  cd "C:\Users\tests\Downloads\cicd project"
  psql -U postgres -d cicd_dashboard -f setup-database.sql
  ```

### Phase 3: Start Services (5 minutes)

- [ ] **Start Dashboard services**
  ```powershell
  cd "C:\Users\tests\Downloads\cicd project"
  .\START-WINDOWS.ps1
  ```
  This opens 3 windows: Backend, Worker, Frontend

- [ ] **Start Jenkins**
  ```powershell
  cd C:\Jenkins
  java -jar jenkins.war --httpPort=8080
  ```

- [ ] **Access Jenkins**
  - URL: http://localhost:8080
  - Get password: `Get-Content "C:\Jenkins\jenkins_home\secrets\initialAdminPassword"`
  - Paste password in browser

### Phase 4: Configure Jenkins (15 minutes)

- [ ] **Install suggested plugins**
  - Click "Install suggested plugins"
  - Wait for completion

- [ ] **Create admin user**
  - Username: `admin`
  - Password: `admin123`
  - Click "Save and Continue"

- [ ] **Install additional plugins**
  - Go to: Manage Jenkins → Plugins → Available
  - Search and install:
    - ✅ Git
    - ✅ GitHub
    - ✅ Pipeline
    - ✅ HTTP Request Plugin
  - Click "Install without restart"

### Phase 5: Setup GitHub Access (10 minutes)

- [ ] **Create GitHub Personal Access Token**
  - Go to: https://github.com/settings/tokens
  - Click "Generate new token (classic)"
  - Name: `Jenkins CI/CD`
  - Scope: Check **`repo`** (all boxes)
  - Click "Generate token"
  - **COPY THE TOKEN** (you won't see it again!)

- [ ] **Add credentials to Jenkins**
  - Jenkins: Manage Jenkins → Credentials
  - Click "(global)" → "Add Credentials"
  - Kind: "Username with password"
  - Username: `PaladiAbhideep`
  - Password: `<paste your token>`
  - ID: `github-credentials`
  - Click "Create"

### Phase 6: Create Pipeline Job (10 minutes)

- [ ] **Create new job**
  - Jenkins Dashboard → "New Item"
  - Name: `Devops_Project_Pipeline`
  - Type: "Pipeline"
  - Click "OK"

- [ ] **Configure job**
  - ✅ Check "GitHub project"
  - URL: `https://github.com/PaladiAbhideep/Devops_Project/`
  
- [ ] **Set build trigger**
  - ✅ Check "Poll SCM"
  - Schedule: `H/5 * * * *`

- [ ] **Configure pipeline source**
  - Definition: "Pipeline script from SCM"
  - SCM: "Git"
  - Repository URL: `https://github.com/PaladiAbhideep/Devops_Project.git`
  - Credentials: Select `github-credentials`
  - Branch: `*/main`
  - Script Path: `Jenkinsfile`
  - Click "Save"

### Phase 7: Test Everything (5 minutes)

- [ ] **Verify services are running**
  ```powershell
  # Backend
  curl http://localhost:4000/health
  
  # Dashboard
  curl http://localhost:3000
  
  # Jenkins
  curl http://localhost:8080/login
  ```

- [ ] **Trigger first build**
  - Go to: http://localhost:8080/job/Devops_Project_Pipeline/
  - Click "Build Now"
  - Click build #1
  - Click "Console Output"
  - Watch it execute!

- [ ] **Check Dashboard**
  - Open: http://localhost:3000
  - You should see the pipeline run appear!
  - Watch logs stream in real-time! 🎉

### Phase 8: Test Automatic Builds (5 minutes)

- [ ] **Make a test change**
  ```powershell
  cd "C:\Users\tests\Downloads\cicd project"
  
  # Make a small change
  echo "# Test update" >> README.md
  
  # Commit and push
  git add README.md
  git commit -m "Test Jenkins integration"
  git push
  ```

- [ ] **Wait for automatic build**
  - Wait up to 5 minutes (polling interval)
  - Check Jenkins: http://localhost:8080/job/Devops_Project_Pipeline/
  - New build should start automatically!
  - Check Dashboard to see it appear

---

## ✅ Success Criteria

You'll know everything is working when:

- ✅ Jenkins accessible at http://localhost:8080
- ✅ Dashboard shows at http://localhost:3000
- ✅ Backend API responds at http://localhost:4000/health
- ✅ Manual build ("Build Now") works
- ✅ Build appears in Dashboard
- ✅ Logs stream in real-time
- ✅ Automatic builds trigger on push
- ✅ All pipeline stages complete successfully

---

## 🎯 Quick Reference

### URLs:
- **Dashboard**: http://localhost:3000
- **Backend API**: http://localhost:4000
- **Jenkins**: http://localhost:8080
- **GitHub Repo**: https://github.com/PaladiAbhideep/Devops_Project

### Credentials:
- **Jenkins**: admin / admin123
- **PostgreSQL**: postgres / postgres123
- **GitHub**: Your personal access token

### Important Paths:
- **Project**: `C:\Users\tests\Downloads\cicd project`
- **Jenkins Home**: `C:\Jenkins\jenkins_home`
- **Jenkins WAR**: `C:\Jenkins\jenkins.war`

---

## 🐛 Common Issues

### "Jenkins won't start"
```powershell
# Check Java version
java -version

# Should be 17.x.x
```

### "Can't access GitHub"
- Verify Personal Access Token is correct
- Check credentials ID matches in job config
- Try: `git ls-remote https://github.com/PaladiAbhideep/Devops_Project.git`

### "Build not appearing in Dashboard"
```powershell
# Verify backend is running
curl http://localhost:4000/health

# Check backend PowerShell window for errors
```

### "Automatic builds not working"
- Check "Poll SCM" is enabled
- Verify schedule: `H/5 * * * *`
- Check Jenkins system log for polling activity

---

## 📚 Detailed Guides

For detailed instructions, see:
- **CONNECT-GITHUB-TO-JENKINS.md** - Complete connection guide
- **JENKINS-NO-DOCKER.md** - Jenkins installation
- **NO-DOCKER-SUMMARY.md** - Setup overview

---

## 🎉 You're Done!

Total Time: ~90 minutes (mostly waiting for installations)

**Your CI/CD pipeline is now fully automated!** 🚀

Every time you push to GitHub:
1. Jenkins automatically detects the change
2. Runs your pipeline (build, test, deploy)
3. Sends updates to Dashboard API
4. You see real-time progress at http://localhost:3000

**Happy coding!** 🎊
