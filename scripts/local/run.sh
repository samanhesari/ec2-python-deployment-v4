#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

VENV_DIR="$PROJECT_ROOT/.venv"
REQUIREMENTS_FILE="$PROJECT_ROOT/requirements.txt"

cd "$PROJECT_ROOT"

echo
echo "========================================"
echo "       V4 FASTAPI APPLICATION"
echo "========================================"
echo

if ! command -v python3 >/dev/null 2>&1; then
    echo "[ERROR] Python 3 is not installed."
    exit 1
fi

if [ ! -d "$VENV_DIR" ]; then
    echo "[INFO] Creating virtual environment..."
    python3 -m venv "$VENV_DIR"
    echo "[SUCCESS] Virtual environment created."
fi

echo "[INFO] Activating virtual environment..."
source "$VENV_DIR/bin/activate"
echo "[SUCCESS] Virtual environment activated."

echo "[INFO] Installing project dependencies..."
python -m pip install -r "$REQUIREMENTS_FILE"

echo
echo "========================================"
echo "          STARTING FASTAPI"
echo "========================================"
echo
echo "API:  http://127.0.0.1:8000"
echo "Docs: http://127.0.0.1:8000/docs"
echo
echo "Press CTRL+C to stop."
echo

python -m uvicorn app.main:app --reload