#!/usr/bin/env bash
set -euo pipefail

REPO_URL="https://github.com/unboxd-cloud/cloud-architect-agents.git"
REPO_DIR="/opt/cloud-architect-agents"

if [ "$(id -u)" -ne 0 ]; then
  echo "[install-all] Please run as root or with sudo."
  exit 1
fi

echo "[install-all] Installing base packages..."
apt-get update -y
apt-get install -y curl git ca-certificates gnupg ufw fail2ban

echo "[install-all] Cloning/updating repository..."
mkdir -p "$(dirname "$REPO_DIR")"
if [ ! -d "$REPO_DIR/.git" ]; then
  git clone "$REPO_URL" "$REPO_DIR"
else
  git -C "$REPO_DIR" pull origin main
fi

cd "$REPO_DIR"

echo "[install-all] Hardening node..."
bash scripts/harden-node.sh

echo "[install-all] Installing k3s..."
bash scripts/install-k3s.sh

echo "[install-all] Deploying k8smicro stack..."
bash scripts/deploy-k8smicro.sh

echo "[install-all] Applying SurrealDB schema..."
kubectl -n cloud-architect-agents wait --for=condition=Ready pod -l app=surrealdb --timeout=180s
kubectl -n cloud-architect-agents port-forward svc/surrealdb 8000:8000 >/tmp/k8smicro-surrealdb-port-forward.log 2>&1 &
PF_PID=$!
sleep 5

if command -v surreal >/dev/null 2>&1; then
  surreal sql --conn http://127.0.0.1:8000 --user root --pass root --ns unboxd --db cloud_architect < memory/surrealdb/schema.surql || true
else
  echo "[install-all] Surreal CLI not installed; skipping schema apply. Apply memory/surrealdb/schema.surql manually."
fi

kill "$PF_PID" || true

echo "[install-all] Done."
kubectl get pods -n cloud-architect-agents
