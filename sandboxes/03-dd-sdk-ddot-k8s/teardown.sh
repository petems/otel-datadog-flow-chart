#!/usr/bin/env bash
set -euo pipefail

NAMESPACE="sandbox-03"

echo "Tearing down Sandbox 3..."
kubectl delete -f k8s/ -n "$NAMESPACE" 2>/dev/null || true
helm uninstall datadog -n "$NAMESPACE" 2>/dev/null || true
kubectl delete namespace "$NAMESPACE" 2>/dev/null || true
minikube stop 2>/dev/null || true
echo "Teardown complete."
