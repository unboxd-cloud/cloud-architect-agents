#!/usr/bin/env bash
set -euo pipefail

export INSTALL_K3S_EXEC="--write-kubeconfig-mode 644 --disable servicelb"

echo "[k8smicro] Installing k3s..."
curl -sfL https://get.k3s.io | sh -

echo "[k8smicro] Configuring kubeconfig..."
mkdir -p ~/.kube
sudo cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
sudo chown $(id -u):$(id -g) ~/.kube/config
chmod 600 ~/.kube/config

echo "[k8smicro] Waiting for node readiness..."
kubectl wait --for=condition=Ready node --all --timeout=180s

echo "[k8smicro] Cluster info"
kubectl cluster-info
kubectl get nodes -o wide
