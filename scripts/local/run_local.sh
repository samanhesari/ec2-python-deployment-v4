#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

cd "$PROJECT_ROOT"

echo
echo "========================================"
echo " Running V4 FastAPI Locally"
echo "========================================"
echo

if [ ! -d ".venv" ]; then
    echo "[ERROR] Python virtual environment not found."
    echo
    echo "Create it with:"
    echo "  python3 -m venv .venv"
    echo "  source .venv/bin/activate"
    echo "  pip install -r requirements.txt"
    echo
    exit 1
fi

source .venv/bin/activate

echo "[1/3] Checking Python..."
python --version

echo
echo "[2/3] Checking dependencies..."
python -c "import fastapi, sqlalchemy, pymysql, jose, pwdlib"

echo
echo "[3/3] Starting FastAPI..."
echo
echo "API:"
echo "  http://127.0.0.1:8000"
echo
echo "Swagger:"
echo "  http://127.0.0.1:8000/docs"
echo
echo "Press CTRL+C to stop."
echo

exec python -m uvicorn app.main:app \
    --host 127.0.0.1 \
    --port 8000
