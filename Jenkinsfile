pipeline {
    agent none
    stages {

        stage ('Semgrep Scan') {
            agent {
                docker {
                    image 'returntocorp/semgrep'
                    args "--entrypoint='semgrep --config=auto ./src'"
                }
            }
        }

        stage('Build') {
            agent {
                docker {
                    image 'maven:3.8.7-openjdk-18-slim'
                    args "--entrypoint=''"
                    }
                }
            steps {
                sh 'mvn clean package && ls ./target'
            }
        }

        stage('Test Carry over') {
            agent {
                docker {
                    image 'maven:3.8.7-openjdk-18-slim'
                    args "--entrypoint=''"
                    }
                }
            steps {
                sh 'hostname && id && ls'
            }
        }
    }
}