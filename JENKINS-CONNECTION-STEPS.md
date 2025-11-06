# 🎉 Jenkins is Now Running! Connect to GitHub

## ✅ Current Status

Jenkins is running at: **http://localhost:9090**

### Jenkins Initial Password:
```
1cda8388e7e84e8780eae1d566b27eef
```

---

## 📝 Step-by-Step Connection Guide

### Step 1: Access Jenkins (NOW)

1. Open your browser and go to: **http://localhost:9090**

2. You'll see "Unlock Jenkins" screen

3. Paste this password:
   ```
   1cda8388e7e84e8780eae1d566b27eef
   ```

4. Click **"Continue"**

---

### Step 2: Install Plugins (5 minutes)

1. Click **"Install suggested plugins"**

2. Wait for plugins to install (this takes 5-10 minutes)

3. You'll see progress bars for each plugin

---

### Step 3: Create Admin User (1 minute)

When prompted, create your admin user:

- **Username**: `admin`
- **Password**: `admin123`
- **Full name**: Your Name
- **Email**: your@email.com

Click **"Save and Continue"**

---

### Step 4: Set Jenkins URL

- Jenkins URL: `http://localhost:9090/`
- Click **"Save and Finish"**
- Click **"Start using Jenkins"**

---

### Step 5: Install Additional Plugins (5 minutes)

1. Go to: **"Manage Jenkins"** → **"Plugins"**

2. Click **"Available plugins"**

3. Search and install these plugins:
   - ✅ **Git** (if not already installed)
   - ✅ **GitHub**
   - ✅ **Pipeline**
   - ✅ **HTTP Request Plugin**
   - ✅ **Credentials Binding**

4. Check all boxes

5. Click **"Install without restart"**

6. Wait for installation

---

### Step 6: Create GitHub Personal Access Token (5 minutes)

1. Open: https://github.com/settings/tokens

2. Click **"Generate new token"** → **"Generate new token (classic)"**

3. Fill in:
   - **Note**: `Jenkins CI/CD`
   - **Expiration**: 90 days
   - **Scopes**: Check **`repo`** (all sub-boxes)

4. Click **"Generate token"**

5. **COPY THE TOKEN** (you won't see it again!)

---

### Step 7: Add GitHub Credentials to Jenkins (2 minutes)

1. In Jenkins, go to: **"Manage Jenkins"** → **"Credentials"**

2. Click **"(global)"** under "Stores scoped to Jenkins"

3. Click **"Add Credentials"**

4. Fill in:
   - **Kind**: `Username with password`
   - **Scope**: `Global`
   - **Username**: `PaladiAbhideep`
   - **Password**: `<paste your GitHub token from Step 6>`
   - **ID**: `github-credentials`
   - **Description**: `GitHub Personal Access Token`

5. Click **"Create"**

---

### Step 8: Create Pipeline Job (5 minutes)

1. Go to Jenkins Dashboard: http://localhost:9090

2. Click **"New Item"**

3. Enter name: `Devops_Project_Pipeline`

4. Select: **"Pipeline"**

5. Click **"OK"**

---

### Step 9: Configure Pipeline Job

#### General Section:

- **Description**: `CI/CD Pipeline for DevOps Project`
- ✅ Check **"GitHub project"**
- **Project URL**: `https://github.com/PaladiAbhideep/Devops_Project/`

#### Build Triggers:

- ✅ Check **"Poll SCM"**
- **Schedule**: `H/5 * * * *`
  (This checks GitHub every 5 minutes for changes)

#### Pipeline Section:

- **Definition**: Select **"Pipeline script from SCM"**
- **SCM**: Select **"Git"**

**Repository Settings:**
- **Repository URL**: `https://github.com/PaladiAbhideep/Devops_Project.git`
- **Credentials**: Select `github-credentials`

**Branches to build:**
- **Branch Specifier**: `*/main`

**Script Path:**
- **Script Path**: `Jenkinsfile`

---

### Step 10: Save and Test! (2 minutes)

1. Click **"Save"** at the bottom

2. You'll see your pipeline page

3. Click **"Build Now"**

4. Watch the build start!

5. Click on build #1

6. Click **"Console Output"**

7. Watch the pipeline execute!

---

### Step 11: Verify in Dashboard

1. Open: **http://localhost:3000**

2. You should see the pipeline run appear!

3. Watch logs stream in real-time! 🎉

---

## 🎯 Testing Automatic Builds

After your first build works:

1. Make a change to your code:
```powershell
cd "C:\Users\tests\Downloads\cicd project"
echo "# Test" >> README.md
git add README.md
git commit -m "Test Jenkins automation"
git push
```

2. Wait up to 5 minutes (polling interval)

3. Jenkins will automatically detect the change and build!

4. Check Jenkins: http://localhost:9090/job/Devops_Project_Pipeline/

5. Check Dashboard: http://localhost:3000

---

## 📊 What You Have Now

| Service | URL | Status |
|---------|-----|--------|
| **Jenkins** | http://localhost:9090 | ✅ Running |
| **Dashboard** | http://localhost:3000 | ⬜ Start with START-WINDOWS.ps1 |
| **Backend** | http://localhost:4000 | ⬜ Start with START-WINDOWS.ps1 |

---

## 🚀 Start Dashboard Services

If not already running:

```powershell
cd "C:\Users\tests\Downloads\cicd project"
.\START-WINDOWS.ps1
```

---

## ✅ Success Checklist

- [ ] Jenkins accessible at http://localhost:9090
- [ ] Logged in with admin/admin123
- [ ] Plugins installed (Git, GitHub, Pipeline)
- [ ] GitHub token created
- [ ] Credentials added to Jenkins
- [ ] Pipeline job created and configured
- [ ] First build successful
- [ ] Build appears in Dashboard
- [ ] Logs stream in real-time
- [ ] Automatic builds working

---

## 🎉 Congratulations!

Your GitHub repository is now connected to Jenkins!

**Every time you push code to GitHub:**
1. Jenkins detects the change (within 5 minutes)
2. Runs your pipeline (build, test, deploy)
3. Updates Dashboard in real-time
4. You see live progress at http://localhost:3000

---

## 📚 Additional Resources

- **Full Guide**: CONNECT-GITHUB-TO-JENKINS.md
- **Checklist**: SETUP-CHECKLIST.md
- **Jenkins Setup**: JENKINS-NO-DOCKER.md
- **Project README**: README.md

---

## 🐛 Troubleshooting

### "Can't access Jenkins"
- URL is http://localhost:**9090** (not 8080)
- Make sure Jenkins terminal is still running

### "Credentials not working"
- Verify GitHub token has 'repo' scope
- Token must be used as password, not your GitHub password

### "Build not appearing in Dashboard"
```powershell
# Verify backend is running
curl http://localhost:4000/health

# Should return: {"status":"ok"}
```

### "Port 9090 already in use"
```powershell
# Find process using port 9090
Get-NetTCPConnection -LocalPort 9090

# Kill it if needed
Stop-Process -Id <PID> -Force
```

---

**Happy Building! 🚀**
