#!/bin/bash
chown -R 1000:1000 /workspace/projects /workspace/.pi/agent/extensions 2>/dev/null || true
exec "$@"