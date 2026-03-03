pipeline {
    agent any
    environment {
        AWS_ACCOUNT_ID = '992382545251'
        AWS_REGION     = 'us-east-1'
        IMAGE_NAME     = 'yoav_project_ecr'
        IMAGE_TAG      = "${BUILD_NUMBER}" 
    }
    stages {
        stage('Build Docker Image') {
            steps {
                script {
                    sh "docker build -t ${IMAGE_NAME}:${IMAGE_TAG} ."
                }
            }
        }
        stage('Push to ECR') {
            steps {
                script {
                    sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
                    sh "docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${IMAGE_NAME}:${IMAGE_TAG}"
                    sh "docker push ${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${IMAGE_NAME}:${IMAGE_TAG}"
                }
            }
        }
        stage('Deploy to EKS') {
            steps {
                script {
                    sh "aws eks update-kubeconfig --name yoav-terraform-eks --region ${AWS_REGION}"
                    sh "kubectl set image deployment/status-page-app status-page-container=${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${IMAGE_NAME}:${IMAGE_TAG}"
                }
            }
        }
    }
}
