# Sandbox 4: DD Tracing Libraries (w/ OTel API) + DD Agent

## Architecture

```
Flask App --DD Protocol (8126)--> DD Agent --> Datadog
```

## When to Use This Setup

- You want the full Datadog feature set
- You're NOT on Linux Kubernetes (so DDOT isn't available)
- You want vendor-neutral code via the OTel API

## Prerequisites

- Docker and Docker Compose
- A Datadog API key stored via [envchain](https://github.com/sorah/envchain): `envchain --set datadog DD_API_KEY`

## Quick Start

```bash
envchain datadog docker compose up --build
# In another terminal:
./generate-traffic.sh
```

Check [Datadog APM](https://app.datadoghq.com/apm/services) for service `sandbox-04-dd-agent`.

## What's Running

| Container | Image | Purpose |
|-----------|-------|---------|
| app | Custom Flask (Python 3.12) | Instrumented with ddtrace + OTel API |
| dd-agent | datadog/agent:7 | Receives traces on port 8126, forwards to Datadog |

## Key Configuration

- App uses `ddtrace-run` with `DD_TRACE_OTEL_ENABLED=true` for OTel API compatibility
- Custom spans use `opentelemetry.trace.get_tracer()` (vendor-neutral, routed through ddtrace)
- DD Agent has APM, logs, and process collection enabled

## Cleanup

```bash
docker compose down -v
```
