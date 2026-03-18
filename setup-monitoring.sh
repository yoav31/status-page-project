#!/bin/bash

kubectl get namespace monitoring &>/dev/null
if [ $? -ne 0 ]; then
    echo "Creating namespace 'monitoring'..."
    kubectl create namespace monitoring
else
    echo "Namespace 'monitoring' already exists"
fi

echo "Adding prometheus-community Helm repo..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

helm status monitoring -n monitoring &>/dev/null
if [ $? -ne 0 ]; then
    echo "Installing kube-prometheus-stack..."
    helm install monitoring prometheus-community/kube-prometheus-stack --namespace monitoring
else
    echo "kube-prometheus-stack already installed, upgrading..."
    helm upgrade monitoring prometheus-community/kube-prometheus-stack --namespace monitoring
fi

echo "Waiting for Pods to be ready..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/instance=monitoring -n monitoring --timeout=300s

echo "Starting port-forward to Grafana (http://localhost:3000)..."
echo "Use CTRL+C to stop port-forwarding when done."
kubectl port-forward svc/monitoring-grafana 3000:80 -n monitoring