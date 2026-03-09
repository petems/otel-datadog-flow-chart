# OTel Setup Decision Guide & Sandbox Environments

A decision flowchart and six runnable sandbox environments demonstrating different OpenTelemetry integration patterns with Datadog. 

Helps customers choose the right OTel setup based on their requirements, then try it hands-on.

## Decision Flowchart

See [`otel-setup-flowchart.md`](./otel-setup-flowchart.md) for an interactive Mermaid flowchart that guides you through five questions to determine the best setup type. The flowchart covers:

- Whether to keep an existing OTel Collector pipeline
- Whether to avoid deploying any infrastructure
- Whether Datadog advanced features are needed (ASM, Profiler, DSM, RUM)
- Whether to adopt Datadog tracing libraries
- Whether OTel Collector capabilities are needed alongside the DD Agent

## Sandbox Environments

Six self-contained environments you can spin up to see each setup in action. Each sandbox includes a Python Flask app with traces, metrics, and logs.

| # | Setup Type | SDK | Infrastructure | Compatibility |
|---|-----------|-----|----------------|:---:|
| [01](./sandboxes/01-otel-sdk-oss-collector/) | OTel SDK + OSS Collector + DD Exporter | OTel SDK | Docker Compose | Partial |
| [02](./sandboxes/02-direct-otlp-ingest/) | Direct OTLP Ingest to Datadog | OTel SDK | Docker Compose | Minimal |
| [03](./sandboxes/03-dd-sdk-ddot-k8s/) | DD SDK + DDOT (Recommended) | ddtrace | Minikube + Helm | Full |
| [04](./sandboxes/04-dd-sdk-dd-agent/) | DD Tracing Libraries + DD Agent | ddtrace | Docker Compose | Full |
| [05](./sandboxes/05-otel-sdk-ddot-k8s/) | OTel SDK + DDOT | OTel SDK | Minikube + Helm | High |
| [06](./sandboxes/06-otel-sdk-dd-agent-otlp/) | OTel SDK + DD Agent (OTLP Ingest) | OTel SDK | Docker Compose | High |

### Architecture Overview

```
Sandbox 01: App ──OTLP──▶ OTel Collector ──DD Exporter──▶ Datadog
Sandbox 02: App ──OTLP HTTP──▶ Datadog API (direct)
Sandbox 03: App ──DD Protocol──▶ DDOT (K8s) ──▶ Datadog      ⭐ Recommended
Sandbox 04: App ──DD Protocol──▶ DD Agent ──▶ Datadog
Sandbox 05: App ──OTLP──▶ DDOT (K8s) ──▶ Datadog
Sandbox 06: App ──OTLP──▶ DD Agent (OTLP receiver) ──▶ Datadog
```

## Prerequisites

- Docker and Docker Compose
- A [Datadog API key](https://app.datadoghq.com/organization-settings/api-keys)
- For K8s sandboxes (03, 05): [minikube](https://minikube.sigs.k8s.io/), [helm](https://helm.sh/), [kubectl](https://kubernetes.io/docs/tasks/tools/)

## Quick Start

```bash
# 1. Pick a sandbox and navigate to it
cd sandboxes/06-otel-sdk-dd-agent-otlp

# 2. Set up your API key
cp .env.example .env
# Edit .env and set DD_API_KEY

# 3. Start the sandbox
docker compose up --build

# 4. Generate traffic (in another terminal)
./generate-traffic.sh

# 5. Check Datadog APM for traces
# https://app.datadoghq.com/apm/services
```

Or use the Makefile from the project root:

```bash
export DD_API_KEY=your_key_here
make sandbox-06    # or sandbox-01, sandbox-02, etc.
make down-06       # cleanup
```

For K8s sandboxes:

```bash
cd sandboxes/03-dd-sdk-ddot-k8s
cp .env.example .env
# Edit .env and set DD_API_KEY
bash setup-minikube.sh
kubectl port-forward -n sandbox-03 svc/dd-flask-demo 8080:8080
./generate-traffic.sh
# Cleanup:
bash teardown.sh
```

## Feature Compatibility Matrix

Based on the [Datadog OTel Feature Compatibility](https://docs.datadoghq.com/opentelemetry/compatibility/#feature-compatibility) documentation.

| Feature | DD SDK + DDOT | OTel SDK + DDOT | OTel SDK + OSS Collector | Direct OTLP |
|---|:---:|:---:|:---:|:---:|
| Distributed Tracing | Y | Y | Y | Y |
| Correlated Traces/Metrics/Logs | Y | Y | Y | Y |
| LLM Observability | Y | Y | Y | Y |
| Runtime Metrics | Y | Partial | Partial | Partial |
| Infrastructure Host List | Y | Y | Y | - |
| DB Monitoring | Y | Y | - | - |
| Live Containers / K8s | Y | Y | - | - |
| App & API Protection | Y | - | - | - |
| Continuous Profiler | Y | - | - | - |
| Data Streams Monitoring | Y | - | - | - |
| RUM | Y | - | - | - |
| Source Code Integration | Y | - | - | - |

**Key takeaway:** DD SDK + DDOT is the only setup providing the complete Datadog feature set with OTel Collector capabilities. DD-exclusive features (ASM, Profiler, DSM, RUM) require Datadog tracing libraries.

## Project Structure

```
├── otel-setup-flowchart.md          # Decision flowchart (Mermaid)
├── Makefile                          # Convenience targets for all sandboxes
├── sandboxes/
│   ├── _shared/                      # Reference app templates
│   │   ├── otel-app/                 # OTel SDK Flask app (sandboxes 01,02,05,06)
│   │   ├── dd-app/                   # DD SDK Flask app (sandboxes 03,04)
│   │   └── generate-traffic.sh
│   ├── 01-otel-sdk-oss-collector/
│   ├── 02-direct-otlp-ingest/
│   ├── 03-dd-sdk-ddot-k8s/
│   ├── 04-dd-sdk-dd-agent/
│   ├── 05-otel-sdk-ddot-k8s/
│   └── 06-otel-sdk-dd-agent-otlp/
```

Each sandbox is self-contained with its own app code, Docker/K8s configs, and README.
