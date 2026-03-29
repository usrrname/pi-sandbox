.PHONY: help up down attach reset clean build rebuild

help:
	@echo "Agent Sandbox (docker-compose)"
	@echo ""
	@echo "  make up        - Start sandbox (detached)"
	@echo "  make down      - Stop sandbox"
	@echo "  make attach    - Attach to sandbox shell"
	@echo "  make reset     - Destroy sandbox + volumes"
	@echo "  make clean     - Remove build artifacts"
	@echo "  make build     - Rebuild images"
	@echo "  make rebuild   - Down + build + up + attach"

up:
	eval "$$(varlock load --format=env)" && export MINIMAX_API_KEY GH_TOKEN && docker compose up -d

down:
	docker compose down

attach:
	docker compose exec sandbox bash

reset:
	docker compose down -v

clean:
	docker compose down --rmi local

build:
	eval "$$(varlock load --format=env)" && export MINIMAX_API_KEY && docker compose build --no-cache

rebuild:
	eval "$$(varlock load --format=env)" && export MINIMAX_API_KEY && docker compose down && docker compose build --no-cache && docker compose up -d && docker compose exec sandbox bash
