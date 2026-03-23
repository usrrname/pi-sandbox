# Agent Sandbox Requirements

## Purpose

Isolated development environment for running coding agents (e.g., pi) including multi-agent orchestration — where a primary agent spawns subagents for parallel or delegated tasks — without compromising host integrity or security on Mac OS M-series using OrbStack.

---

## 1. Isolation

| Requirement | Implementation |
|-------------|----------------|
| **Filesystem** | Agent can only read/write within designated workspace |
| **Network** | Agent network access controlled (default: blocked, explicit: allowed) |
| **Resources** | Hard limits on CPU (2 cores), RAM (4GB), processes (100) |
| **Persistence** | All state stored in named volumes, nothing survives container destruction |
| **User** | Agent runs as non-root user matching host UID/GID |

### Constraints

- Agent cannot access `~/.ssh`, `~/.aws`, `~/.config/gcloud`, or other credential directories
- Agent cannot install system packages without explicit permission
- Temporary files stored in tmpfs, not host filesystem

---

## 2. Storage Architecture

```
~/pi-sandbox/
├── memory/          # Agent memory and context (persists)
├── projects/        # Working project directories (persists)
└── cache/          # Package caches (discardable)
```

### Volume Mounts

| Host Path | Container Path | Access |
|-----------|---------------|--------|
| `~/pi-sandbox/memory` | `/root/.pi` | Read/Write |
| `~/pi-sandbox/projects` | `/workspace` | Read/Write |
| tmpfs | `/tmp` | Read/Write (volatile) |

---

## 3. Memory & Context Persistence

- **Session continuity**: Container uses `docker create` (not `docker run --rm`)
- **Resume capability**: `docker start -i <container>` attaches to previous session
- **Base environment**: Commit image after installing tools (`docker commit`)
- **Memory store**: SQLite/JSONL file in `/root/.pi/` for structured memory

### Memory Schema

```
/root/.pi/
├── memory.jsonl        # Learned patterns, project context
├── sessions/          # Session history
└── config/            # Agent preferences
```

---

## 4. Security Hardening

```bash
docker create \
  --name pi-sandbox \
  --cpus=2 \
  --memory=4g \
  --pids-limit=100 \
  --network=none \
  --read-only \
  -v ~/pi-sandbox/memory:/root/.pi:rw \
  -v ~/pi-sandbox/projects:/workspace:rw \
  -v tmpfs:/tmp:rw \
  -w /workspace \
  ubuntu:22.04
```

> Note: `--read-only` may break package managers. Use `:ro` for project dirs, `:rw` for memory.
>
> **Multi-agent**: All containers (primary + subagents) must use same memory volume. Subagents should be spawned with `--rm` and limited to 1 core / 1GB each.

---

## 5. Workflow

### First-Time Setup

```bash
docker create --name pi-sandbox ...
docker attach pi-sandbox
apt update && apt install -y python3 git curl vim tree
docker commit pi-sandbox pi:with-tools
```

### Subsequent Sessions

```bash
docker start -i pi-sandbox
# or
docker run -it --rm \
  -v ~/pi-sandbox/memory:/root/.pi \
  -v $(pwd):/workspace \
  pi:with-tools
```

### Clean Slate (if compromised)

```bash
docker stop pi-sandbox
docker rm pi-sandbox
docker create ... # recreate from base image
```

---

## 6. Project Directory Handling

| Scenario | Approach |
|----------|----------|
| Single persistent project | Mount project into `projects/`, always work there |
| Multiple projects | Mount each project read-only as needed |
| New project | Clone/copy into `projects/` first, then mount |

---

## 7. Acceptance Criteria

### Single Agent
- [ ] Agent cannot read host credentials or SSH keys
- [ ] Agent cannot access network by default (except explicit allowance)
- [ ] All agent memory survives container restart
- [ ] Workspace changes persist to host filesystem
- [ ] Resource exhaustion does not affect host
- [ ] Compromised container can be destroyed and recreated without host damage
- [ ] Agent runs as non-root with appropriate file permissions

### Multi-Agent
- [ ] Subagents spawn from same base image
- [ ] Subagents share memory volume for coordination
- [ ] Subagent failures don't crash primary agent
- [ ] Primary agent can kill orphaned subagent containers
- [ ] Concurrent subagents respect total resource limits
- [ ] Agent-to-agent data flow uses only shared memory (no network)

---

## 8. Multi-Agent Architecture

### Definitions

| Term | Definition |
|------|------------|
| **Primary Agent** | Main agent session (e.g., pi) orchestrating work |
| **Subagent** | Spawned by primary, delegated specific task (code review, testing) |
| **Agent Pool** | Pre-warmed containers ready for subagent tasks |

### Supported Patterns

| Pattern | Description | Implementation |
|---------|-------------|----------------|
| **Fork** | Primary spawns subagent for independent parallel task | `docker run` from same image with shared memory volume |
| **Delegate** | Primary delegates subtask to specialized agent | Named container per task, shares memory via volume |
| **Pipeline** | Chain of agents, output → next agent input | Sequential `docker run` with shared workspace |

### Shared Memory

```
/root/.pi/
├── memory.jsonl        # Primary agent memory
├── shared/            # Shared context between agents
│   ├── task-queue/    # Tasks pending subagent execution
│   ├── results/       # Subagent outputs
│   └── state/         # Shared state (locks, coordination)
└── agents/           # Per-agent state
    ├── primary/       # Primary agent session data
    └── subagent-{n}/ # Subagent session data
```

### Subagent Lifecycle

```
Primary Agent
    │
    ├── Spawn: docker run --rm \
    │            -v pi-memory:/root/.pi:rw \
    │            pi-sandbox:with-tools
    │
    ├── Delegate task via shared /root/.pi/task-queue/
    │
    ├── Wait: poll /root/.pi/shared/results/
    │
    └── Resume with subagent output
```

### Resource Allocation

| Component | CPU | RAM | Notes |
|-----------|-----|-----|-------|
| Primary Agent | 1 core | 2GB | Main session |
| Subagent (each) | 1 core | 1GB | Max 2 concurrent |
| System overhead | 0.5 core | 0.5GB | Docker, logging |

Total: 2 cores / 4GB (matches host limits)

---

## 9. Out of Scope

- Real-time monitoring/alerting
- Automated threat detection
- Cross-cloud agent federation
