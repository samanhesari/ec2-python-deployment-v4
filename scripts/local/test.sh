#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

VENV_DIR="$PROJECT_ROOT/.venv"
REQUIREMENTS_FILE="$PROJECT_ROOT/requirements.txt"

echo
echo "========================================"
echo "          V4 TEST ENVIRONMENT"
echo "========================================"
echo

cd "$PROJECT_ROOT"

# ------------------------------------------
# Check Python
# ------------------------------------------

if ! command -v python3 >/dev/null 2>&1; then
    echo "[ERROR] Python 3 is not installed."
    exit 1
fi

echo "[INFO] Python:"
python3 --version


# ------------------------------------------
# Create virtual environment if necessary
# ------------------------------------------

if [ ! -d "$VENV_DIR" ]; then
    echo
    echo "[INFO] Virtual environment not found."
    echo "[INFO] Creating virtual environment..."

    python3 -m venv "$VENV_DIR"

    echo "[SUCCESS] Virtual environment created."
else
    echo "[INFO] Virtual environment found."
fi


# ------------------------------------------
# Activate virtual environment
# ------------------------------------------

echo
echo "[INFO] Activating virtual environment..."

source "$VENV_DIR/bin/activate"

echo "[SUCCESS] Virtual environment activated."


# ------------------------------------------
# Upgrade pip
# ------------------------------------------

echo
echo "[INFO] Checking pip..."

python -m pip install --upgrade pip --quiet


# ------------------------------------------
# Install dependencies
# ------------------------------------------

if [ -f "$REQUIREMENTS_FILE" ]; then

    echo
    echo "[INFO] Installing project dependencies..."

    python -m pip install -r "$REQUIREMENTS_FILE"

    echo
    echo "[SUCCESS] Dependencies are ready."

else

    echo
    echo "[ERROR] requirements.txt not found:"
    echo "$REQUIREMENTS_FILE"
    exit 1

fi


# ------------------------------------------
# Run tests
# ------------------------------------------

echo
echo "========================================"
echo "          RUNNING V4 TESTS"
echo "========================================"
echo

python -m pytest -v


# ------------------------------------------
# Finished
# ------------------------------------------

echo
echo "========================================"
echo "          TESTS PASSED"
echo "========================================"
echo