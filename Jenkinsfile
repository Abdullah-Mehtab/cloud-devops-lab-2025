pipeline {
    agent any

    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')
        DOCKERHUB_USERNAME = 'abdullahmehtab'
    }

    stages {
        // Stage 1: Checkout code from Git
        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        // Stage 2: Build Docker image
        stage('Build Docker Image') {
            steps {
                dir('python-app') {
                    sh "docker build -t ${env.DOCKERHUB_USERNAME}/my-python-app:${env.BUILD_ID} ."
                }
            }
        }

        // Stage 3: Run tests
        stage('Run Tests') {
            steps {
                timeout(time: 5, unit: 'MINUTES') {
                    sh "docker run --rm ${env.DOCKERHUB_USERNAME}/my-python-app:${env.BUILD_ID} python -m pytest tests/ -v"
                }
                sh "docker run --rm ${env.DOCKERHUB_USERNAME}/my-python-app:${env.BUILD_ID} flake8 app.py --max-line-length=120"
            }
        }

        // Stage 4: SonarQube Analysis
        stage('SonarQube Analysis') {
            steps {
                withCredentials([string(credentialsId: 'sonarqube-token', variable: 'SONAR_TOKEN')]) {
                    sh """
                    sonar-scanner \
                    -Dsonar.projectKey=my-python-app \
                    -Dsonar.sources=python-app \
                    -Dsonar.host.url=http://sonarqube:9000 \
                    -Dsonar.login=${SONAR_TOKEN}
                    """
                }
            }
        }

        // Stage 5: Push Docker image to Docker Hub
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

        // Stage 6: Deploy application using Ansible
        stage('Deploy with Ansible') {
            steps {
                withCredentials([string(credentialsId: 'ansible-vault-password', variable: 'VAULT_PASSWORD')]) {
                    // Use triple double-quotes for variable expansion
                    sh """
                        echo "$VAULT_PASSWORD" > /tmp/vault-pass.txt
                        ansible-playbook ansible/deploy-app.yml \
                            --extra-vars "app_version=${env.BUILD_ID}" \
                            --vault-password-file /tmp/vault-pass.txt \
                            -i ansible/inventory.ini
                        rm -f /tmp/vault-pass.txt
                    """
                }
            }
        }
    } // End of stages

    // Post actions for cleanup and notifications
    post {
        always {
            sh 'docker system prune -f'
        }
        failure {
            echo 'Pipeline failed!'
        }
        success {
            echo 'Pipeline succeeded!'
        }
    }
}
