# syntax=docker/dockerfile:1@sha256:87999aa3d42bdc6bea60565083ee17e86d1f3339802f543c0d03998580f9cb89
#
# Pi-Agent Docker Sandbox
# A hardened container for running the pi-coding-agent
#

# ---------------------------------------------------------------------------
# Base image
# ---------------------------------------------------------------------------
FROM ubuntu:26.04@sha256:53958ec7b67c2c9355df922dd08dbf0360611f8c3cdb656875e81873db9ffdba

# Disable interactive prompts during apt
ENV DEBIAN_FRONTEND=noninteractive

# ---------------------------------------------------------------------------
# System dependencies
# ---------------------------------------------------------------------------
# Install essential tools for development and debugging
RUN apt-get update && apt-get install -y \
  # Version control
  git \
  # Shells and editors
  curl \
  vim \
  neovim \
  # System monitoring
  tree \
  htop \
  jq \
  yq\
  # Archives
  zip \
  unzip \
  # TLS certificates for HTTPS
  ca-certificates \
  # Tailscale
  ca-certificates gnupg lsb-release \
  # Clean up apt cache to reduce image size
  && rm -rf /var/lib/apt/lists/*

# Install Tailscale binary directly
RUN curl -fsSL https://pkgs.tailscale.com/stable/tailscale_latest_arm64.tgz | tar -xz -C /tmp && \
  cp /tmp/tailscale_*/tailscaled /usr/local/bin/ && \
  cp /tmp/tailscale_*/tailscale /usr/local/bin/ && \
  rm -rf /tmp/tailscale_*

# ---------------------------------------------------------------------------
# Node.js
# ---------------------------------------------------------------------------
# Download and extract Node.js binaries (no package manager needed)
ARG NODE_VERSION=22.22.2
RUN curl -fsSL "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-arm64.tar.gz" | \
  tar -xz -C /usr/local --strip-components=1

# ---------------------------------------------------------------------------
# Global npm packages
# ---------------------------------------------------------------------------
# Install tools used by the pi-coding-agent
RUN npm install -g \
  # The AI coding agent
  @earendil-works/pi-coding-agent \
  # Package manager for projects
  pnpm bun 

# ---------------------------------------------------------------------------
# Workspace setup
# ---------------------------------------------------------------------------
WORKDIR /workspace

# Create non-root user for security
RUN useradd -m agent

# Create directories for agent data and session persistence
# - extensions
# - sessions/: Chat history (persisted via docker volume)
# - memory/: Agent memory store (persisted via docker volume)
# - prompts/: Custom prompt templates (copied from host, at repo root)
RUN mkdir -p /workspace/.pi/memory /workspace/.pi/agent/sessions /workspace/.pi/agent/prompts /workspace/.pi/agent/extensions

# Copy shell configuration
COPY docker/bashrc /workspace/.bashrc

# Copy and set up entrypoint
COPY docker/entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

# Copy prompt templates (used by /command in pi agent)
COPY prompts/ /workspace/.pi/agent/prompts/

# Set ownership and permissions
RUN chmod -R 755 /workspace/.pi && chown -R agent:agent /workspace

CMD ["/bin/bash"]
