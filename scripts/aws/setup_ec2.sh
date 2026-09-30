#!/bin/bash

set -euo pipefail

echo "========================================"
echo "       V4 EC2 SERVER SETUP"
echo "========================================"

echo
echo "[INFO] Updating package lists..."
sudo apt-get update

echo
echo "[INFO] Installing Docker Compose..."
sudo apt-get install -y docker-compose-v2

echo
echo "[INFO] Enabling Docker..."
sudo systemctl enable docker
sudo systemctl start docker

echo
echo "[INFO] Adding current user to docker group..."
sudo usermod -aG docker "$USER"

echo
echo "[INFO] Docker version:"
docker --version

echo
echo "[INFO] Docker Compose version:"
docker compose version

echo
echo "[SUCCESS] EC2 Docker environment configured."
echo
echo "[IMPORTANT] Log out and SSH back in for docker group changes to take effect."