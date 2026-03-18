pipeline {
    agent any
    environment {
    AWS_ACCOUNT_ID = '992382545251'
    AWS_REGION     = 'us-east-1'
    IMAGE_NAME     = 'yoav_project_ecr'
    IMAGE_TAG      = "${BUILD_NUMBER}"
    AWS_ACCESS_KEY_ID     = credentials('aws-creds') 
    AWS_SECRET_ACCESS_KEY = credentials('aws-creds')
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
                withAWS(credentials: 'aws-creds', region: 'us-east-1') {
                    script {
                        sh "aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 992382545251.dkr.ecr.us-east-1.amazonaws.com"
                        sh "docker tag yoav_project_ecr:${BUILD_NUMBER} 992382545251.dkr.ecr.us-east-1.amazonaws.com/yoav_project_ecr:${BUILD_NUMBER}"
                        sh "docker push 992382545251.dkr.ecr.us-east-1.amazonaws.com/yoav_project_ecr:${BUILD_NUMBER}"
                    }
                }
            }
        }
        stage('Deploy to EKS') {
            steps {
                script {
                    sh "aws eks update-kubeconfig --name yoav-terraform-eks --region ${AWS_REGION}"
                    def fullImage = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${IMAGE_NAME}:${IMAGE_TAG}"
                    sh "kubectl set image deployment/status-page-app status-page-container=${fullImage}"
                    sh "kubectl set image deployment/status-page-worker worker-container=${fullImage}"
                    sh "kubectl set image deployment/status-page-scheduler scheduler-container=${fullImage}"
                    
                    sh "kubectl rollout status deployment/status-page-app"
                    sh "kubectl rollout status deployment/status-page-worker"
                    sh "kubectl rollout status deployment/status-page-scheduler"
                }
            }
        }
    }
}
