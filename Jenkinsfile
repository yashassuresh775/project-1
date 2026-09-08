pipeline {
    agent any

    options {
        timestamps()
        disableConcurrentBuilds()
    }

    environment {
        COMPOSE_PROJECT_NAME = 'flask-postgresql-two-tier'
        APP_HOST_PORT = '5000'
    }

    stages {
        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Validate Compose') {
            steps {
                sh 'docker compose config'
            }
        }

        stage('Build Images') {
            steps {
                sh 'docker compose build'
            }
        }

        stage('Deploy') {
            steps {
                sh '''
                    set -e
                    if [ ! -f .env ]; then
                      cp .env.example .env
                      # On EC2 with Jenkins, publish Flask on 5000 (Jenkins uses 8080).
                      sed -i 's/^APP_HOST_PORT=.*/APP_HOST_PORT=5000/' .env || true
                      grep -q '^APP_HOST_PORT=' .env || echo 'APP_HOST_PORT=5000' >> .env
                    fi
                    docker compose down --remove-orphans || true
                    docker compose up -d --build
                '''
            }
        }

        stage('Smoke Test') {
            steps {
                sh '''
                    set -e
                    for i in $(seq 1 30); do
                      if curl -fsS "http://127.0.0.1:${APP_HOST_PORT}/api/health" | grep -q '"status"'; then
                        echo "Health check passed"
                        exit 0
                      fi
                      sleep 2
                    done
                    echo "Health check failed"
                    docker compose ps
                    docker compose logs --tail=100
                    exit 1
                '''
            }
        }
    }

    post {
        success {
            echo "Deployed Flask + PostgreSQL Two-Tier on this host."
        }
        failure {
            sh 'docker compose ps || true; docker compose logs --tail=200 || true'
        }
    }
}
