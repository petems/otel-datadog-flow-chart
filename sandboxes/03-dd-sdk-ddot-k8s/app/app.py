import os
import logging
import time
import random

os.environ.setdefault("DD_TRACE_OTEL_ENABLED", "true")
os.environ.setdefault("DD_SERVICE", "dd-flask-demo")
os.environ.setdefault("DD_ENV", "sandbox")
os.environ.setdefault("DD_VERSION", "1.0.0")

import ddtrace.auto  # noqa: E402,F401 - must be imported early for auto-instrumentation

from flask import Flask, jsonify  # noqa: E402
from opentelemetry import trace  # noqa: E402

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

tracer = trace.get_tracer(__name__)

app = Flask(__name__)

ITEMS = {
    "1": {"id": "1", "name": "Widget", "price": 9.99},
    "2": {"id": "2", "name": "Gadget", "price": 24.99},
    "3": {"id": "3", "name": "Doohickey", "price": 4.99},
}


@app.route("/")
def index():
    logger.info("Health check endpoint called")
    return jsonify({"status": "ok", "service": os.environ.get("DD_SERVICE", "dd-flask-demo")})


@app.route("/items")
def list_items():
    with tracer.start_as_current_span("list-items-logic") as span:
        span.set_attribute("items.count", len(ITEMS))
        time.sleep(random.uniform(0.01, 0.05))
        result = list(ITEMS.values())
    logger.info("Listed %d items", len(result))
    return jsonify(result)


@app.route("/items/<item_id>")
def get_item(item_id):
    with tracer.start_as_current_span("get-item-logic") as span:
        span.set_attribute("item.id", item_id)
        time.sleep(random.uniform(0.005, 0.02))
        item = ITEMS.get(item_id)
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
