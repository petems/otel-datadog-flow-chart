#!/usr/bin/env bash
set -euo pipefail

command -v minikube >/dev/null || { echo "ERROR: minikube not installed"; exit 1; }
command -v helm >/dev/null || { echo "ERROR: helm not installed"; exit 1; }
command -v kubectl >/dev/null || { echo "ERROR: kubectl not installed"; exit 1; }

[ -z "${DD_API_KEY:-}" ] && { echo "ERROR: DD_API_KEY not set. Run: envchain datadog env DD_API_KEY"; exit 1; }

NAMESPACE="sandbox-05"
DD_SITE="${DD_SITE:-datadoghq.com}"

minikube start --driver=docker --cpus=4 --memory=4096

eval $(minikube docker-env)
docker build -t otel-flask-demo:latest ./app

helm repo add datadog https://helm.datadoghq.com
helm repo update

kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret generic datadog-secret \
    --from-literal=api-key="$DD_API_KEY" \
    -n "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

helm upgrade --install datadog datadog/datadog \
    -n "$NAMESPACE" \
    -f helm-values/datadog-values.yaml \
    --set "datadog.site=$DD_SITE"

echo "Waiting for Datadog Agent pods to be ready..."
kubectl rollout status daemonset/datadog -n "$NAMESPACE" --timeout=120s || true

kubectl apply -f k8s/ -n "$NAMESPACE"
kubectl rollout status deployment/otel-flask-demo -n "$NAMESPACE" --timeout=60s

echo ""
echo "Setup complete! To access the app:"
echo "  kubectl port-forward -n $NAMESPACE svc/otel-flask-demo 8080:8080"
echo "Then run: ./generate-traffic.sh"
