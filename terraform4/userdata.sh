#!/bin/bash
set -e

# Install Docker (same approach as terraform3/userdata.sh)
curl -fsSL https://get.docker.com | sh

# Ensure an ssm-user exists and can use docker without sudo
id ssm-user &>/dev/null || useradd -m ssm-user
usermod -aG docker ssm-user

# Start Docker
systemctl enable --now docker

# Deploy Rackula via docker compose (persist stack: frontend + API)
# Frontend/nginx listens on TCP 8080 (published); API is internal on 3001.
mkdir -p /opt/rackula
cd /opt/rackula

curl -fsSL \
  https://raw.githubusercontent.com/RackulaLives/Rackula/main/deploy/docker-compose.persist.yml \
  -o docker-compose.yml

# Persistence volume is written by the container user (UID 1001)
mkdir -p data
chown 1001:1001 data

docker compose up -d