.PHONY: help init up down attach reset clean build

SANDBOX_DIR := $(HOME)/pi-sandbox

help:
	@echo "Agent Sandbox (docker-compose)"
	@echo ""
	@echo "  make init     - Create directories + first build"
	@echo "  make up       - Start sandbox (detached)"
	@echo "  make down     - Stop sandbox"
	@echo "  make attach   - Attach to sandbox shell"
	@echo "  make reset    - Destroy sandbox + volumes"
	@echo "  make clean    - Remove build artifacts"
	@echo "  make build    - Rebuild images"

init:
	mkdir -p $(SANDBOX_DIR)/{memory,projects}
	docker compose build

up:
	docker compose up -d

down:
	docker compose down

attach:
	docker compose exec sandbox bash

reset: down
	docker compose down -v

clean:
	docker compose down --rmi local
	rm -rf $(SANDBOX_DIR)

build:
	docker compose build --no-cache
