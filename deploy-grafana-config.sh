#!/bin/bash

NAMESPACE="monitoring"
GRAFANA_DEPLOYMENT=$(kubectl get deployment -n $NAMESPACE -l app.kubernetes.io/name=grafana -o name)

if [ -z "$GRAFANA_DEPLOYMENT" ]; then
    echo "Error: Grafana deployment not found in namespace $NAMESPACE"
    exit 1
fi

echo "Applying Grafana sidecar patch..."
kubectl patch $GRAFANA_DEPLOYMENT -n $NAMESPACE --patch-file Grafana/patch.yaml

echo "Creating Alerting ConfigMaps..."
kubectl create configmap grafana-alert-rules -n $NAMESPACE --from-file=Grafana/alert-rules-v2.yaml --dry-run=client -o yaml | kubectl label -f - --local grafana_alerting="1" -o yaml | kubectl apply -f -
kubectl create configmap grafana-contact-points -n $NAMESPACE --from-file=Grafana/contact-points.yaml --dry-run=client -o yaml | kubectl label -f - --local grafana_alerting="1" -o yaml | kubectl apply -f -
kubectl create configmap grafana-notification-policies -n $NAMESPACE --from-file=Grafana/policies.yaml --dry-run=client -o yaml | kubectl label -f - --local grafana_alerting="1" -o yaml | kubectl apply -f -

echo "Creating Dashboard ConfigMaps..."
kubectl create configmap grafana-dashboard-health -n $NAMESPACE --from-file="Grafana/Status Page Health - yoav vaknin-1772636668495.json" --dry-run=client -o yaml | kubectl label -f - --local grafana_dashboard="1" -o yaml | kubectl apply -f -
kubectl create configmap grafana-dashboard-health-logs -n $NAMESPACE --from-file="Grafana/Status Page Health with logs- yoav vaknin -1773659040498.json" --dry-run=client -o yaml | kubectl label -f - --local grafana_dashboard="1" -o yaml | kubectl apply -f -

echo "Restarting Grafana to pick up changes..."
kubectl rollout restart $GRAFANA_DEPLOYMENT -n $NAMESPACE

echo "Grafana configuration deployed successfully!"
