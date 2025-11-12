# Atalhos para instalar/rodar o Crafty de forma simples

.PHONY: help local-install local-run local-update service-install service-logs service-uninstall check-ports docker-up docker-down docker-logs

help:
	@echo "Targets disponíveis:"
	@echo "  make local-install   # cria venv e instala requirements"
	@echo "  make local-run       # inicia o painel localmente"
	@echo "  make local-update    # atualiza o Crafty (git pull + pip)"
	@echo "  make service-install # instala via instalador + habilita serviço systemd"
	@echo "  make service-logs    # segue logs do serviço crafty"
	@echo "  make service-uninstall # remove o serviço systemd (mantém dados)"
	@echo "  make check-ports     # verifica portas (8000/8443/19132/8123) e firewall"
	@echo "  make docker-up       # sobe o Crafty via docker compose (exemplo do projeto)"
	@echo "  make docker-down     # derruba os containers do compose"
	@echo "  make docker-logs     # segue logs dos containers"

local-install:
	bash scripts/setup_local.sh

local-run:
	bash minecraft/run_crafty.sh

local-update:
	bash minecraft/update_crafty.sh -y

service-install:
	bash scripts/setup_service.sh

service-logs:
	sudo journalctl -u crafty -f

service-uninstall:
	bash scripts/uninstall_service.sh

check-ports:
	bash scripts/check_ports.sh

docker-up:
	cd minecraft/crafty-4/docker && docker compose up -d

docker-down:
	cd minecraft/crafty-4/docker && docker compose down

docker-logs:
	cd minecraft/crafty-4/docker && docker compose logs -f
