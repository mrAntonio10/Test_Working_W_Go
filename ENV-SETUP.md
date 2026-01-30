# Configuración de Variables de Entorno

Esta guía te ayudará a configurar correctamente las variables de entorno para tu aplicación Go.

## 🔐 Seguridad Primero

**IMPORTANTE**: Nunca commitees el archivo `.env` a Git. El archivo `.gitignore` ya está configurado para excluirlo.

## 📝 Configuración Inicial

### 1. Crear el archivo .env

```bash
# En Windows
copy .env.example .env

# En Linux/Mac
cp .env.example .env
```

### 2. Editar las Variables Requeridas

Abre el archivo `.env` y configura las siguientes variables **REQUERIDAS**:

```env
# REQUERIDO: Usuario de PostgreSQL
DB_USER=tu_usuario

# REQUERIDO: Contraseña de PostgreSQL
DB_PASSWORD=tu_contraseña_segura

# REQUERIDO: Nombre de la base de datos
DB_NAME=own_assistant
```

## 🗄️ Configuración de Base de Datos

### Desarrollo Local (PostgreSQL instalado localmente)

```env
DB_HOST=localhost
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=tu_contraseña_local
DB_NAME=own_assistant
DB_SSLMODE=disable
```

### Docker Compose (Recomendado)

```env
DB_HOST=postgres
DB_PORT=5432
DB_USER=postgres
DB_PASSWORD=tu_contraseña_segura
DB_NAME=own_assistant
DB_SSLMODE=disable
```

### Producción (Base de datos externa)

```env
DB_HOST=tu-servidor-postgres.com
DB_PORT=5432
DB_USER=usuario_produccion
DB_PASSWORD=contraseña_muy_segura_y_larga
DB_NAME=own_assistant
DB_SSLMODE=require  # ¡Importante para producción!
```

## 🌐 Configuración del Servidor

```env
# Puerto donde correrá el servidor
SERVER_PORT=1323

# Ambiente: development, staging, production
ENV=development
```

## 📋 Variables de Entorno Completas

| Variable | Tipo | Descripción | Default | Ejemplo |
|----------|------|-------------|---------|---------|
| `DB_USER` | **REQUERIDO** | Usuario de PostgreSQL | - | `postgres` |
| `DB_PASSWORD` | **REQUERIDO** | Contraseña de PostgreSQL | - | `my_secure_pass` |
| `DB_NAME` | **REQUERIDO** | Nombre de la base de datos | - | `own_assistant` |
| `DB_HOST` | Opcional | Host de PostgreSQL | `localhost` | `postgres` |
| `DB_PORT` | Opcional | Puerto de PostgreSQL | `5432` | `5432` |
| `DB_SSLMODE` | Opcional | Modo SSL de conexión | `disable` | `require` |
| `SERVER_PORT` | Opcional | Puerto del servidor | `1323` | `8080` |
| `ENV` | Opcional | Ambiente de ejecución | `development` | `production` |

## 🔒 Opciones de SSL Mode

| Modo | Descripción | Uso Recomendado |
|------|-------------|-----------------|
| `disable` | Sin SSL | Desarrollo local |
| `allow` | SSL si está disponible | - |
| `prefer` | Prefiere SSL | - |
| `require` | Requiere SSL (sin verificar) | Staging |
| `verify-ca` | SSL + Verifica CA | Producción |
| `verify-full` | SSL + Verifica CA + Host | Producción Alta Seguridad |

## ✅ Validación

La aplicación validará automáticamente que las variables **REQUERIDAS** estén configuradas al inicio.

Si falta alguna variable requerida, verás un error como:

```
ERROR: Required environment variable DB_USER is not set. Please check your .env file
```

## 🚀 Ejemplos de Configuración

### Ejemplo 1: Desarrollo Local

```env
# .env para desarrollo local
DB_USER=postgres
DB_PASSWORD=123456
DB_NAME=own_assistant
DB_HOST=localhost
DB_PORT=5432
DB_SSLMODE=disable
SERVER_PORT=1323
ENV=development
```

### Ejemplo 2: Docker Compose

```env
# .env para Docker Compose
DB_USER=postgres
DB_PASSWORD=my_docker_password
DB_NAME=own_assistant
DB_HOST=postgres
DB_PORT=5432
DB_SSLMODE=disable
SERVER_PORT=1323
ENV=production
```

### Ejemplo 3: Producción

```env
# .env para producción
DB_USER=prod_user
DB_PASSWORD=Sup3rS3cur3P@ssw0rd!2024
DB_NAME=own_assistant
DB_HOST=prod-db.example.com
DB_PORT=5432
DB_SSLMODE=require
SERVER_PORT=8080
ENV=production
```

## 🔧 Troubleshooting

### Error: "Required environment variable X is not set"

**Solución**: Verifica que el archivo `.env` existe y contiene todas las variables REQUERIDAS.

```bash
# Verifica que existe
ls -la .env

# Verifica el contenido
cat .env
```

### Error: "Could not connect to database"

**Solución**: Verifica que:
1. PostgreSQL esté corriendo
2. Las credenciales sean correctas
3. El host y puerto sean accesibles
4. La base de datos exista

```bash
# Prueba la conexión manualmente
psql -h localhost -U postgres -d own_assistant
```

### El archivo .env no se carga

**Solución**: El archivo debe estar en la raíz del proyecto donde está `server.go`.

```
first/
├── server.go
├── .env           ← Aquí debe estar
├── .env.example
└── ...
```

## 🛡️ Mejores Prácticas de Seguridad

1. **Nunca** commitees `.env` a Git
2. Usa contraseñas fuertes en producción (mínimo 16 caracteres)
3. Cambia las contraseñas por defecto
4. Usa `DB_SSLMODE=require` en producción
5. Limita los permisos del archivo `.env`:
   ```bash
   chmod 600 .env
   ```
6. Usa secretos de Docker/Kubernetes en producción real
7. Rota las contraseñas periódicamente
8. No compartas el archivo `.env` por email o chat

## 📚 Recursos Adicionales

- [Twelve-Factor App: Config](https://12factor.net/config)
- [PostgreSQL SSL Modes](https://www.postgresql.org/docs/current/libpq-ssl.html)
- [Docker Secrets](https://docs.docker.com/engine/swarm/secrets/)

---

**Recuerda**: La seguridad de tu aplicación comienza con una buena gestión de las variables de entorno. ¡No tomes atajos en producción!
