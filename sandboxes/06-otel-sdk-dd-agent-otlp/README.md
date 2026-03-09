# Sandbox 6: OTel SDK + DD Agent (OTLP Ingest)

## Architecture

```
Flask App --OTLP gRPC (4317)--> DD Agent (OTLP receiver) --> Datadog
```

## When to Use This Setup

- You want DD infrastructure features with a simple OTLP setup
- You don't need OTel Collector capabilities (routing, custom processors)
- You don't need DD-exclusive trace features (ASM, Profiler, DSM)
- Simple setup: DD Agent accepts OTLP natively

## Prerequisites

- Docker and Docker Compose
- A Datadog API key

## Quick Start

```bash
cp .env.example .env
# Edit .env and set DD_API_KEY
docker compose up --build
# In another terminal:
./generate-traffic.sh
```

Check [Datadog APM](https://app.datadoghq.com/apm/services) for service `sandbox-06-otel-dd-agent`.

## What's Running

| Container | Image | Purpose |
|-----------|-------|---------|
| app | Custom Flask (Python 3.12) | Instrumented with OTel SDK, sends OTLP to DD Agent |
| dd-agent | datadog/agent:7 | Accepts OTLP on port 4317/4318, forwards to Datadog |

## Key Configuration

- DD Agent has OTLP receiver enabled via `DD_OTLP_CONFIG_RECEIVER_PROTOCOLS_GRPC_ENDPOINT`
- App uses standard OTel SDK with OTLP gRPC exporter pointing to `dd-agent:4317`
- DD Agent also provides infrastructure monitoring (containers, processes)

## Cleanup

```bash
docker compose down -v
```
