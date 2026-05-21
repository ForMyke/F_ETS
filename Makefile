APP_NAME    = f_ets_web
COMPOSE     = docker compose
IMAGE       = f_ets_web
PORT        = 8080

.PHONY: help build up down restart logs shell clean rebuild dev

## Muestra esta ayuda
help:
	@echo ""
	@echo "  F_ETS Flutter Web — Comandos disponibles"
	@echo "  ─────────────────────────────────────────"
	@awk 'BEGIN {FS = ":.*##"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)
	@echo ""

build: ## Construir la imagen Docker
	$(COMPOSE) build

up: ## Levantar el contenedor (build si es necesario)
	$(COMPOSE) up --build -d
	@echo ""
	@echo "  ✅ App corriendo en http://localhost:$(PORT)"
	@echo ""

down: ## Detener y eliminar el contenedor
	$(COMPOSE) down

restart: ## Reiniciar el contenedor
	$(COMPOSE) restart

logs: ## Ver logs en tiempo real
	$(COMPOSE) logs -f $(APP_NAME)

shell: ## Entrar al shell del contenedor
	docker exec -it $(APP_NAME) sh

clean: ## Eliminar contenedor, imagen y volúmenes
	$(COMPOSE) down --rmi all --volumes --remove-orphans
	@echo "  🧹 Limpieza completa"

rebuild: ## Reconstruir sin caché y levantar
	$(COMPOSE) build --no-cache
	$(COMPOSE) up -d
	@echo ""
	@echo "  ✅ App reconstruida en http://localhost:$(PORT)"
	@echo ""

dev: ## Levantar en modo desarrollo (hot-reload)
	$(COMPOSE) --profile dev up flutter-dev