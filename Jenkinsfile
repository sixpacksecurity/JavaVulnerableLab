pipeline {
    agent {
        docker {
            image 'ubuntu'
            args "--entrypoint=''"
        }
    }
    stages {

        stage('Initialize') {
            steps {
                sh '''
                    sudo apt update && sudo apt upgrade -y
                    sudo apt install maven openjdk-18-jdk -y
                '''
            }
        }

        stage('Build') {
            steps {
                sh 'mvn clean package && ls ./target'
            }
        }
    }
}