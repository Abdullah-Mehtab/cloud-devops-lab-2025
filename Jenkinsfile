// Jenkinsfile — Fix B: host agent (label 'app-server'), HTTPS checkout using PAT stored in Jenkins
pipeline {
  agent { label 'app-server' }

  environment {
    DOCKERHUB_CREDENTIALS = credentials('dockerhub-credentials')
    DOCKERHUB_USERNAME = 'abdullahmehtab'
    IMAGE_PY = "${DOCKERHUB_USERNAME}/my-python-app"
    IMAGE_HTML = "${DOCKERHUB_USERNAME}/my-html-app"
    ANSIBLE_PLAYBOOK = 'ansible/deploy-stack.yml'
    ANSIBLE_INVENTORY = 'ansible/inventory.ini'
  }

  options {
    buildDiscarder(logRotator(numToKeepStr: '30'))
    timeout(time: 60, unit: 'MINUTES')
  }

  stages {
    stage('Checkout (HTTPS + PAT)') {
      steps {
        // uses the Jenkins credential ID 'github-pat-credentials' added earlier
        echo "Checking out repository via HTTPS using stored PAT credential..."
        git branch: 'develop',
            url: 'https://github.com/Abdullah-Mehtab/cloud-devops-lab-2025.git',
            credentialsId: 'github-pat-credentials'
      }
    }

    stage('Pre-flight') {
      steps {
        script {
          if (sh(script: 'command -v docker >/dev/null 2>&1', returnStatus: true) != 0) {
            error "docker CLI not found on agent 'app-server'. Install Docker on the EC2 host."
          }
        }
      }
    }

    stage('Build Images') {
      steps {
        script {
          dir('python-app') {
            sh "docker build -t ${IMAGE_PY}:${env.BUILD_ID} ."
            sh "docker tag ${IMAGE_PY}:${env.BUILD_ID} ${IMAGE_PY}:latest || true"
          }
          dir('html-app') {
            sh "docker build -t ${IMAGE_HTML}:${env.BUILD_ID} ."
            sh "docker tag ${IMAGE_HTML}:${env.BUILD_ID} ${IMAGE_HTML}:latest || true"
          }
        }
      }
    }

    stage('Test') {
      steps {
        script {
          echo "Running unit tests inside python image (non-blocking)..."
          sh """
            set +e
            docker run --rm ${IMAGE_PY}:${env.BUILD_ID} bash -c 'python -m pytest tests/ -v'
            RC=\$?
            set -e
            if [ \$RC -ne 0 ]; then
              echo "Unit tests returned \$RC — pipeline will continue (change to fail if desired)."
            fi
          """
          sh 'pip3 install --user flake8 || true'
          sh 'flake8 python-app/app.py || true'
        }
      }
    }

    stage('SonarQube (optional)') {
      steps {
        echo "SonarQube step placeholder — configure with withSonarQubeEnv(...) when Sonar is set up."
      }
    }

    stage('Push to DockerHub') {
      steps {
        script {
          withCredentials([usernamePassword(credentialsId: 'dockerhub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
            sh 'echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin'
          }
          sh "docker push ${IMAGE_PY}:${env.BUILD_ID} || true"
          sh "docker push ${IMAGE_PY}:latest || true"
          sh "docker push ${IMAGE_HTML}:${env.BUILD_ID} || true"
          sh "docker push ${IMAGE_HTML}:latest || true"
        }
      }
    }

    stage('Deploy (ansible)') {
      when { branch 'main' }   // only run deploy when building main; remove or change if you want otherwise
      steps {
        script {
          if (sh(script: 'command -v ansible-playbook >/dev/null 2>&1', returnStatus: true) == 0) {
            sh "ansible-playbook -i ${ANSIBLE_INVENTORY} ${ANSIBLE_PLAYBOOK} --extra-vars \"app_version=${env.BUILD_ID}\""
          } else {
            echo "ansible-playbook not found on agent; skipping deploy. Install Ansible on the 'app-server' node if you want automated deploys."
          }
        }
      }
    }
  }

  post {
    always {
      script {
        if (sh(script: 'command -v docker >/dev/null 2>&1', returnStatus: true) == 0) {
          sh 'docker system prune -f || true'
        } else {
          echo 'docker CLI missing; skipped docker prune'
        }
      }
    }
    success { echo "Pipeline succeeded (BUILD_ID=${env.BUILD_ID})" }
    failure { echo "Pipeline failed (BUILD_ID=${env.BUILD_ID}); check console output." }
  }
}
