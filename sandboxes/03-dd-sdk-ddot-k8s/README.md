# Sandbox 3: DD SDK + DDOT (Recommended)

## Architecture

```
Flask App --DD Protocol (8126)--> DDOT (Datadog Agent + OTel Collector) --> Datadog
                                      |
                                      +-- Also accepts OTLP on 4317/4318
```

## When to Use This Setup

- You're running Linux-based Kubernetes
- You want the full Datadog feature set (ASM, Profiler, DSM, RUM, etc.)
- You want OTel Collector capabilities built into the agent
- You want vendor-neutral code via the OTel API

This is the **recommended** setup for most customers.

## Prerequisites

- Docker, minikube, helm, kubectl
- A Datadog API key stored via [envchain](https://github.com/sorah/envchain): `envchain --set datadog DD_API_KEY`

## Quick Start

```bash
envchain datadog bash setup-minikube.sh
# Set up port-forward:
kubectl port-forward -n sandbox-03 svc/dd-flask-demo 8080:8080
# In another terminal:
./generate-traffic.sh
```

Check [Datadog APM](https://app.datadoghq.com/apm/services) for service `sandbox-03-dd-ddot`.

## What's Running

| Component | Image | Purpose |
|-----------|-------|---------|
| dd-flask-demo | Custom Flask (Python 3.12) | Instrumented with ddtrace + OTel API |
| datadog (DaemonSet) | datadog/agent:7.65.0 | DDOT: DD Agent with embedded OTel Collector |

## Key Configuration

- `helm-values/datadog-values.yaml` -- Enables DDOT with `otelCollector.enabled: true`
- `k8s/app-deployment.yaml` -- App deployment with DD unified service tagging
- App uses `ddtrace-run` and `DD_TRACE_OTEL_ENABLED=true` for OTel API compatibility

## Cleanup

```bash
bash teardown.sh
```
