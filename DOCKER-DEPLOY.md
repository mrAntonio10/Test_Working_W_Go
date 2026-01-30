# Guía de Deployment con Docker

Esta guía te ayudará a compilar y desplegar tu aplicación Go Backend usando Docker.

## 📋 Pre-requisitos

- Docker instalado ([Descargar Docker](https://www.docker.com/get-started))
- Docker Compose instalado (viene incluido con Docker Desktop)
- Git Bash o WSL en Windows (para ejecutar scripts bash)

## 🚀 Opción 1: Deployment con Docker Compose (Recomendado)

Esta opción despliega tanto la aplicación como PostgreSQL automáticamente.

### 1. Configurar variables de entorno

Crea un archivo `.env` en la raíz del proyecto:

```bash
cp .env.example .env
```

Edita el archivo `.env` con tus valores:

```env
# Database Configuration
DB_HOST=postgres
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=tu_contraseña_segura
DB_NAME=own_assistant
DB_SSLMODE=disable

# Server Configuration
SERVER_PORT=1323

# Environment
ENV=production
```

### 2. Levantar los servicios

```bash
docker-compose up -d
```

Esto hará:
- Descargar la imagen de PostgreSQL
- Compilar tu aplicación Go
- Crear y levantar ambos contenedores
- Configurar la red entre ellos

### 3. Verificar que todo está corriendo

```bash
# Ver logs
docker-compose logs -f

# Ver solo logs de la app
docker-compose logs -f app

# Verificar estado
docker-compose ps
```

### 4. Probar la aplicación

```bash
curl http://localhost:1323/
```

Deberías ver: "Server is running with TOON support!"

### 5. Detener los servicios

```bash
# Detener
docker-compose stop

# Detener y eliminar contenedores
docker-compose down

# Detener, eliminar contenedores Y datos
docker-compose down -v
```

## 🔧 Opción 2: Build Manual con Script Bash

Si prefieres compilar localmente antes de dockerizar:

### 1. Dar permisos de ejecución al script

```bash
chmod +x build.sh
```

### 2. Ejecutar el script de build

```bash
./build.sh
```

El script:
- Verifica que Go esté instalado
- Descarga dependencias
- Verifica las dependencias
- Compila la aplicación
- Crea el binario en `./bin/server`

### 3. Ejecutar localmente

```bash
./bin/server
```

## 🐳 Opción 3: Solo Docker (sin Compose)

Si solo quieres dockerizar la aplicación (sin PostgreSQL):

### 1. Construir la imagen

```bash
docker build -t first-go-app .
```

### 2. Ejecutar el contenedor

```bash
docker run -d \
  --name first-app \
  -p 1323:1323 \
  -e DB_HOST=tu_postgres_host \
  -e DB_USER=postgres \
  -e DB_PASSWORD=tu_contraseña \
  -e DB_NAME=own_assistant \
  first-go-app
```

### 3. Ver logs

```bash
docker logs -f first-app
```

## 🔍 Comandos Útiles

```bash
# Reconstruir la imagen
docker-compose build --no-cache

# Reiniciar solo la app
docker-compose restart app

# Ver logs en tiempo real
docker-compose logs -f app

# Ejecutar comandos dentro del contenedor
docker-compose exec app sh

# Ver uso de recursos
docker stats

# Limpiar todo (cuidado: borra volúmenes)
docker-compose down -v
docker system prune -a
```

## 🗄️ Gestión de Base de Datos

### Conectarse a PostgreSQL

```bash
docker-compose exec postgres psql -U postgres -d own_assistant
```

### Backup de la base de datos

```bash
docker-compose exec postgres pg_dump -U postgres own_assistant > backup.sql
```

### Restaurar backup

```bash
docker-compose exec -T postgres psql -U postgres own_assistant < backup.sql
```

## 🌐 Deployment en Producción

### Variables de entorno importantes

Asegúrate de configurar en producción:

```env
ENV=production
DB_PASSWORD=una_contraseña_muy_segura
DB_SSLMODE=require  # Para conexiones seguras
```

### Recomendaciones

1. **Usar secretos**: No commites el archivo `.env` a Git
2. **HTTPS**: Usa un reverse proxy como Nginx o Traefik
3. **Logs**: Configura log rotation
4. **Backups**: Automatiza backups de PostgreSQL
5. **Monitoreo**: Usa herramientas como Prometheus + Grafana

## 🐛 Troubleshooting

### La app no se conecta a PostgreSQL

```bash
# Verifica que PostgreSQL esté saludable
docker-compose ps

# Revisa los logs de PostgreSQL
docker-compose logs postgres
```

### Puerto 1323 ya está en uso

Cambia el puerto en `.env`:
```env
SERVER_PORT=8080
```

Y actualiza el mapeo en `docker-compose.yml`.

### Rebuild después de cambios en el código

```bash
docker-compose up -d --build
```

## 📚 Estructura de Archivos Docker

```
first/
├── Dockerfile              # Definición de imagen Docker
├── docker-compose.yml      # Orquestación de servicios
├── .dockerignore          # Archivos ignorados en build
├── build.sh               # Script de compilación
├── .env.example           # Template de variables
└── .env                   # Variables de entorno (no commitear)
```

## ✅ Checklist de Deployment

- [ ] Configurar `.env` con valores correctos
- [ ] Verificar que Docker esté corriendo
- [ ] Ejecutar `docker-compose up -d`
- [ ] Verificar logs con `docker-compose logs -f`
- [ ] Probar endpoint: `curl http://localhost:1323/`
- [ ] Configurar backups de PostgreSQL
- [ ] Configurar reverse proxy si es necesario

---

**¡Listo!** Tu aplicación Go Backend ahora está dockerizada y lista para deployment.
