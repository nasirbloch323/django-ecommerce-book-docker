pipeline {
    agent any

    environment {
        // har branch ka apna alag project name taake containers clash na karein
        COMPOSE_PROJECT_NAME = "book-ecom-${env.BRANCH_NAME}"
        IMAGE_NAME            = "django-ecommerce-book:${env.BRANCH_NAME}"
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timestamps()
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
                echo "Building branch: ${env.BRANCH_NAME}"
            }
        }

        stage('Build Image') {
            steps {
                sh 'docker compose build'
            }
        }

        stage('Django Checks (dev branch)') {
            when {
                branch 'dev'
            }
            steps {
                // container start kar ke basic django checks / migrations dry-run karte hain
                sh '''
                    docker compose run --rm web python3 manage.py check
                    docker compose run --rm web python3 manage.py makemigrations books --check --dry-run
                    docker compose run --rm web python3 manage.py makemigrations accounts --check --dry-run
                '''
            }
            post {
                always {
                    sh 'docker compose down --remove-orphans || true'
                }
            }
        }

        stage('Deploy (master only)') {
            when {
                branch 'master'
            }
            steps {
                echo 'Deploying web container on master branch...'
                sh '''
                    docker compose down --remove-orphans || true
                    docker compose up -d
                '''
            }
        }

        stage('Health Check (master only)') {
            when {
                branch 'master'
            }
            steps {
                // container up hone ke baad thora wait karke port check karte hain
                sh '''
                    sleep 8
                    curl -f http://localhost:8000 || echo "WARNING: app not responding on port 8000"
                '''
            }
        }
    }

    post {
        always {
            echo "Pipeline finished for branch: ${env.BRANCH_NAME}"
        }
        success {
            echo 'Build successful ✅'
        }
        failure {
            echo 'Build failed ❌'
            sh 'docker compose down --remove-orphans || true'
        }
    }
}
