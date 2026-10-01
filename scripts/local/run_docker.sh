#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

cd "$PROJECT_ROOT"

echo
echo "========================================"
echo " Running V4 with Docker Locally"
echo "========================================"
echo

if [ ! -f ".env" ]; then
    echo "[ERROR] .env file not found."
    echo
    echo "Create it with:"
    echo "  cp .env.example .env"
    echo
    echo "Then set JWT_SECRET_KEY in .env."
    echo
    exit 1
fi

if ! grep -q "^JWT_SECRET_KEY=" .env || \
   [ -z "$(sed -n 's/^JWT_SECRET_KEY=//p' .env)" ]; then
    echo "[ERROR] JWT_SECRET_KEY is missing or empty in .env."
    exit 1
fi

echo "[1/3] Checking Docker..."
docker --version

echo
echo "[2/3] Checking Docker Compose..."
docker compose version

echo
echo "[3/3] Starting FastAPI + MySQL..."
echo

docker compose up -d --build

echo
echo "Waiting for containers..."
sleep 5

echo
echo "========================================"
echo " Local Docker Application"
echo "========================================"
echo

echo "API:"
echo "  http://127.0.0.1:8000"

echo
echo "Swagger:"
echo "  http://127.0.0.1:8000/docs"

echo
echo "Container status:"
docker compose ps

echo
echo "Useful commands:"
echo "  docker compose logs -f"
echo "  docker compose logs -f api"
echo "  docker compose logs -f mysql"
echo "  docker compose down"
echo
