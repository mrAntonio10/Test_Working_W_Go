@echo off
REM Script de deployment para Windows
REM Este script facilita el deployment con Docker Compose en Windows

setlocal enabledelayedexpansion

echo ================================================
echo   Go Backend - Docker Deployment (Windows)
echo ================================================
echo.

REM Verificar si Docker está instalado
where docker >nul 2>nul
if %errorlevel% neq 0 (
    echo [ERROR] Docker no esta instalado.
    echo Por favor instala Docker Desktop desde: https://www.docker.com/get-started
    pause
    exit /b 1
)

echo [OK] Docker esta instalado
echo.

REM Verificar si docker-compose está disponible
where docker-compose >nul 2>nul
if %errorlevel% neq 0 (
    docker compose version >nul 2>nul
    if %errorlevel% neq 0 (
        echo [ERROR] Docker Compose no esta disponible.
        pause
        exit /b 1
    )
    set COMPOSE_CMD=docker compose
) else (
    set COMPOSE_CMD=docker-compose
)

echo [OK] Docker Compose esta disponible
echo.

REM Verificar si existe .env
if not exist .env (
    echo [WARNING] No se encontro el archivo .env
    echo Creando .env desde .env.example...
    copy .env.example .env
    echo.
    echo [INFO] Por favor edita el archivo .env con tus configuraciones
    echo y ejecuta este script nuevamente.
    echo.
    pause
    exit /b 0
)

echo [OK] Archivo .env encontrado
echo.

REM Mostrar menu
echo Selecciona una opcion:
echo.
echo   1. Levantar servicios (deploy)
echo   2. Detener servicios
echo   3. Ver logs
echo   4. Reconstruir y levantar
echo   5. Ver estado de servicios
echo   6. Backup de base de datos
echo   7. Limpiar todo (CUIDADO: borra datos)
echo   0. Salir
echo.

set /p choice="Opcion: "

if "%choice%"=="1" goto deploy
if "%choice%"=="2" goto down
if "%choice%"=="3" goto logs
if "%choice%"=="4" goto rebuild
if "%choice%"=="5" goto status
if "%choice%"=="6" goto backup
if "%choice%"=="7" goto clean
if "%choice%"=="0" goto end
goto invalid

:deploy
echo.
echo [INFO] Levantando servicios...
%COMPOSE_CMD% up -d
if %errorlevel% equ 0 (
    echo.
    echo [SUCCESS] Servicios levantados correctamente!
    echo.
    echo Puedes acceder a la aplicacion en: http://localhost:1323
    echo.
    echo Para ver logs: %COMPOSE_CMD% logs -f
)
goto end

:down
echo.
echo [INFO] Deteniendo servicios...
%COMPOSE_CMD% down
if %errorlevel% equ 0 (
    echo.
    echo [SUCCESS] Servicios detenidos correctamente!
)
goto end

:logs
echo.
echo [INFO] Mostrando logs (Ctrl+C para salir)...
echo.
%COMPOSE_CMD% logs -f
goto end

:rebuild
echo.
echo [INFO] Reconstruyendo y levantando servicios...
%COMPOSE_CMD% up -d --build
if %errorlevel% equ 0 (
    echo.
    echo [SUCCESS] Servicios reconstruidos y levantados!
    echo.
    echo Puedes acceder a la aplicacion en: http://localhost:1323
)
goto end

:status
echo.
echo [INFO] Estado de los servicios:
echo.
%COMPOSE_CMD% ps
echo.
docker stats --no-stream
goto end

:backup
echo.
echo [INFO] Creando backup de la base de datos...
set timestamp=%date:~-4%%date:~3,2%%date:~0,2%_%time:~0,2%%time:~3,2%%time:~6,2%
set timestamp=%timestamp: =0%
set backup_file=backup_%timestamp%.sql
%COMPOSE_CMD% exec -T postgres pg_dump -U postgres own_assistant > %backup_file%
if %errorlevel% equ 0 (
    echo.
    echo [SUCCESS] Backup creado: %backup_file%
)
goto end

:clean
echo.
echo [WARNING] Esto eliminara TODOS los contenedores, imagenes y DATOS.
set /p confirm="Estas seguro? (S/N): "
if /i "%confirm%"=="S" (
    echo.
    echo [INFO] Limpiando todo...
    %COMPOSE_CMD% down -v
    docker rmi first-go-app 2>nul
    echo.
    echo [SUCCESS] Limpieza completada
) else (
    echo.
    echo [INFO] Operacion cancelada
)
goto end

:invalid
echo.
echo [ERROR] Opcion invalida
goto end

:end
echo.
pause
