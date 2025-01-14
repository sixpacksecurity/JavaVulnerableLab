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
                        sh "export SEMGREP_BASELINE_REF=${env.GIT_COMMIT}; echo \$SEMGREP_BASELINE_REF"
                        sh "SEMGREP_BASELINE_REF=${env.GIT_COMMIT} semgrep --config=auto --json -o semgrep_output.json ./src"
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
                        sh 'gitleaks detect --source . -v --log-opts "-p -n 1"'
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
                    //sh "docker rmi -f \$(docker images | grep 'vulnerablejavappcontainer')" //remove older images to save space. Don't need them for demo. Escaping via \
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

        stage ('Publish Image') {
            agent {
                docker {
                    image "amazon/aws-cli"
                    args "--entrypoint='' -u root -v /var/run/docker.sock:/var/run/docker.sock"
                }
            }
            environment {
                AWS_ACCESS_KEY_ID     = credentials('jenkins-aws-secret-key-id')
                AWS_SECRET_ACCESS_KEY = credentials('jenkins-aws-secret-access-key')
            }
            steps { // instead of running as root and installing dependencies, we could also use docker as a build agent 
                sh 'yum update; yum install tar gzip -y'
                sh 'curl https://download.docker.com/linux/static/stable/x86_64/docker-20.10.9.tgz -o docker-20.10.9.tgz -s'
                sh 'tar -xzvf docker-20.10.9.tgz'
                sh 'chmod +x ./docker/docker && cp ./docker/docker /usr/bin'
                sh "aws ecr get-login-password --region ap-southeast-1 | docker login --username AWS --password-stdin 662411289471.dkr.ecr.ap-southeast-1.amazonaws.com"
                sh "docker tag vulnerablejavappcontainer:${env.BUILD_ID} 662411289471.dkr.ecr.ap-southeast-1.amazonaws.com/vulnerablejavapp-testrepository:${env.BUILD_ID}"
                sh "docker push 662411289471.dkr.ecr.ap-southeast-1.amazonaws.com/vulnerablejavapp-testrepository:${env.BUILD_ID}"
                sh "docker rmi -f vulnerablejavappcontainer:${env.BUILD_ID} 662411289471.dkr.ecr.ap-southeast-1.amazonaws.com/vulnerablejavapp-testrepository:${env.BUILD_ID}" //removing both the image builds from dind after pushing to ecr
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
