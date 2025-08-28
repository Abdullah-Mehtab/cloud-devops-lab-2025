pipeline {
    agent any
    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')
    }
    stages {
        stage('Checkout Code') {
            steps {
                checkout scm  // Gets your code from GitHub
            }
        }
        
        stage('Build Docker Image') {
            steps {
                dir('python-app') {
                    sh 'docker build -t my-python-app:${BUILD_ID} .'
                }
            }
        }
        
        stage('Run Tests') {
            steps {
                sh 'docker run --rm my-python-app:${BUILD_ID} python -m pytest tests/ -v'
                // Add linting if needed: flake8 python-app/app.py
            }
        }
        
        stage('SonarQube Analysis') {
            steps {
                // Ensure sonar-scanner is installed on Jenkins agent
                sh 'sonar-scanner -Dsonar.projectKey=my-python-app -Dsonar.sources=. -Dsonar.host.url=http://localhost:9001 -Dsonar.login=admin -Dsonar.password=admin'
            }
        }
        
        stage('Push to Docker Hub') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', 'dockerhub-credentials') {
                        docker.image("my-python-app:${BUILD_ID}").push()
                    }
                }
            }
        }
        
        stage('Deploy with Ansible') {
            steps {
                ansiblePlaybook(
                    playbook: 'ansible/deploy-app.yml',
                    extras: "--extra-vars 'app_version=${BUILD_ID}'",
                    inventory: 'ansible/inventory.ini'
                )
            }
        }
    }
    
    post {
        always {
            sh 'docker system prune -f'  // Clean up
        }
    }
}