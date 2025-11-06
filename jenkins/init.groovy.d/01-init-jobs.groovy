import jenkins.model.*
import hudson.security.*
import org.jenkinsci.plugins.workflow.job.*
import org.jenkinsci.plugins.workflow.cps.*
import jenkins.branch.*
import org.jenkinsci.plugins.github_branch_source.*

// Get Jenkins instance
def jenkins = Jenkins.getInstance()

println "Jenkins initialization started..."

// Install plugins if not already installed
def pm = jenkins.getPluginManager()
def uc = jenkins.getUpdateCenter()

def pluginsToInstall = [
    'workflow-aggregator',
    'git',
    'github',
    'configuration-as-code',
    'job-dsl',
    'blueocean',
    'nodejs'
]

pluginsToInstall.each { pluginName ->
    if (!pm.getPlugin(pluginName)) {
        println "Installing plugin: ${pluginName}"
        def plugin = uc.getPlugin(pluginName)
        if (plugin) {
            plugin.deploy(true)
        }
    }
}

// Create sample pipeline job
def jobName = "sample-pipeline"
def job = jenkins.getItem(jobName)

if (job == null) {
    println "Creating sample pipeline job: ${jobName}"
    
    def pipelineJob = jenkins.createProject(WorkflowJob.class, jobName)
    pipelineJob.setDefinition(new CpsFlowDefinition('''
pipeline {
    agent any
    
    environment {
        DASHBOARD_API = "${DASHBOARD_API_URL}"
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo 'Checking out code...'
                // Notify dashboard
                script {
                    notifyDashboard('Checkout', 'running')
                }
                sleep 2
            }
        }
        
        stage('Build') {
            steps {
                echo 'Building application...'
                script {
                    notifyDashboard('Build', 'running')
                }
                sleep 3
            }
        }
        
        stage('Test') {
            steps {
                echo 'Running tests...'
                script {
                    notifyDashboard('Test', 'running')
                }
                sleep 2
            }
        }
        
        stage('Deploy') {
            steps {
                echo 'Deploying application...'
                script {
                    notifyDashboard('Deploy', 'running')
                }
                sleep 2
            }
        }
    }
    
    post {
        success {
            echo 'Pipeline completed successfully!'
        }
        failure {
            echo 'Pipeline failed!'
        }
    }
}

def notifyDashboard(stageName, status) {
    try {
        sh """
            curl -X POST ${DASHBOARD_API}/api/jenkins/notify \
                -H 'Content-Type: application/json' \
                -d '{
                    "job": "${env.JOB_NAME}",
                    "build": "${env.BUILD_NUMBER}",
                    "stage": "'"${stageName}"'",
                    "status": "'"${status}"'",
                    "timestamp": "'"$(date -u +%Y-%m-%dT%H:%M:%SZ)"'"
                }'
        """.trim()
    } catch (Exception e) {
        echo "Failed to notify dashboard: ${e.message}"
    }
}
''', true))
    
    pipelineJob.save()
    println "Sample pipeline job created successfully"
}

// Save Jenkins configuration
jenkins.save()

println "Jenkins initialization completed!"
