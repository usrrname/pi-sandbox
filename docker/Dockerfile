# syntax=docker/dockerfile:1
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
  git curl vim nano tree htop jq zip unzip ca-certificates \
  && rm -rf /var/lib/apt/lists/* \
  && curl -fsSL https://nodejs.org/dist/v22.22.2/node-v22.22.2-linux-arm64.tar.gz | tar -xz -C /usr/local --strip-components=1

RUN npm install -g @mariozechner/pi-coding-agent

WORKDIR /workspace

RUN useradd -m agent
RUN mkdir -p /workspace/.pi/memory /workspace/.pi/agent/sessions /workspace/.pi/agent/prompts
COPY bashrc /workspace/.bashrc
COPY prompts/ /workspace/.pi/agent/prompts/
RUN chmod -R 755 /workspace/.pi && chown -R agent:agent /workspace

CMD ["/bin/bash"]
