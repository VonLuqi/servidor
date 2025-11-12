# Servidor Minecraft Bedrock (para jogar eternamente com os amigos)

> Painel e automação para hospedar e administrar um servidor de Minecraft — foco em Bedrock Edition — de forma simples e duradoura.

Este repositório empacota o Crafty Controller 4 (painel web em Python) com scripts de execução, atualização e um serviço systemd prontos para uso. A ideia é manter um servidor “sempre no ar” para jogar com os amigos, com backups, atualização fácil e opções de execução local ou via Docker.


## Visão geral

- Painel: Crafty Controller 4.5.x (web UI para gerenciar servidores Minecraft)
- Edição alvo: Bedrock (porta padrão 19132/UDP). Também suporta Java se quiser.
- Formas de rodar:
	- Local com Python/venv (scripts incluídos)
	- Como serviço systemd (auto‑start no boot)
	- Via Docker/Docker Compose (opcional)
- Backups, logs e múltiplos servidores administrados pelo painel


## Início rápido

Você escolhe um dos dois jeitos abaixo (ambos inclusos no repo):

- Local (rápido, ideal para dev/teste): cria venv no próprio repositório
- Serviço systemd (produção): instala em /var/opt e inicia no boot

Com Makefile (atalhos prontos):

```bash
# 1) Local (venv dentro do repo)
make local-install
make local-run

# 2) Serviço systemd (produção)
make service-install
make service-logs
```

Sem Makefile, você pode usar os scripts diretamente:

```bash
# Local (venv)
bash scripts/setup_local.sh
bash minecraft/run_crafty.sh

# Serviço (instalador oficial + systemd)
bash scripts/setup_service.sh
```


## Requisitos

- Linux (testado em Ubuntu 22.04/24.04)
- Python 3.9+ e venv (o instalador cuida disso para você)
- Git e permissões sudo (para instalação como serviço)
- Rede/Firewalls liberados:
	- 8000 (HTTP) e/ou 8443 (HTTPS) para acessar o painel
	- 19132/UDP para jogadores Bedrock
	- 25500–25600 (TCP) caso você use múltiplos servidores/portas via Crafty
	- 8123 (opcional, Dynmap)


## Estrutura do projeto (essencial)

- `minecraft/crafty-4/` — Código do Crafty Controller (painel)
- `minecraft/run_crafty.sh` — Inicia o painel em modo foreground (usa venv `.venv`)
- `minecraft/run_crafty_service.sh` — Inicia o painel em modo daemon (para systemd)
- `minecraft/update_crafty.sh` — Atualiza o Crafty (git pull + pip install)
- `minecraft/crafty.service` — Unidade systemd pronta (User=crafty)
- `crafty-installer-4.0/` — Instalador oficial do Crafty para Linux (cria venv, usuário, deps)

Dica: após o primeiro start, as pastas como `backups/`, `servers/`, `logs/` são criadas/gerenciadas pelo Crafty em `minecraft/crafty-4/`.


## Instalação (recomendado: instalador oficial)

O instalador cuida das dependências, cria o usuário `crafty`, venv e pode registrar o serviço.

- Caminho padrão de instalação: `/var/opt/minecraft/crafty` (configurável em `crafty-installer-4.0/config.json`).

Opcional (documentação):
```bash
# Executa o instalador (pede sudo quando necessário)
./crafty-installer-4.0/install_crafty.sh
```
Durante o processo você pode optar por criar o serviço systemd automaticamente.


## Execução local (Python/venv)

Se você estiver usando este repositório diretamente (ex.: dev container), pode rodar o painel com o venv em `minecraft/.venv`:

Opcional (documentação):
```bash
# Criar venv se ainda não existir
python3 -m venv minecraft/.venv
source minecraft/.venv/bin/activate
pip install -U pip
pip install -r minecraft/crafty-4/requirements.txt

# Iniciar o painel
bash minecraft/run_crafty.sh
```
A interface web do Crafty ficará disponível nas portas 8000/8443 (veja abaixo sobre acesso).


## Serviço systemd (iniciar no boot)

Se você preferir rodar “em produção” como serviço:

1) Garanta que o usuário `crafty` exista (o instalador cria).  
2) Copie e habilite a unidade:

Opcional (documentação):
```bash
sudo cp minecraft/crafty.service /etc/systemd/system/crafty.service
sudo systemctl daemon-reload
sudo systemctl enable crafty.service
sudo systemctl start crafty.service

# Acompanhar logs
sudo journalctl -u crafty -f
```
A unidade usa `ExecStart=/usr/bin/bash /workspaces/servidor/minecraft/run_crafty_service.sh`. Ajuste o caminho se você instalar noutro diretório.


## Docker (opcional)

O Crafty possui suporte oficial a Docker. Há exemplos em `minecraft/crafty-4/docker/`.

- Portas normalmente mapeadas: 8000 (HTTP), 8443 (HTTPS), 19132/UDP (Bedrock), 25500–25600 (TCP para servidores), 8123 (Dynmap)
- Volumes recomendados: `backups`, `logs`, `servers`, `config`, `import`

Referência rápida (compose de exemplo no próprio projeto do Crafty):
```bash
# Dentro de minecraft/crafty-4/docker
docker compose up -d
```


## Como criar o servidor Bedrock no painel

1) Acesse o Crafty: `http://SEU_IP:8000` (ou `https://SEU_IP:8443` se habilitado).  
2) Faça o onboarding inicial (usuário admin) e crie um novo servidor.  
3) Tipo: “Bedrock” (o Crafty faz o download do binário quando necessário).  
4) Defina a porta UDP (padrão 19132) e aceite o EULA quando solicitado.  
5) Abra a porta no firewall/roteador e convide seus amigos pelo IP/porta configurados.


## Atualização do painel

Use o script incluído:

Opcional (documentação):
```bash
# Pergunta se pode sobrescrever alterações locais
bash minecraft/update_crafty.sh

# Ou forçar modo não interativo
bash minecraft/update_crafty.sh -y
```


## Backups e dados

- Backups, servidores e logs são gerenciados pelo Crafty e ficam dentro da instalação.  
- Caminho típico (execução local): `minecraft/crafty-4/{backups,servers,logs}`.  
- Em Docker, monte volumes persistentes para os mesmos diretórios.


## Dicas e troubleshooting

- Painel não abre? Verifique se as portas 8000/8443 estão expostas e se o processo está rodando (`journalctl -u crafty -f`).
- Bedrock sem conexão? Confirme liberação da 19132/UDP e IP/porta no cliente.
- Erro de Python/venv: recrie o venv e reinstale `requirements.txt`.
- Serviço falhando: ajuste caminhos no `crafty.service` e confira permissões do usuário `crafty`.


## Créditos e licença

- Crafty Controller © Arcadia Technology. Documentação: https://docs.craftycontrol.com  
- Licenças estão nos diretórios `minecraft/crafty-4/` e `crafty-installer-4.0/`.
