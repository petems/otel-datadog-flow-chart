# OTel Setup Decision Flowchart

Use this flowchart to determine which OpenTelemetry setup type best fits a customer's requirements and constraints.

```mermaid
flowchart TD
    Start([🏁 START: Customer wants OTel<br/>with Datadog])
    Start --> Q1

    Q1{Q1: Does the customer have a<br/>hard-line on keeping their exact<br/>OTel Collector-only setup as-is?}

    Q1 -->|YES| T1

    T1["<b>OTel SDK + OSS Collector<br/>with DD Exporter</b><br/>─────────────────<br/>✅ Fully vendor-neutral pipeline<br/>✅ No Datadog-specific agents required<br/>⚠️ Limited DD feature support<br/>📊 Compatibility: Partial"]

    Q1 -->|NO| Q2

    Q2{Q2: Does the customer want to<br/>avoid deploying any agent or<br/>collector infrastructure at all?}

    Q2 -->|YES| T2

    T2["<b>Direct OTLP Ingest<br/>to Datadog</b><br/>─────────────────<br/>✅ Zero infrastructure to manage<br/>✅ Fastest time-to-value<br/>⚠️ Most limited DD feature set<br/>⚠️ No infra-level visibility<br/>📊 Compatibility: Minimal"]

    Q2 -->|NO| Q3

    Q3{Q3: Does the customer need<br/>Datadog advanced features?<br/><i>Continuous Profiler, ASM,<br/>Data Streams, RUM,<br/>Source Code Integration</i>}

    Q3 -->|YES| Q4
    Q3 -->|NO| Q5

    Q4{Q4: Is the customer willing to<br/>adopt Datadog Tracing Libraries?<br/><i>Note: DD libraries support the<br/>OTel Tracing API for<br/>vendor-neutral code</i>}

    Q4 -->|YES| Q4a
    Q4 -->|NO| Q4no

    Q4no["ℹ️ Advanced features require<br/>DD tracing libraries.<br/>Revisit trade-offs with customer."]
    Q4no --> Q5

    Q4a{Q4a: Running<br/>Linux-based K8s?}

    Q4a -->|YES| T3
    Q4a -->|NO| T4

    T3["⭐ <b>DD SDK + DDOT</b> ⭐<br/>★ RECOMMENDED ★<br/>─────────────────<br/>✅ Full DD feature set<br/>✅ OTel Collector capabilities built-in<br/>✅ Vendor-neutral code via OTel API<br/>✅ Single agent deployment<br/>📊 Compatibility: Full"]

    T4["<b>DD Tracing Libraries<br/>(w/ OTel API) + DD Agent</b><br/>─────────────────<br/>✅ Full DD feature set<br/>✅ Vendor-neutral code via OTel API<br/>⚠️ Requires DD Agent sidecar/host<br/>📊 Compatibility: Full"]

    Q5{Q5: Does the customer need OTel<br/>Collector capabilities alongside<br/>the DD Agent?<br/><i>Routing to multiple backends,<br/>custom processors, etc.</i>}

    Q5 -->|YES| Q5a
    Q5 -->|NO| T6

    Q5a{Q5a: Running<br/>Linux-based K8s?}

    Q5a -->|YES| T5a
    Q5a -->|NO| T5b

    T5a["<b>OTel SDK + DDOT</b><br/>─────────────────<br/>✅ OTel Collector capabilities<br/>✅ DD infra-level features via Agent<br/>✅ Single deployment (DDOT)<br/>⚠️ No DD-exclusive trace features<br/>📊 Compatibility: High"]

    T5b["<b>OTel SDK + OSS Collector<br/>+ DD Exporter</b><br/><i>(+ optionally DD Agent alongside)</i><br/>─────────────────<br/>✅ Full OTel Collector flexibility<br/>✅ Route to multiple backends<br/>⚠️ More infrastructure to manage<br/>📊 Compatibility: Partial"]

    T6["<b>OTel SDK + DD Agent<br/>(OTLP Ingest)</b><br/>─────────────────<br/>✅ DD infra-level features<br/>✅ Simple: Agent accepts OTLP natively<br/>⚠️ No DD-exclusive trace features<br/>📊 Compatibility: High"]

    %% Styling
    classDef question fill:#4a90d9,stroke:#2c5f8a,color:#fff,font-size:13px
    classDef terminal fill:#2d8659,stroke:#1a5c3a,color:#fff,font-size:12px
    classDef recommended fill:#d4a017,stroke:#9e7a0f,color:#000,font-size:12px,stroke-width:3px
    classDef info fill:#e8913a,stroke:#b86e1f,color:#fff,font-size:12px
    classDef startEnd fill:#6c3483,stroke:#4a235a,color:#fff,font-size:14px

    class Start startEnd
    class Q1,Q2,Q3,Q4,Q4a,Q5,Q5a question
    class T1,T2,T4,T5a,T5b,T6 terminal
    class T3 recommended
    class Q4no info
```

## Setup Types Summary

| Setup Type | When to Use |
|---|---|
| **DD SDK + DDOT** ⭐ | Customer on Linux K8s, wants full DD features + OTel Collector capabilities. **Recommended path.** |
| **DD Tracing Libraries + DD Agent** | Customer wants full DD features but isn't on Linux K8s. |
| **OTel SDK + DDOT** | Customer on Linux K8s, needs Collector capabilities, doesn't need DD-exclusive trace features. |
| **OTel SDK + OSS Collector + DD Exporter** | Customer committed to vendor-neutral Collector pipeline, or not on K8s but needs Collector features. |
| **OTel SDK + DD Agent (OTLP Ingest)** | Customer wants DD infra features with a simple OTLP setup, no Collector needs. |
| **Direct OTLP Ingest** | Customer wants zero infrastructure; accepts limited feature set. |

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
| Cloud Network Monitoring | Y | Y | - | - |
| Live Containers / K8s | Y | Y | - | - |
| Live Processes | Y | Y | - | - |
| USM | Y | Y | - | - |
| App & API Protection | Y | - | - | - |
| Continuous Profiler | Y | - | - | - |
| Data Streams Monitoring | Y | - | - | - |
| RUM | Y | - | - | - |
| Source Code Integration | Y | - | - | - |

### Reading the Matrix

- **Y** = Fully supported
- **Partial** = Limited or partial support
- **-** = Not available with this setup type

### Key Takeaways

1. **DD SDK + DDOT** is the only setup that provides the complete Datadog feature set while also offering OTel Collector capabilities.
2. **DD-exclusive features** (ASM, Profiler, DSM, RUM, Source Code Integration) require Datadog tracing libraries — they are not available with OTel SDK alone.
3. **Infrastructure-level features** (DB Monitoring, CNM, Live Containers, USM) require a Datadog Agent (either standalone or as DDOT) and are not available via OSS Collector or direct ingest.
4. **Core observability** (traces, correlated signals, LLM Obs) works across all setup types.
