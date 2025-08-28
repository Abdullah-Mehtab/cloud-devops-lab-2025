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
                    sh "docker build -t ${env.DOCKERHUB_USERNAME}/my-python-app:${env.BUILD_ID} ."
                }
            }
        }
        
        stage('Run Tests') {
            steps {
                // Run tests with timeout to prevent hanging
                timeout(time: 5, unit: 'MINUTES') {
                    sh "docker run --rm ${env.DOCKERHUB_USERNAME}/my-python-app:${env.BUILD_ID} python -m pytest tests/ -v"
                }
                // Run flake8 linting
                sh "docker run --rm ${env.DOCKERHUB_USERNAME}/my-python-app:${env.BUILD_ID} flake8 app.py --max-line-length=120"
            }
        }
        
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
                withCredentials([string(credentialsId: 'ansible-vault-password', variable: 'VAULT_PASSWORD')]) {
                    sh '''
                        echo "$VAULT_PASSWORD" > /tmp/vault-pass.txt
                        ansible-playbook ansible/deploy-app.yml \
                            --extra-vars "app_version=${env.BUILD_ID}" \
                            --vault-password-file /tmp/vault-pass.txt \
                            -i ansible/inventory.ini
                        rm -f /tmp/vault-pass.txt
                    '''
                }
            }
        }
    } // End of stages
    
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