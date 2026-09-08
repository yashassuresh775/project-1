#!/usr/bin/env bash
# Step 2 — Install Git, Docker, and Docker Compose on Ubuntu 22.04 EC2.
set -euo pipefail

echo "==> Updating packages"
sudo apt-get update -y
sudo DEBIAN_FRONTEND=noninteractive apt-get upgrade -y

echo "==> Installing Git, Docker, Compose plugin, curl"
sudo apt-get install -y git curl ca-certificates docker.io docker-compose-v2

echo "==> Enabling Docker"
sudo systemctl enable --now docker

echo "==> Adding current user to docker group"
sudo usermod -aG docker "$USER"

echo "==> Docker version"
docker --version || true
docker compose version || true

cat <<'EOF'

Done (Step 2).
Log out and back in (or run: newgrp docker) so docker works without sudo.
Next: scripts/02-install-jenkins.sh
EOF
