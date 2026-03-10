# Sandbox 5: OTel SDK + DDOT

## Architecture

```
Flask App --OTLP gRPC (4317)--> DDOT (Datadog Agent + OTel Collector) --> Datadog
```

## When to Use This Setup

- You're running Linux-based Kubernetes
- You need OTel Collector capabilities alongside the DD Agent
- You don't need DD-exclusive trace features (ASM, Profiler, DSM)
- You want a single agent deployment (DDOT combines DD Agent + OTel Collector)

## Prerequisites

- Docker, minikube, helm, kubectl
- A Datadog API key stored via [envchain](https://github.com/sorah/envchain): `envchain --set datadog DD_API_KEY`

## Quick Start

```bash
envchain datadog bash setup-minikube.sh
# Set up port-forward:
kubectl port-forward -n sandbox-05 svc/otel-flask-demo 8080:8080
# In another terminal:
./generate-traffic.sh
```

Check [Datadog APM](https://app.datadoghq.com/apm/services) for service `sandbox-05-otel-ddot`.

## What's Running

| Component | Image | Purpose |
|-----------|-------|---------|
| otel-flask-demo | Custom Flask (Python 3.12) | Instrumented with OTel SDK, sends OTLP to DDOT |
| datadog (DaemonSet) | datadog/agent:7.65.0 | DDOT: DD Agent with embedded OTel Collector |

## Key Configuration

- `helm-values/datadog-values.yaml` -- Enables DDOT with `otelCollector.enabled: true`
- `k8s/app-deployment.yaml` -- App sends OTLP to `$(NODE_IP):4317` (DDOT DaemonSet)
- App uses standard OTel SDK with OTLP gRPC exporter

## Cleanup

```bash
bash teardown.sh
```
