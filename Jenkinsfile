pipeline {
    agent any

    environment {
<<<<<<< HEAD
        GIT_CREDENTIALS = 'github-pat-credentials' // your GitHub PAT credential ID
=======
        GIT_CREDENTIALS = 'github-pat-credentials'
>>>>>>> 4999ccd (Minimal Jenkinsfile: Python-Flask + HTML deployment (removed secret))
        GIT_REPO = 'https://github.com/Abdullah-Mehtab/cloud-devops-lab-2025.git'
        GIT_BRANCH = 'develop'
    }

    stages {
        stage('Checkout') {
            steps {
                git(
                    url: "${GIT_REPO}",
                    branch: "${GIT_BRANCH}",
                    credentialsId: "${GIT_CREDENTIALS}"
                )
            }
        }

        stage('Verify Docker & Compose') {
            steps {
                sh 'docker --version'
                sh 'docker-compose --version || echo "docker-compose not installed"'
            }
        }

        stage('Build & Deploy Python-Flask App') {
            steps {
                dir('python-flask-app') {
                    sh '''
                        docker-compose build
                        docker-compose up -d
                    '''
                }
            }
        }

        stage('Deploy HTML App') {
            steps {
                dir('html-app') {
                    sh 'cp -r . /var/www/html/'  // Adjust path if needed
                }
            }
        }

        stage('Verify Containers') {
            steps {
                sh 'docker ps -a'
            }
        }
    }

    post {
        success {
            echo 'Deployment completed successfully!'
        }
        failure {
            echo 'Deployment failed. Check logs!'
        }
    }
}
