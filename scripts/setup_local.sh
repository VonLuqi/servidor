#!/usr/bin/env bash
set -euo pipefail

# Setup local (venv) for Crafty Controller inside the repo
# - Creates minecraft/.venv
# - Installs requirements
# - Prints how to start the panel

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VENV_DIR="$ROOT_DIR/minecraft/.venv"
CRAFTY_DIR="$ROOT_DIR/minecraft/crafty-4"
REQS_FILE="$CRAFTY_DIR/requirements.txt"
RUN_SCRIPT="$ROOT_DIR/minecraft/run_crafty.sh"

echo "[setup_local] Verificando dependências básicas..."
command -v python3 >/dev/null 2>&1 || { echo "python3 não encontrado"; exit 1; }
command -v git >/dev/null 2>&1 || { echo "git não encontrado"; exit 1; }

if ! python3 -c 'import venv' 2>/dev/null; then
  echo "Módulo venv não encontrado. Instalando..."
  if [ -d "/etc/apt" ]; then
    sudo apt update -y && sudo apt install -y python3-venv
  elif [ -d "/etc/pacman.d" ]; then
    sudo pacman -Sy --noconfirm python-virtualenv
  else
    sudo dnf install -y python3-virtualenv
  fi
fi

echo "[setup_local] Criando venv em $VENV_DIR ..."
python3 -m venv "$VENV_DIR"
source "$VENV_DIR/bin/activate"
python3 -m pip install -U pip

if [ ! -d "$CRAFTY_DIR" ]; then
  echo "[setup_local] Clonando Crafty Controller..."
  git clone --depth=1 https://gitlab.com/crafty-controller/crafty-4.git "$CRAFTY_DIR"
fi

if [ ! -f "$REQS_FILE" ]; then
  echo "Arquivo de requisitos não encontrado em: $REQS_FILE" >&2
  exit 1
fi

echo "[setup_local] Instalando requirements do Crafty..."
pip install -r "$REQS_FILE"

echo
echo "[setup_local] Pronto! Para iniciar o painel agora:" 
echo "bash $RUN_SCRIPT"
echo
echo "Acesse: http://SEU_IP:8000 (ou https://SEU_IP:8443 se habilitado)"