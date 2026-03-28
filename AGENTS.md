# Agent Sandbox

Docker sandbox for pi-coding-agent with Node.js 22.

## Quick Start

```bash
# 1. Install varlock (https://varlock.dev)
npm install -g @dmno/varlock

# 2. Configure secrets provider (1Password, AWS, etc.) - see https://varlock.dev/guides/secrets/

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

Set up `.env.schema`:

```json

```

Or use any other secret key accepted  

**Gotcha:** `auth.json` is created by the agent on first run using `MINIMAX_API_KEY`.
If `MINIMAX_API_KEY` is empty/missing, the agent won't authenticate. Ensure varlock
properly injects the key before running `pi`.

## Structure

- `/workspace` — projects (host: `~/pi-sandbox/projects`)
- `/workspace/.pi` — agent data (sessions, memory, auth)
- `/workspace/.pi/agent/prompts/` — prompt templates
- `/tmp` — tmpfs (ephemeral)

## Prompt Templates

Available at `/workspace/.pi/agent/prompts/`:

| Command | Description |
|---------|-------------|
| `/review` | Code review for bugs and security |
| `/commit` | Generate conventional commit message |
| `/explain` | Explain code in simple terms |
| `/security-audit` | Security-focused code review |
| `/safe-cmd` | Build safe shell commands |
| `/dep-check` | Check for vulnerable dependencies |
| `/soul` | Set agent personality and principles |

## Security

- Non-root (UID 1000)
- `network_mode: bridge`
- `read_only: true`
- Resource limits (CPU, memory, PIDs)
- API keys never stored in plain text

## Adding Tools

Edit `docker/Dockerfile`, then `make build`.
