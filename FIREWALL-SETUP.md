# Configuración de Firewall para Acceso Público

Esta guía te ayuda a **exponer tu aplicación a Internet** para que sea accesible desde cualquier IP.

## 🔓 Las 3 Capas Necesarias

Para que tu API sea accesible desde Internet necesitas configurar:

1. ✅ **Docker** - Publicar el puerto (ya configurado)
2. ✅ **Aplicación Go** - Escuchar en 0.0.0.0 (ya configurado)
3. ⚠️ **Firewall Ubuntu** - Permitir el puerto (debes configurar)

## 🛡️ Configurar Firewall en Ubuntu (UFW)

### 1. Verificar estado actual del firewall

```bash
# Ver si UFW está activo
sudo ufw status

# Ver reglas actuales
sudo ufw status numbered
```

### 2. Permitir el puerto de la aplicación

```bash
# Permitir puerto 1323 (o el que uses)
sudo ufw allow 1323/tcp

# Verificar que se agregó
sudo ufw status
```

Deberías ver algo como:

```
Status: active

To                         Action      From
--                         ------      ----
1323/tcp                   ALLOW       Anywhere
1323/tcp (v6)              ALLOW       Anywhere (v6)
```

### 3. Si UFW no está habilitado

```bash
# IMPORTANTE: Primero permite SSH para no quedarte sin acceso
sudo ufw allow ssh
sudo ufw allow 22/tcp

# Luego habilita UFW
sudo ufw enable

# Permite tu aplicación
sudo ufw allow 1323/tcp
```

## ☁️ Configurar Security Groups (Si usas VPS en la nube)

### AWS EC2

1. Ve a **EC2 Console** > **Security Groups**
2. Selecciona el Security Group de tu instancia
3. **Inbound Rules** > **Edit**
4. **Add Rule**:
   - Type: Custom TCP
   - Port Range: 1323
   - Source: 0.0.0.0/0 (o la IP específica)
   - Description: Go Backend API

### DigitalOcean Droplet

1. Ve a **Networking** > **Firewalls**
2. Selecciona tu firewall
3. **Inbound Rules** > **Add Rule**:
   - Type: Custom
   - Protocol: TCP
   - Port Range: 1323
   - Sources: All IPv4, All IPv6

### Google Cloud (GCP)

1. Ve a **VPC Network** > **Firewall**
2. **Create Firewall Rule**:
   - Name: allow-go-backend
   - Direction: Ingress
   - Action: Allow
   - Targets: All instances
   - Source IP ranges: 0.0.0.0/0
   - Protocols and ports: tcp:1323

### Azure VM

1. Ve a **Virtual machines** > tu VM > **Networking**
2. **Add inbound port rule**:
   - Source: Any
   - Source port ranges: *
   - Destination: Any
   - Destination port ranges: 1323
   - Protocol: TCP
   - Action: Allow

## ✅ Verificar Configuración

### 1. Verificar que Docker está publicando el puerto

```bash
# Ver puertos publicados
docker ps --format "table {{.Names}}\t{{.Ports}}"
```

Deberías ver:

```
NAMES       PORTS
first-app   0.0.0.0:1323->1323/tcp
```

### 2. Verificar que el servidor escucha en 0.0.0.0

```bash
# Ver qué está escuchando en el puerto 1323
sudo netstat -tulpn | grep 1323

# O con ss
sudo ss -tulpn | grep 1323
```

Deberías ver:

```
tcp    0    0 0.0.0.0:1323    0.0.0.0:*    LISTEN    -
```

**Importante**: `0.0.0.0:1323` significa que escucha en TODAS las interfaces (accesible desde cualquier IP).

### 3. Probar acceso local

```bash
# Desde el mismo servidor
curl http://localhost:1323/

# Desde la IP pública del servidor
curl http://TU_IP_PUBLICA:1323/
```

### 4. Probar acceso externo

```bash
# Desde otra máquina o tu computadora
curl http://TU_IP_PUBLICA:1323/

# O en el navegador
http://TU_IP_PUBLICA:1323/
```

## 🔍 Obtener tu IP Pública

```bash
# Método 1
curl ifconfig.me

# Método 2
curl ipinfo.io/ip

# Método 3
dig +short myip.opendns.com @resolver1.opendns.com

# Método 4 (desde dentro del servidor)
hostname -I
```

## 🐛 Troubleshooting

### No puedo acceder desde Internet

**1. Verificar que Docker esté publicando el puerto:**

```bash
docker ps | grep first-app
```

Debe mostrar: `0.0.0.0:1323->1323/tcp`

**2. Verificar firewall local:**

```bash
sudo ufw status | grep 1323
```

Si no aparece:

```bash
sudo ufw allow 1323/tcp
```

**3. Verificar que el proceso escuche en 0.0.0.0:**

```bash
sudo netstat -tulpn | grep 1323
```

Debe decir `0.0.0.0:1323` no `127.0.0.1:1323`

**4. Probar conectividad básica:**

```bash
# Ver si el puerto está abierto externamente
telnet TU_IP_PUBLICA 1323

# O usar nmap desde otra máquina
nmap -p 1323 TU_IP_PUBLICA
```

### Error: "Connection refused"

```bash
# Verificar que el contenedor esté corriendo
docker ps | grep first-app

# Ver logs del contenedor
docker logs first-app

# Reiniciar el contenedor
docker restart first-app
```

### Error: "No route to host"

- Verifica el Security Group de tu VPS
- Asegúrate de que el firewall de la nube permita el puerto

### Puerto bloqueado por el proveedor

Algunos proveedores bloquean ciertos puertos. Si 1323 está bloqueado:

```bash
# Cambiar a otro puerto (ej: 8080)
# Edita .env
nano .env

# Cambia SERVER_PORT=1323 por
SERVER_PORT=8080

# Redeploy
./deploy.sh

# Permite el nuevo puerto en UFW
sudo ufw allow 8080/tcp
```

## 🔒 Seguridad Adicional (Recomendado)

### 1. Usar Nginx como Reverse Proxy

En lugar de exponer directamente el puerto 1323, usa Nginx:

```bash
# Instalar Nginx
sudo apt-get install nginx -y

# Crear configuración
sudo nano /etc/nginx/sites-available/go-backend
```

Contenido:

```nginx
server {
    listen 80;
    server_name tu-dominio.com;  # o tu IP pública

    location / {
        proxy_pass http://localhost:1323;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;
    }
}
```

```bash
# Activar sitio
sudo ln -s /etc/nginx/sites-available/go-backend /etc/nginx/sites-enabled/

# Probar configuración
sudo nginx -t

# Reiniciar Nginx
sudo systemctl restart nginx

# Permitir HTTP en firewall
sudo ufw allow 'Nginx Full'

# Bloquear acceso directo al 1323 (opcional)
sudo ufw delete allow 1323/tcp
```

Ahora accedes por: `http://TU_IP_PUBLICA/` (puerto 80)

### 2. Agregar SSL/HTTPS (Recomendado para producción)

```bash
# Instalar Certbot
sudo apt-get install certbot python3-certbot-nginx -y

# Obtener certificado (necesitas un dominio)
sudo certbot --nginx -d tu-dominio.com

# Renovación automática (ya configurada)
sudo certbot renew --dry-run
```

### 3. Limitar acceso por IP (Opcional)

Si solo quieres permitir IPs específicas:

```bash
# Eliminar regla que permite todo
sudo ufw delete allow 1323/tcp

# Permitir solo IP específica
sudo ufw allow from TU_IP_CLIENTE to any port 1323 proto tcp

# Permitir rango de IPs
sudo ufw allow from 192.168.1.0/24 to any port 1323 proto tcp
```

## 📊 Verificación Final

Después de configurar todo, verifica:

```bash
# 1. Docker publica el puerto
docker ps --format "table {{.Names}}\t{{.Ports}}"
# Debe mostrar: 0.0.0.0:1323->1323/tcp

# 2. Firewall permite el puerto
sudo ufw status | grep 1323
# Debe mostrar: 1323/tcp ALLOW Anywhere

# 3. Proceso escucha en 0.0.0.0
sudo netstat -tulpn | grep 1323
# Debe mostrar: 0.0.0.0:1323

# 4. Acceso desde Internet (desde otra máquina)
curl http://TU_IP_PUBLICA:1323/
# Debe mostrar: Server is running with TOON support!
```

## ✅ Checklist

- [ ] Docker publicando puerto: `0.0.0.0:1323->1323/tcp` ✓
- [ ] Go escuchando en `0.0.0.0:1323` ✓
- [ ] UFW permite puerto 1323 (ejecutar `sudo ufw allow 1323/tcp`)
- [ ] Security Group de VPS permite puerto 1323
- [ ] Probado acceso desde Internet
- [ ] (Opcional) Nginx configurado
- [ ] (Opcional) SSL/HTTPS configurado

---

**¡Listo!** Tu aplicación ahora es accesible desde cualquier parte del mundo. 🌍
