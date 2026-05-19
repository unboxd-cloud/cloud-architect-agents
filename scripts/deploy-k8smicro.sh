#!/usr/bin/env bash
set -euo pipefail

REPO_DIR="/opt/cloud-architect-agents"

mkdir -p "$REPO_DIR"

if [ ! -d "$REPO_DIR/.git" ]; then
  git clone https://github.com/unboxd-cloud/cloud-architect-agents.git "$REPO_DIR"
else
  cd "$REPO_DIR"
  git pull origin main
fi

cd "$REPO_DIR"

echo "[deploy] Applying namespace..."
kubectl apply -f manifests/namespace.yaml

echo "[deploy] Deploying SurrealDB..."
kubectl apply -f manifests/surrealdb.yaml

echo "[deploy] Waiting for SurrealDB..."
kubectl rollout status deployment/surrealdb -n cloud-architect-agents --timeout=180s

echo "[deploy] Deploying k8smicro worker..."
kubectl apply -f manifests/k8smicro-worker.yaml

echo "[deploy] Waiting for worker rollout..."
kubectl rollout status deployment/k8smicro-worker -n cloud-architect-agents --timeout=180s

echo "[deploy] Cluster status"
kubectl get pods -n cloud-architect-agents
