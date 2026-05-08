.PHONY: help up down attach reset clean build rebuild check-env

# --- Required variables (add/remove as needed) ---
REQUIRED_VARS := OPENCODE_API_KEY MEMORY_LIMIT READ_ONLY

check-env:
	@echo "Checking environment..."
	@# 1. Ensure varlock is installed
	@command -v varlock >/dev/null 2>&1 || { echo "❌ varlock not found. Install: npm i -g @dmno/varlock"; exit 1; }
	@# 2. Load vars and check required ones are set
	@eval "$$(varlock load --format=shell)" && \
		for var in $(REQUIRED_VARS); do \
			eval "val=$$$$$var"; \
			if [ -z "$$$$val" ]; then \
				echo "❌ Missing required variable: $$$$var"; \
				exit 1; \
			fi; \
		done
	@echo "✅ All required variables present"

help:
	@echo "Pi Agent Sandbox (docker-compose)"
	@echo ""
	@echo "  make up        - Start sandbox (detached)"
	@echo "  make down      - Stop sandbox"
	@echo "  make attach    - Attach to sandbox shell"
	@echo "  make reset     - Destroy sandbox + volumes"
	@echo "  make clean     - Remove build artifacts"
	@echo "  make build     - Rebuild images"
	@echo "  make rebuild   - Down + build + up + attach"

up: check-env
	eval "$$(varlock load --format=shell)" && docker compose up -d

down:
	docker compose down

attach:
	docker compose exec sandbox bash

reset:
	docker compose down -v

clean:
	docker compose down --rmi local

build: check-env
	eval "$$(varlock load --format=shell)" && docker compose build --no-cache

rebuild: check-env
	eval "$$(varlock load --format=shell)" && docker compose down && docker compose build --no-cache && docker compose up -d && docker compose exec sandbox bash
