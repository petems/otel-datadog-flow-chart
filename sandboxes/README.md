# OTel + Datadog Sandbox Environments

Six runnable sandbox environments demonstrating different OpenTelemetry setup types with Datadog.

## Prerequisites

- Docker and Docker Compose
- A [Datadog API key](https://app.datadoghq.com/organization-settings/api-keys)
- [envchain](https://github.com/sorah/envchain) for secure secret management
- For K8s sandboxes (03, 05): `minikube`, `helm`, `kubectl`

## Quick Start

1. Store your API key once: `envchain --set datadog DD_API_KEY`
2. Run a sandbox with `envchain datadog` prefix (see commands below)
3. Generate traffic: `./generate-traffic.sh`
4. Check [Datadog APM](https://app.datadoghq.com/apm/services) for traces

## Sandboxes

| # | Setup Type | SDK | Infrastructure | Command |
|---|-----------|-----|----------------|---------|
| 01 | [OTel SDK + OSS Collector](./01-otel-sdk-oss-collector/) | OTel SDK | Docker Compose | `envchain datadog docker compose up --build` |
| 02 | [Direct OTLP Ingest](./02-direct-otlp-ingest/) | OTel SDK | Docker Compose | `envchain datadog docker compose up --build` |
| 03 | [DD SDK + DDOT](./03-dd-sdk-ddot-k8s/) (Recommended) | ddtrace | Minikube + Helm | `envchain datadog bash setup-minikube.sh` |
| 04 | [DD SDK + DD Agent](./04-dd-sdk-dd-agent/) | ddtrace | Docker Compose | `envchain datadog docker compose up --build` |
| 05 | [OTel SDK + DDOT](./05-otel-sdk-ddot-k8s/) | OTel SDK | Minikube + Helm | `envchain datadog bash setup-minikube.sh` |
| 06 | [OTel SDK + DD Agent OTLP](./06-otel-sdk-dd-agent-otlp/) | OTel SDK | Docker Compose | `envchain datadog docker compose up --build` |

## Feature Compatibility

| Feature | 03 DD+DDOT | 04 DD+Agent | 05 OTel+DDOT | 01 OTel+Collector | 06 OTel+Agent | 02 Direct |
|---------|:---:|:---:|:---:|:---:|:---:|:---:|
| Distributed Tracing | Y | Y | Y | Y | Y | Y |
| Correlated Traces/Metrics/Logs | Y | Y | Y | Y | Y | Y |
| Runtime Metrics | Y | Y | Partial | Partial | Partial | Partial |
| Infrastructure Host List | Y | Y | Y | Y | Y | - |
| Continuous Profiler | Y | Y | - | - | - | - |
| App & API Protection | Y | Y | - | - | - | - |
| Data Streams Monitoring | Y | Y | - | - | - | - |

See the [full feature matrix](../otel-setup-flowchart.md#feature-compatibility-matrix) for details.

## Architecture Comparison

```
Sandbox 01: App --OTLP--> OTel Collector --DD Exporter--> Datadog
Sandbox 02: App --OTLP HTTP--> Datadog API (direct)
Sandbox 03: App --DD Protocol--> DDOT (K8s) --> Datadog
Sandbox 04: App --DD Protocol--> DD Agent --> Datadog
Sandbox 05: App --OTLP--> DDOT (K8s) --> Datadog
Sandbox 06: App --OTLP--> DD Agent (OTLP receiver) --> Datadog
```
