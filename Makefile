# Makefile para Go Backend
# Comandos útiles para desarrollo y deployment

.PHONY: help build run test clean docker-build docker-run docker-stop deploy down logs shell

# Variables
BINARY_NAME=server
BINARY_PATH=./bin/$(BINARY_NAME)
DOCKER_IMAGE=first-go-app
DOCKER_CONTAINER=first-app

# Color output
GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
RESET  := $(shell tput -Txterm sgr0)

help: ## Muestra esta ayuda
	@echo ''
	@echo 'Uso:'
	@echo '  make ${YELLOW}<target>${RESET}'
	@echo ''
	@echo 'Targets:'
	@awk 'BEGIN {FS = ":.*?## "} { \
		if (/^[a-zA-Z_-]+:.*?##.*$$/) {printf "  ${YELLOW}%-20s${GREEN}%s${RESET}\n", $$1, $$2} \
		else if (/^## .*$$/) {printf "  ${GREEN}%s${RESET}\n", substr($$1,4)} \
		}' $(MAKEFILE_LIST)

## Desarrollo Local

build: ## Compila la aplicación localmente
	@echo "${GREEN}→ Compilando aplicación...${RESET}"
	@chmod +x build.sh
	@./build.sh

run: build ## Compila y ejecuta la aplicación localmente
	@echo "${GREEN}→ Ejecutando aplicación...${RESET}"
	@$(BINARY_PATH)

test: ## Ejecuta los tests
	@echo "${GREEN}→ Ejecutando tests...${RESET}"
	@go test ./... -v

clean: ## Limpia archivos compilados
	@echo "${GREEN}→ Limpiando archivos compilados...${RESET}"
	@rm -rf ./bin
	@go clean

deps: ## Descarga dependencias
	@echo "${GREEN}→ Descargando dependencias...${RESET}"
	@go mod download
	@go mod verify
	@go mod tidy

## Docker - Build y Run Manual

docker-build: ## Construye la imagen Docker
	@echo "${GREEN}→ Construyendo imagen Docker...${RESET}"
	@docker build -t $(DOCKER_IMAGE) .

docker-run: ## Ejecuta el contenedor Docker
	@echo "${GREEN}→ Ejecutando contenedor Docker...${RESET}"
	@docker run -d \
		--name $(DOCKER_CONTAINER) \
		-p 1323:1323 \
		--env-file .env \
		$(DOCKER_IMAGE)

docker-stop: ## Detiene y elimina el contenedor Docker
	@echo "${GREEN}→ Deteniendo contenedor Docker...${RESET}"
	@docker stop $(DOCKER_CONTAINER) || true
	@docker rm $(DOCKER_CONTAINER) || true

## Docker Compose

deploy: ## Levanta todos los servicios con Docker Compose
	@echo "${GREEN}→ Levantando servicios con Docker Compose...${RESET}"
	@docker-compose up -d

down: ## Detiene todos los servicios
	@echo "${GREEN}→ Deteniendo servicios...${RESET}"
	@docker-compose down

restart: ## Reinicia todos los servicios
	@echo "${GREEN}→ Reiniciando servicios...${RESET}"
	@docker-compose restart

rebuild: ## Reconstruye y levanta los servicios
	@echo "${GREEN}→ Reconstruyendo servicios...${RESET}"
	@docker-compose up -d --build

logs: ## Muestra logs de todos los servicios
	@docker-compose logs -f

logs-app: ## Muestra logs solo de la aplicación
	@docker-compose logs -f app

logs-db: ## Muestra logs solo de PostgreSQL
	@docker-compose logs -f postgres

## Utilidades

shell: ## Abre una shell en el contenedor de la app
	@docker-compose exec app sh

db-shell: ## Abre una shell de PostgreSQL
	@docker-compose exec postgres psql -U postgres -d own_assistant

db-backup: ## Crea un backup de la base de datos
	@echo "${GREEN}→ Creando backup de la base de datos...${RESET}"
	@docker-compose exec postgres pg_dump -U postgres own_assistant > backup_$(shell date +%Y%m%d_%H%M%S).sql
	@echo "${GREEN}✓ Backup creado${RESET}"

db-restore: ## Restaura la base de datos desde backup.sql
	@echo "${GREEN}→ Restaurando base de datos...${RESET}"
	@docker-compose exec -T postgres psql -U postgres own_assistant < backup.sql
	@echo "${GREEN}✓ Base de datos restaurada${RESET}"

status: ## Muestra el estado de los contenedores
	@docker-compose ps

clean-docker: down ## Limpia todos los contenedores, imágenes y volúmenes
	@echo "${YELLOW}⚠ Esto eliminará TODOS los datos. ¿Continuar? [y/N]${RESET}" && read ans && [ $${ans:-N} = y ]
	@docker-compose down -v
	@docker rmi $(DOCKER_IMAGE) || true
	@echo "${GREEN}✓ Limpieza completada${RESET}"

env: ## Crea archivo .env desde .env.example
	@if [ ! -f .env ]; then \
		cp .env.example .env; \
		echo "${GREEN}✓ Archivo .env creado. Por favor edítalo con tus valores.${RESET}"; \
	else \
		echo "${YELLOW}⚠ El archivo .env ya existe.${RESET}"; \
	fi

## Desarrollo

fmt: ## Formatea el código
	@echo "${GREEN}→ Formateando código...${RESET}"
	@go fmt ./...

lint: ## Ejecuta el linter
	@echo "${GREEN}→ Ejecutando linter...${RESET}"
	@golangci-lint run || echo "Instala golangci-lint: https://golangci-lint.run/usage/install/"

.DEFAULT_GOAL := help
