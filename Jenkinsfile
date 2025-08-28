pipeline {
    agent { label 'app-server' }

    environment {
        DOCKER_DIR = "/home/devops/apps/docker"
        PYTHON_APP_DIR = "/home/devops/apps/python-app"
        HTML_APP_DIR = "/home/devops/apps/html-app"
    }

    options {
        // Keep only last 10 builds to save disk space
        buildDiscarder(logRotator(numToKeepStr: '10'))
        // Timeout pipeline if stuck
        timeout(time: 60, unit: 'MINUTES')
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main', url: 'git@github.com:your-org/your-repo.git'
            }
        }

        stage('Verify Docker & Compose') {
            steps {
                sh '''
                    echo "Docker version:"
                    docker --version
                    echo "Docker Compose version:"
                    docker compose version
                '''
            }
        }

        stage('Build & Deploy Stack') {
            steps {
                dir("${DOCKER_DIR}") {
                    // Pull images with retry
                    sh '''
                        export COMPOSE_HTTP_TIMEOUT=300
                        export DOCKER_CLIENT_TIMEOUT=300
                        docker compose pull || true
                    '''
                    // Start stack with rebuild
                    sh '''
                        docker compose up -d --build
                    '''
                }
            }
        }

        stage('Verify Containers') {
            steps {
                sh '''
                    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
                '''
            }
        }

        stage('Run Python App Tests') {
            steps {
                dir("${PYTHON_APP_DIR}") {
                    sh '''
                        pip3 install -r requirements.txt
                        pytest tests/
                    '''
                }
            }
        }

        stage('Echo HTML App Status') {
            steps {
                dir("${HTML_APP_DIR}") {
                    sh 'echo "HTML app deployed in ${HTML_APP_DIR}"'
                }
            }
        }

    }

    post {
        success {
            echo "Deployment pipeline completed successfully on ${env.NODE_NAME}"
        }
        failure {
            echo "Deployment failed on ${env.NODE_NAME}. Check logs!"
        }
    }
}
