pipeline {
    agent none

    stages {
        stage ('SAST') {
            parallel {
                stage ('Semgrep') {
                    agent {
                        docker {
                            image "returntocorp/semgrep"
                            args  "-u root" // OR RUN mkdir /.semgrep && chmod -R 777 /.semgrep
                        }
                    }
                    steps {
                        sh "semgrep --config=auto --json -o semgrep_output.json ./src"
                    }
                }
                stage ('Gitleaks') {
                    agent {
                        docker {
                            image "zricethezav/gitleaks:latest"
                            args "--entrypoint=''"
                        }
                    }
                    steps {
                        sh 'gitleaks detect --source . -v'
                    }
                }
            }
        } 

        stage('Build Maven Project') {
            agent {
                docker {
                    image "maven:3.8.7-openjdk-18-slim"
                    args "--entrypoint=''"
                    }
                }
            steps {
                sh "mvn clean package && ls ./target"
            }
        }
        stage ('Build Docker Image') {
            agent any
                steps {
                    //sh "docker rmi -f vulnerablejavaappcontainer:*"
                    sh "docker build --no-cache -t vulnerablejavappcontainer:${env.BUILD_ID} ."
                    sh "docker images | grep vulnerablejavappcontainer"
                }
            }
        stage ('Trivy Scan') {
            agent {
                docker {
                    image "aquasec/trivy:0.36.1"
                    args "--entrypoint='' -u root -v /var/run/docker.sock:/var/run/docker.sock" // run as root to create /.cache directory; mount docker.sock to be able to scan container images in dind
                }
            }
            steps {
                sh "trivy image vulnerablejavappcontainer:${env.BUILD_ID}"
            }
        }


        stage('Test Carry over') {
            agent {
                docker {
                    image "maven:3.8.7-openjdk-18-slim"
                    args "--entrypoint=''"
                    }
                }
            steps {
                sh "hostname && id && ls"
            }
        }
    }
}