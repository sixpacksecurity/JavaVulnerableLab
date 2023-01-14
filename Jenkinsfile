pipeline {
    agent {
        docker {
            image 'maven:3.8.7-openjdk-18-slim'
            args "--entrypoint=''"
        }
    }
    stages {
        stage('Initialize and Build') {
            steps {
                sh 'mvn clean package && ls ./target'
            }
        }
    }
}