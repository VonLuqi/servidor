#!/usr/bin/env bash
set -euo pipefail

# Desinstalação segura do serviço Crafty (systemd)
# - Para e desabilita o serviço
# - Remove a unit /etc/systemd/system/crafty.service (se existir)
# - NÃO remove dados em /var/opt/minecraft/crafty (você decide depois)

if ! command -v systemctl >/dev/null 2>&1; then
  echo "systemctl não encontrado. Este script requer systemd." >&2
  exit 1
fi

SERVICE_NAME="crafty"
UNIT_FILE="/etc/systemd/system/${SERVICE_NAME}.service"

echo "[uninstall] Parando serviço (se ativo)..."
sudo systemctl stop "$SERVICE_NAME" || true

echo "[uninstall] Desabilitando serviço..."
sudo systemctl disable "$SERVICE_NAME" || true

if [ -f "$UNIT_FILE" ]; then
  echo "[uninstall] Removendo unit file: $UNIT_FILE"
  sudo rm -f "$UNIT_FILE"
fi

echo "[uninstall] Reload do daemon..."
sudo systemctl daemon-reload || true
sudo systemctl reset-failed || true

echo
INSTALL_DIR="/var/opt/minecraft/crafty"
echo "Serviço removido. Os dados do Crafty foram mantidos em: $INSTALL_DIR"
echo "Se deseja remover os dados, execute manualmente: sudo rm -rf $INSTALL_DIR"