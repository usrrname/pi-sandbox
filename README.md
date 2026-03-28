# pi-sandbox

A Docker sandbox for running [pi-coding-agent](https://github.com/badlogic/pi-mono) — the minimal agent underlying OpenClaw.

## Setup

```bash
# Install varlock for secrets
npm install -g @dmno/varlock
pnpm install -g @varlock/1password-plugin

# Configure 1Password (edit .env.schema with your vault path)
# Run the sandbox
varlock run -- make build && varlock run -- make up && varlock run -- make attach

# Inside container
pi
```

## What is This?

A **container configured as a sandbox** for running AI coding agents safely on your machine.

| Feature | Implementation |
|---------|---------------|
| Non-root user | UID 1000 |
| Filesystem | Read-only + tmpfs |
| Network | Bridge (AI API access) |
| Resources | 2 CPU, 4GB RAM, 100 PIDs |

## Quick Commands

```bash
make up        # Start container
make attach    # Shell inside
make down      # Stop container
make build     # Rebuild image
```

## Structure

```
/workspace          # Your projects (~/pi-sandbox/projects)
/workspace/.pi     # Agent data (sessions, memory, auth)
/tmp               # Ephemeral temp files
```

## Prompt Templates

Inside container, type `/` to see templates:

| Command | Use |
|---------|-----|
| `/review` | Review code for bugs |
| `/commit` | Generate commit message |
| `/explain` | Explain code simply |
| `/security-audit` | Security review |
| `/safe-cmd` | Build safe shell commands |
| `/dep-check` | Check vulnerabilities |
| `/soul` | Set agent personality |

## Secrets

API keys are injected via [varlock](https://varlock.dev) — never stored in plain text.

Edit `.env.schema` to configure your secrets provider.

## Adding Tools

Edit `docker/Dockerfile`, then:
```bash
make build
```

See [AGENTS.md](./AGENTS.md) for full documentation.
