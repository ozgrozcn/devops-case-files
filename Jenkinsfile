def versionController(imageVersion) {
    def versionParts = imageVersion.split("\\.")
    def majorPart = versionParts[0].toInteger()
    def minorPart = versionParts[1].toInteger()

    if (minorPart < 9) {
        minorPart++
    }
    else {
        majorPart++
        minorPart = 0
    }
    return "${majorPart}.${minorPart}"
}


pipeline {
    agent { label 'kube-master' }
    environment {
        IMAGE_NAME = 'ozguro/hello-world'
        DOCKER_HUB_CREDENTIALS = credentials('docker-hub')
        DEPLOYMENT_FILES_PATH = '/home/ubuntu/deployments'
        DEPLOYMENT_FILE_NAME = 'deployment.yaml'
    }
    stages {
        stage('build') {
            steps {
                sh 'cd hello-world-java/ && bash mvnw clean package'    
            }
        }
        stage('test') {
            steps {
                sh 'cd hello-world-java/ && bash mvnw test'                
            }
        }
        stage('build-image') {
            steps {
                script {
                LAST_IMAGE_VERSION = sh(
                    script: '/bin/bash -c "docker images \"${IMAGE_NAME}\":* | awk \'{print \\$2}\' | awk \'NR==2\'"',
                    returnStdout: true
                    ).trim()
                IMAGE_VERSION = versionController(LAST_IMAGE_VERSION)
                sh "docker build -f Dockerfile . -t ${IMAGE_NAME}:${IMAGE_VERSION}"  
                sh "docker login --username ${DOCKER_HUB_CREDENTIALS_USR} --password ${DOCKER_HUB_CREDENTIALS_PSW}"
                sh "docker push ${IMAGE_NAME}:${IMAGE_VERSION}"
                echo "PUSHED IMAGE: ${IMAGE_NAME}:${IMAGE_VERSION}"
                }
            }
        }
        stage('deploy'){
            steps {
                sh "sed -i 's|image:.*|image: ${IMAGE_NAME}:${IMAGE_VERSION}|' ${DEPLOYMENT_FILES_PATH}/${DEPLOYMENT_FILE_NAME}" 
                sh "kubectl apply -f ${DEPLOYMENT_FILES_PATH}/${DEPLOYMENT_FILE_NAME}"
            }
        }
    }
}
