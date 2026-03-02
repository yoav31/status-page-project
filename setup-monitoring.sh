#!/bin/bash

# סקריפט התקנה אוטומטי ל-monitoring ב-Kubernetes

# 1️⃣ יצירת namespace אם לא קיים
kubectl get namespace monitoring &>/dev/null
if [ $? -ne 0 ]; then
    echo "Creating namespace 'monitoring'..."
    kubectl create namespace monitoring
else
    echo "Namespace 'monitoring' already exists"
fi

# 2️⃣ הוספת repo של Helm
echo "Adding prometheus-community Helm repo..."
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update

# 3️⃣ התקנת kube-prometheus-stack אם לא מותקן
helm status monitoring -n monitoring &>/dev/null
if [ $? -ne 0 ]; then
    echo "Installing kube-prometheus-stack..."
    helm install monitoring prometheus-community/kube-prometheus-stack --namespace monitoring
else
    echo "kube-prometheus-stack already installed, upgrading..."
    helm upgrade monitoring prometheus-community/kube-prometheus-stack --namespace monitoring
fi

# 4️⃣ מחכה שכל ה-Pods יתחילו
echo "Waiting for Pods to be ready..."
kubectl wait --for=condition=ready pod -l app.kubernetes.io/instance=monitoring -n monitoring --timeout=300s

# 5️⃣ Port-forward ל-Grafana
echo "Starting port-forward to Grafana (http://localhost:3000)..."
echo "Use CTRL+C to stop port-forwarding when done."
kubectl port-forward svc/monitoring-grafana 3000:80 -n monitoring