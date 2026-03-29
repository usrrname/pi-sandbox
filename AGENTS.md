# Agent Sandbox

Docker sandbox for pi-coding-agent with Node.js 22.

## Quick Start

```bash
# 1. Install varlock (https://varlock.dev)
```

npm install -g @dmno/varlock
 or
brew install varlock

```

# 2. Configure secrets provider (1Password) - see https://varlock.dev/guides/secrets/

# 3. Set your API key in secrets provider

# 4. Run with varlock
varlock run -- make build && varlock run -- make up && varlock run -- make attach
```

## Commands

| Command | Description |
|---------|-------------|
| `make up` | Start container |
| `make down` | Stop container |
| `make attach` | Shell inside |
| `make build` | Rebuild image |

## Secrets (Varlock)

This project uses [varlock](https://varlock.dev) to inject API keys securely.

Set up `.env.schema` with 1Password references to your AI API keys.

**Gotcha:**

- `auth.json` is created by the agent on first run using `MINIMAX_API_KEY` (or whatever API key of your choosing)
If `MINIMAX_API_KEY` is empty/missing, the agent won't authenticate. Ensure varlock properly injects the key before running `pi`.

## Structure

- `/workspace` — projects (host: `~/pi-sandbox/projects`)
- `/workspace/.pi` — agent data (sessions, memory, auth)
- `/workspace/.pi/agent/prompts/` — prompt templates
- `/tmp` — tmpfs (ephemeral)

## Security

- Non-root (UID 1000)
- `network_mode: bridge`
- `read_only: true`
- Resource limits (CPU, memory, PIDs)
- API keys never stored in plain text

## Adding Tools

Edit `docker/Dockerfile`, then `make build`.
