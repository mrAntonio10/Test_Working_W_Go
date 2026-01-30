# Go Backend - Test Working W Go

Backend en Go con Echo framework y PostgreSQL.

## 🚀 Deploy Rápido

```bash
# 1. Dar permisos
chmod +x deploy.sh

# 2. Configurar .env (si no existe)
cp .env.example .env
nano .env

# 3. Deploy
./deploy.sh
```

## ✨ Características del Deploy

El script `deploy.sh` automáticamente:

- ✅ **Elimina el contenedor anterior** si existe
- ✅ **Elimina la imagen anterior** para no ocupar espacio
- ✅ **Compila una nueva imagen** con tus cambios
- ✅ **Inicia el contenedor** automáticamente
- ✅ **Limpia imágenes sin usar** (docker prune)
- ✅ **No instala PostgreSQL** - usa el que ya tienes corriendo

## 📋 Pre-requisitos

- Docker instalado
- PostgreSQL corriendo en localhost:5432
- Go 1.21+ (solo para compilación local)

## 🔧 Configuración

Edita el archivo `.env`:

```env
DB_USER=marcoro
DB_PASSWORD=4708
DB_NAME=own_assistant
DB_HOST=localhost
DB_PORT=5432
SERVER_PORT=1323
```

## 📊 Comandos Útiles

```bash
# Ver logs
docker logs -f first-app

# Reiniciar
docker restart first-app

# Detener
docker stop first-app

# Ver estado
docker ps | grep first-app

# Acceder al contenedor
docker exec -it first-app sh
```

## 🔄 Actualizar la Aplicación

Simplemente vuelve a ejecutar el deploy:

```bash
./deploy.sh
```

El script se encarga de todo automáticamente.

## 📝 Estructura del Proyecto

```
Test_Working_W_Go/
├── server.go           # Código principal
├── internal/           # Lógica interna
├── pkg/                # Paquetes compartidos
├── Dockerfile          # Imagen Docker
├── docker-compose.yml  # Configuración Docker (solo app)
├── deploy.sh           # Script de deployment
├── buildDocker.sh      # Script de compilación
└── .env                # Variables de entorno (no commitear)
```

## 🌐 Endpoints

- `GET /` - Health check

## 🔒 Seguridad

- No commitees el archivo `.env`
- Usa contraseñas seguras en producción
- El contenedor corre con usuario no-root

## 📚 Más Información

- [DOCKER-DEPLOY.md](DOCKER-DEPLOY.md) - Guía completa de Docker
- [ENV-SETUP.md](ENV-SETUP.md) - Configuración de variables de entorno
- [UBUNTU-DEPLOY.md](UBUNTU-DEPLOY.md) - Deploy en Ubuntu (producción)
