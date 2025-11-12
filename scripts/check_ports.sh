#!/usr/bin/env bash
set -euo pipefail

# Verifica portas e serviço para o Crafty/Minecraft Bedrock
# - HTTP 8000, HTTPS 8443
# - DYNMAP 8123 (opcional)
# - Bedrock 19132/udp
# - Range TCP 25500-25600 (servidores gerenciados)

PORTS_TCP=(8000 8443 8123)
PORTS_UDP=(19132)
RANGE_TCP_START=25500
RANGE_TCP_END=25600

has_cmd() { command -v "$1" >/dev/null 2>&1; }

ss_listen_tcp() {
  if has_cmd ss; then ss -ltnp; else netstat -ltnp; fi
}
ss_listen_udp() {
  if has_cmd ss; then ss -lunp; else netstat -lunp; fi
}

check_service() {
  if has_cmd systemctl; then
    if systemctl is-enabled -q crafty 2>/dev/null; then echo "[service] crafty: enabled"; fi
    if systemctl is-active -q crafty 2>/dev/null; then echo "[service] crafty: active"; else echo "[service] crafty: inactive"; fi
  else
    echo "[service] systemctl não disponível"
  fi
}

check_tcp_ports() {
  echo "[tcp] Verificando portas TCP: ${PORTS_TCP[*]}"
  local out
  out="$(ss_listen_tcp || true)"
  for p in "${PORTS_TCP[@]}"; do
    if echo "$out" | grep -q ":$p\>"; then
      echo "  - Porta $p: LISTEN"
    else
      echo "  - Porta $p: não encontrada em LISTEN"
    fi
  done
}

check_udp_ports() {
  echo "[udp] Verificando portas UDP: ${PORTS_UDP[*]}"
  local out
  out="$(ss_listen_udp || true)"
  for p in "${PORTS_UDP[@]}"; do
    if echo "$out" | grep -q ":$p\>"; then
      echo "  - Porta $p/udp: LISTEN"
    else
      echo "  - Porta $p/udp: não encontrada em LISTEN"
    fi
  done
}

check_tcp_range() {
  echo "[tcp-range] Verificando range TCP ${RANGE_TCP_START}-${RANGE_TCP_END} (opcional)"
  local out any=0
  out="$(ss_listen_tcp || true)"
  for ((p=RANGE_TCP_START; p<=RANGE_TCP_END; p++)); do
    if echo "$out" | grep -q ":$p\>"; then any=1; break; fi
  done
  if [ "$any" -eq 1 ]; then echo "  - Alguma porta no range está em LISTEN (ok)"; else echo "  - Nenhuma porta no range em LISTEN (ok se não usado)"; fi
}

check_firewall() {
  echo "[fw] Checando firewalls (ufw/firewalld/nftables)"
  if has_cmd ufw; then
    ufw status || true
  elif has_cmd firewall-cmd; then
    firewall-cmd --state || true
    firewall-cmd --list-ports || true
  elif has_cmd nft; then
    nft list ruleset | sed -n '1,120p' || true
  else
    echo "  - Nenhum gerenciador de firewall detectado (ok)."
  fi
}

main() {
  check_service
  check_tcp_ports
  check_udp_ports
  check_tcp_range
  check_firewall
  echo
  echo "Dicas:"
  echo "- Se o serviço estiver inactive, tente: sudo systemctl restart crafty && sudo journalctl -u crafty -f"
  echo "- Abra as portas no firewall/roteador: 8000/tcp, 8443/tcp, 19132/udp, 8123/tcp (opcional), 25500-25600/tcp (se usar)."
}

main "$@"
