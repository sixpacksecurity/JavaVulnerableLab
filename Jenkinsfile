pipeline {
    agent none

    stages {
        stage ('SAST') {
            parallel {
                stage ('Semgrep') {
                    agent {
                        docker {
                            image 'returntocorp/semgrep'
                            args  '-u root' // OR RUN mkdir /.semgrep && chmod -R 777 /.semgrep
                        }
                    }
                    steps {
                        sh 'semgrep --config=auto --json -o semgrep_output.json ./src'
                    }
                }
                stage {
                    steps {
                        sh 'docker images'
                    }
                }
                stage ('Trivy') {
                    agent {
                        docker {
                            image 'aquasec/trivy:0.36.1'
                            args "--entrypoint=''"
                        }
                    }
                    steps {
                        sh 'trivy image -i Dockerfile'
                    }
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