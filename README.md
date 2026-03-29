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
/workspace                          # From image
/workspace/.pi/agent/prompts/      # Prompt templates (from image)
/workspace/.pi/agent/sessions/      # Session history (persists)
.workspace/.pi/memory/             # Agent memory (persists)
/workspace/projects/                # Your code (persists)
/tmp                                # Ephemeral temp files (RAM, 500MB limit)
```

### Storage Strategy

| Path | Source | Persists |
|------|--------|----------|
| `/workspace` | Image | No |
| `/workspace/.pi/agent/prompts/` | Image | No (rebuild to update) |
| `/workspace/.pi/agent/sessions/` | Volume | ✅ |
| `/workspace/.pi/memory/` | Volume | ✅ |
| `/workspace/projects/` | Volume | ✅ |
| `/tmp` | tmpfs (RAM) | No |

This ensures prompts stay in sync with the image while session history, memory, and projects persist across runs.

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

## Git & SSH

The agent needs its own SSH key for GitHub operations. Create one on your host:

```bash
mkdir -p ~/.ssh/pi-agent
ssh-keygen -t ed25519 -f ~/.ssh/pi-agent/id_ed25519 -C "pi-agent"
# Add the public key to GitHub: cat ~/.ssh/pi-agent/id_ed25519.pub
```

Create `~/.gitconfig` to configure git with the agent's SSH key:

```ini
[core]
  sshCommand = ssh -i ~/.ssh/pi-agent/id_ed25519 -o StrictHostKeyChecking=no

[user]
  email = your@email.com
  name = Your Name
```

Both are mounted into the container automatically via docker-compose.yml.

## Extending config

Edit `docker/Dockerfile`, then:

```bash
make build
```

See [AGENTS.md](./AGENTS.md) for full documentation.
