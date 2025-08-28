pipeline {
    agent any
    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')
        DOCKERHUB_USERNAME = 'abdullahmehtab'
    }
    stages {
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }
        
        stage('Build Docker Image') {
            steps {
                dir('python-app') {
                    // Use environment variable for image name
                    sh "docker build -t ${env.DOCKERHUB_USERNAME}/my-python-app:${env.BUILD_ID} ."
                }
            }
        }
        
        stage('Run Tests') {
            steps {
                sh "docker run --rm ${env.DOCKERHUB_USERNAME}/my-python-app:${env.BUILD_ID} python -m pytest tests/ -v"
                sh "docker run --rm ${env.DOCKERHUB_USERNAME}/my-python-app:${env.BUILD_ID} flake8 app.py"
            }
        }
        
        stage('SonarQube Analysis') {
            steps {
                // Use the correct port (9001 external -> 9000 internal)
                sh "sonar-scanner -Dsonar.projectKey=my-python-app -Dsonar.sources=python-app -Dsonar.host.url=http://sonarqube:9000 -Dsonar.login=admin -Dsonar.password=admin"
            }
        }
        
        stage('Push to Docker Hub') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', 'dockerhub-credentials') {
                        docker.image("${env.DOCKERHUB_USERNAME}/my-python-app:${env.BUILD_ID}").push()
                        docker.image("${env.DOCKERHUB_USERNAME}/my-python-app:${env.BUILD_ID}").push('latest')
                    }
                }
            }
        }
        
        stage('Deploy with Ansible') {
            steps {
                ansiblePlaybook(
                    playbook: 'ansible/deploy-app.yml',
                    extras: "--extra-vars 'app_version=${env.BUILD_ID}'",
                    inventory: 'ansible/inventory.ini'
                )
            }
        }
    }
    
    post {
        always {
            sh 'docker system prune -f'
        }
    }
}