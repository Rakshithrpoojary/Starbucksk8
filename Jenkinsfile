pipeline {
    agent any
    tools {
        nodejs 'node17'
    }
    environment {
        SCANNER_HOME = tool 'sonar-scanner'
        DOCKERUSERNAME = 'rakshithrpoojary'
        IMAGE_NAME = 'rakshithrpoojary/starbucks'
        IMAGE_TAG = "${BUILD_NUMBER}"
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
            steps {
                git branch: 'main', url: 'https://github.com/Rakshithrpoojary/Starbucksk8.git'
            }
        }
        stage('Sonar analysis')
        {
            steps {
                withSonarQubeEnv('sonarqube') {
                    sh ''' $SCANNER_HOME/bin/sonar-scanner -Dsonar.projectName=starbucks \
                    -Dsonar.projectKey=starbucks -Dsonar.exclusions=Imps/**,scripts/**,scriptsnew/**'''
                }
            }
        }
        stage('Quality gate')
        {
            steps {
                waitForQualityGate(abortPipeline: false, credentialsId: 'sonar-cred')
            }
        }
        stage('Install packages')
        {
            steps {
                sh 'npm install'
            }
        }
        stage('Trivy scanner')
        {
            steps {
                sh 'trivy fs . > trivy.txt'
            }
        }
        stage('prepare docker image')
        {
            steps {
                sh'docker build -t starbucks .'
            }
        }
        stage('Push docker image to docker hub')
        {
            steps {
                withDockerRegistry(credentialsId: 'docker-cred', url:'https://index.docker.io/v1/') {
                    sh ''' docker tag starbucks  ${DOCKERUSERNAME}/starbucks:${BUILD_NUMBER}
                     docker push ${DOCKERUSERNAME}/starbucks:${BUILD_NUMBER}
                     docker run -d --name starbucks-${BUILD_NUMBER} -p 3000:3000 ${DOCKERUSERNAME}/starbucks:${BUILD_NUMBER}
                    '''
                }
            }
        }
        stage('Update Deployment YAML file') {
            steps {
                sh """
          sed -i 's|image: .*|image: $IMAGE_NAME:$IMAGE_TAG|g' k8/manifest.yaml
        """
            }
        }

        stage('Commit & Push to Git') {
            steps {
                withCredentials([gitUsernamePassword(credentialsId: 'git-cred', gitToolName: 'Default')]) {
                    sh """
          git config user.name "Rakshith"
          git config user.email "poojaryrakshith986@gmail.com"
          git add k8/manifest.yaml
          git commit -m "Update frontend image to $IMAGE_TAG [ci skip]"
          git push origin HEAD --push-option=ci.skip
        """
                }
            }
        }
    }
}
