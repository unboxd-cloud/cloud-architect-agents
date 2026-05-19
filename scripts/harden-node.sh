#!/usr/bin/env bash
set -euo pipefail

echo "[k8smicro] Updating system packages..."
sudo apt-get update -y
sudo apt-get upgrade -y

echo "[k8smicro] Installing base dependencies..."
sudo apt-get install -y \
  curl \
  wget \
  git \
  vim \
  htop \
  fail2ban \
  ufw \
  ca-certificates \
  gnupg

echo "[k8smicro] Configuring firewall..."
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw allow 6443/tcp
sudo ufw --force enable

echo "[k8smicro] Enabling fail2ban..."
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

echo "[k8smicro] Disabling password SSH authentication..."
sudo sed -i 's/^#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/^PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo systemctl restart ssh || sudo systemctl restart sshd

echo "[k8smicro] Hardening complete."
