#!/bin/bash
set -euo pipefail

AWS_ACCOUNT_ID=<YOUR_AWS_ACCOUNT_ID>
REGION="us-east-1"
ECR_REPOSITORY=<YOUR_ECR_REPOSITORY_NAME>
ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${REGION}.amazonaws.com"
EKS_CLUSTER_NAME=<YOUR_EKS_CLUSTER_NAME>

echo "🔍 Checking latest tag in ECR..."
LATEST_TAG=$(aws ecr describe-images \
  --repository-name "$ECR_REPOSITORY" \
  --region "$REGION" \
  --query 'sort_by(imageDetails, &imagePushedAt)[-1].imageTags[0]' \
  --output text 2>/dev/null || echo "v0")

if [[ "$LATEST_TAG" =~ ^v[0-9]+$ ]]; then
    CURRENT_VERSION=${LATEST_TAG#v}
else
    CURRENT_VERSION=0
fi

NEW_VERSION=$((CURRENT_VERSION + 1))
TAG="v$NEW_VERSION"
FULL_IMAGE="${ECR_REGISTRY}/${ECR_REPOSITORY}:${TAG}"

echo "Latest tag: $LATEST_TAG -> New tag: $TAG"

VALUES_FILE="terraform/charts/statuspage-chart/values.yaml"
if [ -f "$VALUES_FILE" ]; then
    sed -i "s/tag: \".*\"/tag: \"$TAG\"/" "$VALUES_FILE"
    echo "Updated $VALUES_FILE with tag $TAG"
fi

# --- Build & Push ---
echo "Building Docker image..."
docker build -f status-page/Dockerfile -t statuspage-app:$TAG ./status-page/

echo "Tagging image..."
docker tag statuspage-app:$TAG $FULL_IMAGE

echo "Logging in to ECR..."
aws ecr get-login-password --region $REGION | docker login --username AWS --password-stdin $ECR_REGISTRY

echo "Pushing to ECR..."
docker push $FULL_IMAGE

echo "Starting Deployment to EKS..."

aws eks update-kubeconfig --name $EKS_CLUSTER_NAME --region $REGION

echo "Applying Kubernetes manifests from EKS-deployments-files..."
kubectl apply -f EKS-deployments-files/

echo "Updating Kubernetes deployments to image: $TAG"

kubectl set image deployment/status-page-app status-page-container=$FULL_IMAGE
kubectl set image deployment/status-page-worker worker-container=$FULL_IMAGE
kubectl set image deployment/status-page-scheduler scheduler-container=$FULL_IMAGE

echo "Waiting for rollout to complete..."
kubectl rollout status deployment/status-page-app --timeout=90s
kubectl rollout status deployment/status-page-worker --timeout=90s
kubectl rollout status deployment/status-page-scheduler --timeout=90s

echo "Deployment Successful! Version: $TAG"