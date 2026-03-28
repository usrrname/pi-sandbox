---
description: Build safe shell commands
---
Generate a shell command to accomplish: $@

Safety rules:
- Never echo or expose secrets/API keys
- Validate and sanitize all inputs
- Use quoted variables: "$VAR"
- Prefer read-only operations
- Add error handling (set -euo pipefail)
