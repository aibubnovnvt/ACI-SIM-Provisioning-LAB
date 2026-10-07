#!/bin/bash
#
# setup_env.sh
#
# Bootstraps a local Python virtual environment with the exact Ansible
# version, Python dependencies, and Galaxy collection versions this
# project was built and tested against. Replaces committing a pre-built
# venv into git - run this once after cloning instead.
#
# This was built and tested against:
#   - Python 3.10.12 (Ubuntu 22.04 system python3, installed via apt)
#   - Linux x86_64
# Running on a different Python version or OS/architecture may pull
# different compiled wheels (cryptography, bcrypt, pynacl, etc.) and is
# not guaranteed to behave identically.
#
# Usage:
#   ./setup_env.sh [venv_dir]
#
# Then activate with:
#   source <venv_dir>/bin/activate   (defaults to ./venv)

set -euo pipefail

VENV_DIR="${1:-venv}"
PYTHON_BIN="${PYTHON_BIN:-python3}"
REQUIRED_PY_MAJOR_MINOR="3.10"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd "$SCRIPT_DIR"

# --- Verify the interpreter matches the tested version ---------------------
ACTUAL_PY_VERSION="$("$PYTHON_BIN" -c 'import sys; print("%d.%d" % sys.version_info[:2])')"
ACTUAL_PY_FULL="$("$PYTHON_BIN" -c 'import platform; print(platform.python_version())')"
ACTUAL_PLATFORM="$("$PYTHON_BIN" -c 'import platform; print(platform.system(), platform.machine())')"

echo "Detected interpreter: ${PYTHON_BIN} -> Python ${ACTUAL_PY_FULL} (${ACTUAL_PLATFORM})"

if [ "$ACTUAL_PY_VERSION" != "$REQUIRED_PY_MAJOR_MINOR" ]; then
    echo
    echo "WARNING: this project was built and tested against Python ${REQUIRED_PY_MAJOR_MINOR}.x"
    echo "         (specifically 3.10.12 on Ubuntu 22.04 / Linux x86_64)."
    echo "         Detected Python ${ACTUAL_PY_FULL} instead. Some pinned package"
    echo "         versions in requirements.txt (cryptography, bcrypt, pynacl, ...)"
    echo "         may not have matching prebuilt wheels for this interpreter/OS,"
    echo "         which can change behavior or break the build entirely."
    echo
    echo "         To install Python 3.10 on Ubuntu:"
    echo "           sudo apt-get update && sudo apt-get install -y python3.10 python3.10-venv python3-pip"
    echo "         Then re-run: PYTHON_BIN=python3.10 ./setup_env.sh"
    echo
    read -r -p "Continue anyway with ${PYTHON_BIN} (Python ${ACTUAL_PY_FULL})? [y/N] " reply
    case "$reply" in
        [yY][eE][sS]|[yY]) ;;
        *) echo "Aborting."; exit 1 ;;
    esac
fi

if [ -d "$VENV_DIR" ]; then
    echo "Virtual environment '${VENV_DIR}' already exists - skipping creation."
else
    echo "Creating virtual environment in ./${VENV_DIR} ..."
    "$PYTHON_BIN" -m venv "$VENV_DIR"
fi

# shellcheck disable=SC1091
source "${VENV_DIR}/bin/activate"

echo "Upgrading pip, setuptools, and wheel ..."
# setuptools+wheel must be present *before* requirements.txt is installed,
# otherwise packages without prebuilt wheels (e.g. pyvmomi) silently fall
# back to the legacy "setup.py install" path instead of a proper wheel
# build - less deterministic and not what the tested environment used.
python3 -m pip install --upgrade pip setuptools wheel

echo "Installing Python/Ansible requirements from requirements.txt ..."
pip install -r requirements.txt

echo "Installing Ansible Galaxy collections from requirements.yml ..."
ansible-galaxy collection install -r requirements.yml --force

echo
echo "Done."
echo "Activate the environment with:"
echo "  source ${VENV_DIR}/bin/activate"
echo
echo "Then run the full provisioning sequence with:"
echo "  cd POD1_config"
echo "  ansible-playbook -i POD1 ACI_Simulator_Site.yml"

