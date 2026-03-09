# Sandbox 1: OTel SDK + OSS Collector with DD Exporter

## Architecture

```
Flask App --OTLP gRPC--> OTel Collector (contrib) --DD Exporter--> Datadog
                              |
                              +-- datadog/connector (computes APM stats)
```

## When to Use This Setup

- You want a fully vendor-neutral pipeline
- You already have an OTel Collector deployment
- You don't need DD-exclusive features (ASM, Profiler, DSM, etc.)

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

Check [Datadog APM](https://app.datadoghq.com/apm/services) for service `sandbox-01-otel-collector`.

## What's Running

| Container | Image | Purpose |
|-----------|-------|---------|
| app | Custom Flask (Python 3.12) | Instrumented with OTel SDK, sends OTLP to collector |
| otel-collector | otel/opentelemetry-collector-contrib:0.120.0 | Receives OTLP, exports to Datadog via DD exporter |

## Key Configuration

- `otel-collector-config.yaml` -- Collector pipeline with DD exporter + connector for APM stats
- `app/app.py` -- Flask app with OTel SDK instrumentation (traces, metrics, logs)

## Cleanup

```bash
docker compose down -v
```
