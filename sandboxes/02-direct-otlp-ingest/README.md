# Sandbox 2: Direct OTLP Ingest to Datadog

## Architecture

```
Flask App --OTLP HTTP--> Datadog API (direct, no agent or collector)
```

## When to Use This Setup

- You want zero infrastructure to manage
- You want the fastest time-to-value
- You accept the most limited Datadog feature set
- No infrastructure-level visibility needed

## Prerequisites

- Docker and Docker Compose
- A Datadog API key

> **Note:** Direct OTLP traces ingest may be in Preview and require enablement on your Datadog account. Metrics and logs direct ingest are GA.

## Quick Start

```bash
cp .env.example .env
# Edit .env and set DD_API_KEY
docker compose up --build
# In another terminal:
./generate-traffic.sh
```

Check [Datadog APM](https://app.datadoghq.com/apm/services) for service `sandbox-02-direct-otlp`.

## What's Running

| Container | Image | Purpose |
|-----------|-------|---------|
| app | Custom Flask (Python 3.12) | Instrumented with OTel SDK, sends OTLP HTTP directly to Datadog |

This is the simplest sandbox -- a single container with no collector or agent.

## Key Configuration

- The app uses `opentelemetry-exporter-otlp-proto-http` (HTTP, not gRPC)
- `OTEL_EXPORTER_OTLP_ENDPOINT` points directly to Datadog's OTLP intake
- `OTEL_EXPORTER_OTLP_HEADERS` includes the `DD-API-KEY` header

## Cleanup

```bash
docker compose down -v
```
