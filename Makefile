.PHONY: help check-env

SANDBOXES_DIR := sandboxes

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-25s\033[0m %s\n", $$1, $$2}'

check-env: ## Verify DD_API_KEY is set
	@test -n "$${DD_API_KEY}" || (echo "ERROR: DD_API_KEY not set. Run: envchain datadog make <target>"; exit 1)

# --- Docker Compose sandboxes ---
sandbox-01: check-env ## Run Sandbox 1: OTel SDK + OSS Collector
	cd $(SANDBOXES_DIR)/01-otel-sdk-oss-collector && docker compose up --build

sandbox-02: check-env ## Run Sandbox 2: Direct OTLP Ingest
	cd $(SANDBOXES_DIR)/02-direct-otlp-ingest && docker compose up --build

sandbox-04: check-env ## Run Sandbox 4: DD SDK + DD Agent
	cd $(SANDBOXES_DIR)/04-dd-sdk-dd-agent && docker compose up --build

sandbox-06: check-env ## Run Sandbox 6: OTel SDK + DD Agent OTLP
	cd $(SANDBOXES_DIR)/06-otel-sdk-dd-agent-otlp && docker compose up --build

# --- K8s sandboxes ---
sandbox-03: check-env ## Run Sandbox 3: DD SDK + DDOT (Minikube)
	cd $(SANDBOXES_DIR)/03-dd-sdk-ddot-k8s && bash setup-minikube.sh

sandbox-05: check-env ## Run Sandbox 5: OTel SDK + DDOT (Minikube)
	cd $(SANDBOXES_DIR)/05-otel-sdk-ddot-k8s && bash setup-minikube.sh

# --- Cleanup ---
down-01: ## Tear down Sandbox 1
	cd $(SANDBOXES_DIR)/01-otel-sdk-oss-collector && docker compose down -v

down-02: ## Tear down Sandbox 2
	cd $(SANDBOXES_DIR)/02-direct-otlp-ingest && docker compose down -v

down-03: ## Tear down Sandbox 3
	cd $(SANDBOXES_DIR)/03-dd-sdk-ddot-k8s && bash teardown.sh

down-04: ## Tear down Sandbox 4
	cd $(SANDBOXES_DIR)/04-dd-sdk-dd-agent && docker compose down -v

down-05: ## Tear down Sandbox 5
	cd $(SANDBOXES_DIR)/05-otel-sdk-ddot-k8s && bash teardown.sh

down-06: ## Tear down Sandbox 6
	cd $(SANDBOXES_DIR)/06-otel-sdk-dd-agent-otlp && docker compose down -v

down-all: ## Tear down all sandboxes
	@for d in 01-otel-sdk-oss-collector 02-direct-otlp-ingest 04-dd-sdk-dd-agent 06-otel-sdk-dd-agent-otlp; do \
		echo "Stopping $$d..."; \
		(cd $(SANDBOXES_DIR)/$$d && docker compose down -v 2>/dev/null) || true; \
	done
	@for d in 03-dd-sdk-ddot-k8s 05-otel-sdk-ddot-k8s; do \
		echo "Stopping $$d..."; \
		(cd $(SANDBOXES_DIR)/$$d && bash teardown.sh 2>/dev/null) || true; \
	done
