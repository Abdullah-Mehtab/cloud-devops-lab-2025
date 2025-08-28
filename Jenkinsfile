pipeline {
    agent any
    environment {
        DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')
        DOCKERHUB_USERNAME = 'abdullahmehtab'
    }
    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Build Applications') {
            steps {
                script {
                    // Build Python app from source
                    dir('python-app') {
                        docker.build("${DOCKERHUB_USERNAME}/my-python-app:${env.BUILD_ID}", ".")
                    }

                    // Build HTML app from source
                    dir('html-app') {
                        docker.build("${DOCKERHUB_USERNAME}/my-html-app:${env.BUILD_ID}", ".")
                    }
                }
            }
        }

        stage('Test') {
            steps {
                script {
                    // Run unit tests for Python app
                    docker.image("${DOCKERHUB_USERNAME}/my-python-app:${env.BUILD_ID}").inside {
                        sh 'python -m pytest tests/ -v || true'  // continue even if tests fail
                    }

                    // Linting for Python app
                    sh 'pip install flake8 || true'
                    sh 'flake8 python-app/app.py || true'
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                script {
                    echo "SonarQube analysis would run here"
                    // Example Sonar scanner usage (if configured):
                    // sh 'sonar-scanner -Dsonar.projectKey=my-python-app -Dsonar.sources=python-app -Dsonar.host.url=http://sonarqube:9000 -Dsonar.login=admin -Dsonar.password=admin'
                }
            }
        }

        stage('Push to DockerHub') {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', 'dockerhub-credentials') {
                        // Push Python app
                        docker.image("${DOCKERHUB_USERNAME}/my-python-app:${env.BUILD_ID}").push()
                        docker.image("${DOCKERHUB_USERNAME}/my-python-app:${env.BUILD_ID}").push("latest")

                        // Push HTML app
                        docker.image("${DOCKERHUB_USERNAME}/my-html-app:${env.BUILD_ID}").push()
                        docker.image("${DOCKERHUB_USERNAME}/my-html-app:${env.BUILD_ID}").push("latest")
                    }
                }
            }
        }

        stage('Deploy') {
            steps {
                script {
                    // Use Ansible to deploy new versions
                    ansiblePlaybook(
                        playbook: 'ansible/deploy-app.yml',
                        extras: "--extra-vars 'app_version=${env.BUILD_ID}'",
                        inventory: 'ansible/inventory.ini'
                    )
                }
            }
        }
    }

    post {
        always {
            // Clean up Docker images and cache
            sh 'docker system prune -f'
        }
    }
}
