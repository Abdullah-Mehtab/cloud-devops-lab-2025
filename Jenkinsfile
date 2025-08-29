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

        // Stage 6: Deploy application using Ansible (updated)
        stage('Deploy with Ansible') {
            steps {
                withCredentials([string(credentialsId: 'ansible-vault-password', variable: 'VAULT_PASSWORD')]) {
                    sh """
                        # Ensure SSH key has correct permissions
                        chmod 600 /home/jenkins/.ssh/devopsproj || true

                        # Test SSH connection to bastion
                        echo "Testing SSH connection to bastion..."
                        ssh -o StrictHostKeyChecking=no -i /home/jenkins/.ssh/devopsproj devops@13.61.153.223 "echo 'Bastion connection successful'"

                        # Test SSH connection to app server through bastion (using ProxyCommand)
                        echo "Testing SSH connection to app server through bastion..."
                        ssh -o StrictHostKeyChecking=no -i /home/jenkins/.ssh/devopsproj -o ProxyCommand='ssh -W %h:%p -i /home/jenkins/.ssh/devopsproj devops@13.61.153.223' devops@10.0.2.168 "echo 'App server connection successful'"

                        # Create temporary vault password file (secure it briefly)
                        echo "${VAULT_PASSWORD}" > /tmp/vault-pass.txt
                        chmod 600 /tmp/vault-pass.txt

                        # Run Ansible with Jenkins-specific config
                        ANSIBLE_CONFIG=ansible/ansible-jenkins.cfg ansible-playbook ansible/deploy-app.yml \
                            --extra-vars "app_version=${env.BUILD_ID}" \
                            --vault-password-file /tmp/vault-pass.txt \
                            -i ansible/inventory.ini

                        # Cleanup temporary vault file
                        rm -f /tmp/vault-pass.txt
                    """
                }
            }
        }
    } // end stages

    // Post actions for cleanup and notifications
    post {
        always {
            sh 'docker system prune -f || true'
        }
        failure {
            echo 'Pipeline failed!'
        }
        success {
            echo 'Pipeline succeeded!'
        }
    }
}
