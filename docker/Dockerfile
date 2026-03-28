# syntax=docker/dockerfile:1
#
# Pi-Agent Docker Sandbox
# A hardened container for running the pi-coding-agent
#

# ---------------------------------------------------------------------------
# Base image
# ---------------------------------------------------------------------------
FROM ubuntu:22.04

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
    nano \
    # System monitoring
    tree \
    htop \
    jq \
    # Archives
    zip \
    unzip \
    # TLS certificates for HTTPS
    ca-certificates \
    # Clean up apt cache to reduce image size
    && rm -rf /var/lib/apt/lists/*

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
    @mariozechner/pi-coding-agent \
    # Package manager for projects
    pnpm

# ---------------------------------------------------------------------------
# Workspace setup
# ---------------------------------------------------------------------------
WORKDIR /workspace

# Create non-root user for security
RUN useradd -m agent

# Create directories for agent data and session persistence
# - sessions/: Chat history (persisted via docker volume)
# - memory/: Agent memory store (persisted via docker volume)
# - prompts/: Custom prompt templates (copied from host)
RUN mkdir -p /workspace/.pi/memory /workspace/.pi/agent/sessions /workspace/.pi/agent/prompts

# Copy shell configuration
COPY bashrc /workspace/.bashrc

# Copy prompt templates (used by /command in pi agent)
COPY prompts/ /workspace/.pi/agent/prompts/

# Set ownership and permissions
RUN chmod -R 755 /workspace/.pi && chown -R agent:agent /workspace

# Default command when container starts
CMD ["/bin/bash"]
