#!/usr/bin/env bash
#
# install_docker.sh
#
# Installs Docker CE on Ubuntu via the official Docker apt repository,
# executing the following steps in strict order (each step must succeed
# before the next one runs):
#
#   1. apt update
#   2. apt install apt-transport-https ca-certificates curl software-properties-common
#   3. Add Docker's official GPG key (curl | gpg --dearmor)
#   4. Add the Docker apt repository (echo ... | tee /etc/apt/sources.list.d/docker.list)
#   5. apt update (to pick up the new repository)
#   6. apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
#
# Notes:
#   - `set -euo pipefail` below means the script aborts immediately on the
#     first failing command (including failures inside a pipe), so a later
#     step can never run against a broken/incomplete earlier step.
#   - The only deliberate change from the commands as given is adding `-y`
#     to the two install commands, so the script runs unattended instead
#     of blocking on an interactive "Do you want to continue? [Y/n]"
#     prompt. Everything else (order, syntax, command substitutions,
#     pipes, quoting) is reproduced exactly as specified.
#   - This script is self-contained and does not read or modify anything
#     under version_1_1/ or any other project folder.
#
# Usage:
#   ./install_docker.sh
#
# Requires: Ubuntu (apt-based), and the ability to run `sudo` (either as
# root or as a user with sudo privileges).

set -euo pipefail

echo "[1/6] sudo apt update"
sudo apt update

echo "[2/6] sudo apt install apt-transport-https ca-certificates curl software-properties-common"
sudo apt install -y apt-transport-https ca-certificates curl software-properties-common

echo "[3/6] Adding Docker's official GPG key"
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "[4/6] Adding Docker's apt repository"
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "[5/6] sudo apt update (picking up the new Docker repository)"
sudo apt update

echo "[6/6] sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin"
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

echo
echo "Docker installation complete."
docker --version || true
