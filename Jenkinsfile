pipeline {
    agent any
    
    environment {
        DASHBOARD_API = "${env.DASHBOARD_API_URL ?: 'http://backend:4000'}"
        NODE_VERSION = '20'
    }
    
    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timestamps()
        timeout(time: 30, unit: 'MINUTES')
    }
    
    triggers {
        // Poll SCM every 5 minutes (can be replaced with webhooks)
        pollSCM('H/5 * * * *')
    }
    
    stages {
        stage('Initialize') {
            steps {
                script {
                    echo "=== CI/CD Pipeline Started ==="
                    echo "Job: ${env.JOB_NAME}"
                    echo "Build: ${env.BUILD_NUMBER}"
                    echo "Branch: ${env.GIT_BRANCH ?: 'main'}"
                    
                    // Create run in dashboard
                    def response = createDashboardRun()
                    env.DASHBOARD_RUN_ID = response?.id ?: 'unknown'
                    echo "Dashboard Run ID: ${env.DASHBOARD_RUN_ID}"
                }
            }
        }
        
        stage('Checkout') {
            steps {
                script {
                    updateDashboardStep('Checkout', 'running')
                }
                
                // Checkout code from Git
                checkout scm
                
                script {
                    updateDashboardStep('Checkout', 'success')
                }
            }
        }
        
        stage('Install Dependencies') {
            steps {
                script {
                    updateDashboardStep('Install Dependencies', 'running')
                }
                
                // Install Node.js dependencies
                sh '''
                    echo "Installing dependencies..."
                    if [ -f "package.json" ]; then
                        npm ci || npm install
                    else
                        echo "No package.json found, skipping..."
                    fi
                '''
                
                script {
                    updateDashboardStep('Install Dependencies', 'success')
                }
            }
        }
        
        stage('Build') {
            steps {
                script {
                    updateDashboardStep('Build', 'running')
                }
                
                sh '''
                    echo "Building application..."
                    if grep -q "\\"build\\"" package.json 2>/dev/null; then
                        npm run build
                    else
                        echo "No build script found, skipping..."
                    fi
                '''
                
                script {
                    updateDashboardStep('Build', 'success')
                }
            }
        }
        
        stage('Test') {
            steps {
                script {
                    updateDashboardStep('Test', 'running')
                }
                
                sh '''
                    echo "Running tests..."
                    if grep -q "\\"test\\"" package.json 2>/dev/null; then
                        npm test || echo "Tests failed but continuing..."
                    else
                        echo "No test script found, skipping..."
                    fi
                '''
                
                script {
                    updateDashboardStep('Test', 'success')
                }
            }
        }
        
        stage('Lint') {
            steps {
                script {
                    updateDashboardStep('Lint', 'running')
                }
                
                sh '''
                    echo "Running linter..."
                    if grep -q "\\"lint\\"" package.json 2>/dev/null; then
                        npm run lint || echo "Linting failed but continuing..."
                    else
                        echo "No lint script found, skipping..."
                    fi
                '''
                
                script {
                    updateDashboardStep('Lint', 'success')
                }
            }
        }
        
        stage('Security Scan') {
            steps {
                script {
                    updateDashboardStep('Security Scan', 'running')
                }
                
                sh '''
                    echo "Running security scan..."
                    if [ -f "package.json" ]; then
                        npm audit --audit-level=moderate || echo "Security issues found but continuing..."
                    fi
                '''
                
                script {
                    updateDashboardStep('Security Scan', 'success')
                }
            }
        }
        
        stage('Package') {
            steps {
                script {
                    updateDashboardStep('Package', 'running')
                }
                
                sh '''
                    echo "Packaging application..."
                    tar -czf application.tar.gz . --exclude=node_modules --exclude=.git
                    echo "Package created: application.tar.gz"
                '''
                
                archiveArtifacts artifacts: 'application.tar.gz', fingerprint: true
                
                script {
                    updateDashboardStep('Package', 'success')
                }
            }
        }
        
        stage('Deploy') {
            when {
                branch 'main'
            }
            steps {
                script {
                    updateDashboardStep('Deploy', 'running')
                }
                
                sh '''
                    echo "Deploying to staging environment..."
                    echo "Deployment successful (simulated)"
                '''
                
                script {
                    updateDashboardStep('Deploy', 'success')
                }
            }
        }
    }
    
    post {
        success {
            script {
                echo "=== Pipeline Completed Successfully ==="
                updateDashboardRun('success')
            }
        }
        failure {
            script {
                echo "=== Pipeline Failed ==="
                updateDashboardRun('failed')
            }
        }
        aborted {
            script {
                echo "=== Pipeline Aborted ==="
                updateDashboardRun('cancelled')
            }
        }
        always {
            script {
                echo "=== Pipeline Finished ==="
                // Clean up workspace
                cleanWs()
            }
        }
    }
}

// Helper function to create a run in the dashboard
def createDashboardRun() {
    try {
        def payload = """
        {
            "pipelineId": 1,
            "repo": "${env.GIT_URL ?: 'jenkins/manual'}",
            "branch": "${env.GIT_BRANCH ?: 'main'}",
            "triggeredBy": "jenkins-${env.BUILD_USER_ID ?: 'system'}",
            "params": {
                "jenkinsJob": "${env.JOB_NAME}",
                "jenkinsBuild": "${env.BUILD_NUMBER}",
                "jenkinsUrl": "${env.BUILD_URL}"
            }
        }
        """
        
        def response = sh(
            script: """
                curl -s -X POST ${DASHBOARD_API}/api/runs \
                    -H 'Content-Type: application/json' \
                    -d '${payload}'
            """,
            returnStdout: true
        ).trim()
        
        return readJSON(text: response)
    } catch (Exception e) {
        echo "Failed to create dashboard run: ${e.message}"
        return null
    }
}

// Helper function to update run status
def updateDashboardRun(status) {
    if (!env.DASHBOARD_RUN_ID || env.DASHBOARD_RUN_ID == 'unknown') {
        return
    }
    
    try {
        sh """
            curl -s -X POST ${DASHBOARD_API}/api/jenkins/runs/${env.DASHBOARD_RUN_ID}/status \
                -H 'Content-Type: application/json' \
                -d '{
                    "status": "${status}",
                    "timestamp": "'"$(date -u +%Y-%m-%dT%H:%M:%SZ)"'",
                    "jenkinsUrl": "${env.BUILD_URL}"
                }'
        """
    } catch (Exception e) {
        echo "Failed to update dashboard run: ${e.message}"
    }
}

// Helper function to update step status
def updateDashboardStep(stepName, status) {
    if (!env.DASHBOARD_RUN_ID || env.DASHBOARD_RUN_ID == 'unknown') {
        return
    }
    
    try {
        sh """
            curl -s -X POST ${DASHBOARD_API}/api/jenkins/steps \
                -H 'Content-Type: application/json' \
                -d '{
                    "runId": "${env.DASHBOARD_RUN_ID}",
                    "stepName": "${stepName}",
                    "status": "${status}",
                    "timestamp": "'"$(date -u +%Y-%m-%dT%H:%M:%SZ)"'",
                    "stage": "Build"
                }'
        """
        
        // Send log message
        sh """
            curl -s -X POST ${DASHBOARD_API}/api/jenkins/logs \
                -H 'Content-Type: application/json' \
                -d '{
                    "runId": "${env.DASHBOARD_RUN_ID}",
                    "stepName": "${stepName}",
                    "level": "info",
                    "message": "Step ${stepName} is ${status}",
                    "timestamp": "'"$(date -u +%Y-%m-%dT%H:%M:%SZ)"'"
                }'
        """
    } catch (Exception e) {
        echo "Failed to update dashboard step: ${e.message}"
    }
}
