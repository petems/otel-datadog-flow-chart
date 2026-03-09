import os
import logging
import time
import random

from flask import Flask, jsonify

from opentelemetry import trace, metrics
from opentelemetry.sdk.resources import Resource
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.sdk.metrics import MeterProvider
from opentelemetry.sdk.metrics.export import PeriodicExportingMetricReader
from opentelemetry.exporter.otlp.proto.http.trace_exporter import OTLPSpanExporter
from opentelemetry.exporter.otlp.proto.http.metric_exporter import OTLPMetricExporter
from opentelemetry.instrumentation.flask import FlaskInstrumentor
from opentelemetry.sdk._logs import LoggerProvider, LoggingHandler
from opentelemetry.sdk._logs.export import BatchLogRecordProcessor
from opentelemetry.exporter.otlp.proto.http._log_exporter import OTLPLogExporter

# --- Resource ---
resource = Resource.create({
    "service.name": os.environ.get("OTEL_SERVICE_NAME", "otel-flask-demo"),
    "service.version": "1.0.0",
    "deployment.environment.name": os.environ.get("OTEL_ENV", "sandbox"),
})

# --- Traces ---
tracer_provider = TracerProvider(resource=resource)
tracer_provider.add_span_processor(BatchSpanProcessor(OTLPSpanExporter()))
trace.set_tracer_provider(tracer_provider)
tracer = trace.get_tracer(__name__)

# --- Metrics ---
metric_reader = PeriodicExportingMetricReader(OTLPMetricExporter(), export_interval_millis=10000)
meter_provider = MeterProvider(resource=resource, metric_readers=[metric_reader])
metrics.set_meter_provider(meter_provider)
meter = metrics.get_meter(__name__)
request_counter = meter.create_counter("app.request.count", description="Total requests")
request_duration = meter.create_histogram("app.request.duration_ms", description="Request duration in ms")

# --- Logs ---
logger_provider = LoggerProvider(resource=resource)
logger_provider.add_log_record_processor(BatchLogRecordProcessor(OTLPLogExporter()))
handler = LoggingHandler(level=logging.INFO, logger_provider=logger_provider)
logging.getLogger().addHandler(handler)
logging.getLogger().setLevel(logging.INFO)
logger = logging.getLogger(__name__)

# --- Flask App ---
app = Flask(__name__)
FlaskInstrumentor().instrument_app(app)

ITEMS = {
    "1": {"id": "1", "name": "Widget", "price": 9.99},
    "2": {"id": "2", "name": "Gadget", "price": 24.99},
    "3": {"id": "3", "name": "Doohickey", "price": 4.99},
}


@app.route("/")
def index():
    logger.info("Health check endpoint called")
    return jsonify({"status": "ok", "service": os.environ.get("OTEL_SERVICE_NAME", "otel-flask-demo")})


@app.route("/items")
def list_items():
    request_counter.add(1, {"endpoint": "/items"})
    start = time.time()
    with tracer.start_as_current_span("list-items-logic") as span:
        span.set_attribute("items.count", len(ITEMS))
        time.sleep(random.uniform(0.01, 0.05))
        result = list(ITEMS.values())
    request_duration.record((time.time() - start) * 1000, {"endpoint": "/items"})
    logger.info("Listed %d items", len(result))
    return jsonify(result)


@app.route("/items/<item_id>")
def get_item(item_id):
    request_counter.add(1, {"endpoint": "/items/:id"})
    start = time.time()
    with tracer.start_as_current_span("get-item-logic") as span:
        span.set_attribute("item.id", item_id)
        time.sleep(random.uniform(0.005, 0.02))
        item = ITEMS.get(item_id)
    request_duration.record((time.time() - start) * 1000, {"endpoint": "/items/:id"})
    if item:
        logger.info("Found item %s", item_id)
        return jsonify(item)
    logger.warning("Item %s not found", item_id)
    return jsonify({"error": "not found"}), 404


@app.route("/error")
def error_endpoint():
    logger.error("Deliberate error triggered")
    raise ValueError("This is a deliberate error for testing")


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
