#!/usr/bin/env bash
set -euo pipefail

# Setup Crafty como serviço systemd usando o instalador oficial incluído
# - Roda o instalador com modo não interativo (unattended)
# - Gera e habilita o serviço systemd automaticamente
# - Instala em /var/opt/minecraft/crafty

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
INSTALLER_DIR="$ROOT_DIR/crafty-installer-4.0"
TMP_INSTALLER="/tmp/crafty-installer-4.0"
CFG="$INSTALLER_DIR/config.json"
BACKUP="$INSTALLER_DIR/config.json.bak"

if [ ! -d "$INSTALLER_DIR" ]; then
  echo "[setup_service] Instalador local não encontrado. Baixando do repositório oficial..."
  command -v git >/dev/null 2>&1 || { echo "git não encontrado"; exit 1; }
  rm -rf "$TMP_INSTALLER"
  git clone --depth=1 https://gitlab.com/crafty-controller/crafty-installer-4.0.git "$TMP_INSTALLER"
  INSTALLER_DIR="$TMP_INSTALLER"
  CFG="$INSTALLER_DIR/config.json"
  BACKUP="$INSTALLER_DIR/config.json.bak"
fi

if [ ! -f "$INSTALLER_DIR/install_crafty.sh" ]; then
  echo "Script do instalador não encontrado: $INSTALLER_DIR/install_crafty.sh" >&2
  exit 1
fi

# Captura config existente e cria uma variante unattended
echo "[setup_service] Preparando configuração unattended do instalador..."
cp -f "$CFG" "$BACKUP"

# Lê valores atuais, força unattended=true e branch=master (estável)
# Usa jq se disponível; senão, escreve um JSON mínimo válido.
if command -v jq >/dev/null 2>&1; then
  tmp="$(mktemp)"
  jq '.unattended=true | .branch="master" | .clone_method="https"' "$BACKUP" > "$tmp"
  mv "$tmp" "$CFG"
else
  cat > "$CFG" << 'JSON'
{
  "install_dir": "/var/opt/minecraft/crafty",
  "unattended": true,
  "clone_method": "https",
  "branch": "master",
  "install_all_software": true,
  "debug_mode": false
}
JSON
fi

echo "[setup_service] Executando instalador (será solicitado sudo quando necessário)..."
sudo bash "$INSTALLER_DIR/install_crafty.sh"

echo "[setup_service] Recarregando daemon do systemd e habilitando serviço..."
sudo systemctl daemon-reload || true
sudo systemctl enable crafty.service || true
sudo systemctl restart crafty.service || true

# Restaura config original
mv -f "$BACKUP" "$CFG" || true

# Limpa instalador temporário, se usado
if [ "${TMP_INSTALLER:-}" != "" ] && [ -d "$TMP_INSTALLER" ]; then
  rm -rf "$TMP_INSTALLER"
fi

echo
echo "[setup_service] Pronto! O serviço 'crafty' deve estar rodando."
echo "Ver logs: sudo journalctl -u crafty -f"
echo "Acesse: http://SEU_IP:8000 (ou https://SEU_IP:8443 se habilitado)"