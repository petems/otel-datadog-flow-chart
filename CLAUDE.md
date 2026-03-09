# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

OTel Setup Decision Guide with 6 runnable sandbox environments demonstrating different OpenTelemetry + Datadog integration patterns. Each sandbox is a self-contained Python Flask app with the specific instrumentation and infrastructure for that setup type.

## Running Sandboxes

All sandboxes require `DD_API_KEY`. Copy `.env.example` to `.env` in the sandbox directory and set it.

```bash
# Docker Compose sandboxes (01, 02, 04, 06)
make sandbox-01  # OTel SDK + OSS Collector
make sandbox-02  # Direct OTLP Ingest
make sandbox-04  # DD SDK + DD Agent
make sandbox-06  # OTel SDK + DD Agent OTLP

# Kubernetes sandboxes (03, 05) - require minikube, helm, kubectl
make sandbox-03  # DD SDK + DDOT (recommended)
make sandbox-05  # OTel SDK + DDOT

# Cleanup
make down-01     # or down-02, down-03, etc.
make down-all
```

After starting a sandbox, run `./generate-traffic.sh` from within the sandbox directory to generate telemetry.

## Architecture

### Two App Variants

- **OTel SDK app** (`sandboxes/_shared/otel-app/`): Uses `opentelemetry-sdk` with programmatic `TracerProvider`, `MeterProvider`, `LoggerProvider` and OTLP exporters. Used by sandboxes 01, 02, 05, 06. Sandbox 02 uses the HTTP exporter variant instead of gRPC.
- **DD SDK app** (`sandboxes/_shared/dd-app/`): Uses `ddtrace` with `DD_TRACE_OTEL_ENABLED=true` for OTel API compatibility. Runs via `ddtrace-run`. Used by sandboxes 03, 04.

### Sandbox Structure

Each sandbox directory under `sandboxes/` is fully self-contained with its own copy of the app code (not symlinked from `_shared/`). Changes to a shared app should be propagated to each sandbox's `app/` directory manually.

### Key Files Per Sandbox Type

**Docker Compose** (01, 02, 04, 06): `docker-compose.yaml`, `app/`, `.env.example`, `generate-traffic.sh`
**Kubernetes** (03, 05): `setup-minikube.sh`, `teardown.sh`, `helm-values/datadog-values.yaml`, `k8s/`, `app/`

### Collector Config (Sandbox 01)

`otel-collector-config.yaml` uses the `datadog/connector` to compute APM stats (required since collector-contrib v0.108+). The traces pipeline exports to both the connector and the DD exporter; a separate `traces/stats` pipeline feeds connector stats to the exporter.

## Conventions

- Service names follow the pattern `sandbox-XX-<description>` (e.g., `sandbox-01-otel-collector`)
- K8s sandboxes use namespace `sandbox-XX` and Datadog unified service tags (`tags.datadoghq.com/*`)
- The flowchart documentation lives in `otel-setup-flowchart.md` using Mermaid syntax
