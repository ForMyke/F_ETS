COMPOSE     = docker compose
PORT_PROD   = 8080
PORT_DEV    = 5000

.PHONY: help build-prod up down restart logs shell \
        dev-build dev dev-down dev-logs dev-shell \
        clean rebuild

help:
	@echo ""
	@echo "  F_ETS Flutter Web — Comandos disponibles"
	@echo "  ─────────────────────────────────────────────────────────"
	@awk 'BEGIN {FS = ":.*##"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-14s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
	@echo ""

build-prod: ## Construye la imagen de producción
	$(COMPOSE) build flutter-web

up: ## Levanta producción
	$(COMPOSE) up -d flutter-web

down: ## Detiene producción
	$(COMPOSE) down

restart: ## Reinicia producción
	$(COMPOSE) restart flutter-web

logs: ## Logs de producción
	$(COMPOSE) logs -f flutter-web

shell: ## Shell en contenedor de producción
	docker exec -it f_ets_web sh

dev-build: ## Construye la imagen de desarrollo
	$(COMPOSE) --profile dev build flutter-dev

dev: ## Levanta desarrollo con hot-reload
	$(COMPOSE) --profile dev up flutter-dev

dev-down: ## Detiene desarrollo
	$(COMPOSE) --profile dev down

dev-logs: ## Logs de desarrollo
	$(COMPOSE) --profile dev logs -f flutter-dev

dev-shell: ## Shell en contenedor de desarrollo
	docker exec -it f_ets_dev sh

rebuild: ## Reconstruye todo sin caché
	$(COMPOSE) build --no-cache flutter-web
	$(COMPOSE) --profile dev build --no-cache flutter-dev

clean: ## Elimina contenedores, imágenes y volúmenes
	$(COMPOSE) --profile dev down --rmi all --volumes --remove-orphans