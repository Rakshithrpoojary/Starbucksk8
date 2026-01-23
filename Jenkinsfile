pipeline {
    agent any
    tools {
        nodejs 'node17'
    }
    environments {
        SCANNER_HOME = tool 'sonar-scanner'
        DOCKERUSERNAME = 'rakshithrpoojary'
    }
    stages {
        stage('Clean workspace')
        {
            steps {
                cleanWs()
            }
        }
        stage('Checkout git')
        {
            step {
                git branch: 'main', url: 'https://github.com/Rakshithrpoojary/Starbucksk8.git'
            }
        }
        stage('Sonar analysis')
        {
            step {
                withSonarQubeEnv(credentialsId: 'sonar-cred') {
                    sh ''' $SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=starbucks \
                    -Dsonar.projectKey=starbucks -Dsonar.exclusions=Imps/**,scripts/**,scriptsnew/**'''
                }
            }
        }
        stage('Quality gate')
        {
            step {
                waitForQualityGate(abortPipeline: false, credentialsId: 'sonar-cred')
            }
        }
        stage('Install packages')
        {
            step {
                sh 'npm install'
            }
        }
        stage('Trivy scanner')
        {
            step {
                'trivy fs . > trivy.txt'
            }
        }
        stage('prepare docker image')
        {
            step {
                sh'docker build -t starbucks .'
            }
        }
        stage('Push docker image to docker hub')
        {
            step {
                withDockerRegistry(credentialsId: 'docker-cred-system') {
                    sh ''' docker tag starbucks  ${DOCKERUSERNAME}/starbucks:${BUILD_NUMBER}
                     docker push ${DOCKERUSERNAME}/starbucks:${BUILD_NUMBER}
                     docker run -d --name starbucks-${BUILD_NUMBER} -p 3000:3000 ${DOCKERUSERNAME}/starbucks:${BUILD_NUMBER}
                    '''
                }
            }
        }
    }
}
