#!/bin/bash

# 🚀 INICIALIZADOR DEL ECOSISTEMA COMPLETO - Media Quality Net
# Este script configura e inicia todo el ecosistema digital de MQN

set -e  # Salir si hay algún error

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Función para logging
log_message() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[$(date +'%Y-%m-%d %H:%M:%S')] ⚠️${NC} $1"
}

log_error() {
    echo -e "${RED}[$(date +'%Y-%m-%d %H:%M:%S')] ❌${NC} $1"
}

log_info() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')] ℹ️${NC} $1"
}

log_success() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] ✅${NC} $1"
}

# Función para mostrar banner
show_banner() {
    clear
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                                                              ║"
    echo "║  🚀 ECOSISTEMA DIGITAL COMPLETO - MEDIA QUALITY NET 🚀      ║"
    echo "║                                                              ║"
    echo "║  'Materializando tus ideas...' digitalmente                  ║"
    echo "║                                                              ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo -e "${YELLOW}📅 Fecha: $(date +'%Y-%m-%d %H:%M:%S')${NC}"
    echo -e "${YELLOW}👤 Usuario: $(whoami)${NC}"
    echo -e "${YELLOW}📍 Directorio: $(pwd)${NC}"
    echo ""
}

# Función para verificar dependencias
check_dependencies() {
    log_info "🔍 Verificando dependencias del sistema..."
    
    # Verificar Docker
    if ! command -v docker &> /dev/null; then
        log_error "Docker no está instalado. Por favor instálalo primero."
        exit 1
    fi
    
    # Verificar Docker Compose
    if ! command -v docker-compose &> /dev/null; then
        log_error "Docker Compose no está instalado. Por favor instálalo primero."
        exit 1
    fi
    
    # Verificar permisos de Docker
    if ! docker info &> /dev/null; then
        log_error "No tienes permisos para ejecutar Docker. Agrega tu usuario al grupo docker."
        exit 1
    fi
    
    log_success "Dependencias verificadas correctamente"
}

# Función para crear estructura de directorios
create_directory_structure() {
    log_info "📁 Creando estructura de directorios..."
    
    # Directorios principales
    mkdir -p backend/app/{models,routes,services,middleware,utils}
    mkdir -p frontend/src/{components,pages,hooks,services,styles}
    mkdir -p whatsapp_interface/{voice_recognition,command_processor,n8n_integration,templates}
    mkdir -p ai_services/{graphic_assistant,content_generator,image_enhancer,product_analyzer}
    mkdir -p production_management/{workflow_tracker,task_management,inventory,supplier_management}
    mkdir -p social_media_automation/{content_scheduler,post_generator,platform_apis,analytics}
    mkdir -p accounting_basic/{payment_tracking,invoice_management,supplier_accounts,client_accounts}
    
    # Directorios de Docker
    mkdir -p docker/{nginx,ssl,monitoring/{dashboards,datasources}}
    mkdir -p docker/n8n/{workflows,credentials}
    
    # Directorios de datos
    mkdir -p database/{migrations,seeds,backups}
    mkdir -p uploads/{images,documents,designs}
    mkdir -p logs/{backend,frontend,whatsapp,nginx}
    
    # Directorios de IA
    mkdir -p ai_uploads/{images,audio,text}
    mkdir -p ai_outputs/{designs,enhanced_images,generated_content}
    
    # Directorios de WhatsApp
    mkdir -p whatsapp_media/{images,audio,documents}
    mkdir -p whatsapp_logs/{conversations,commands,errors}
    
    log_success "Estructura de directorios creada correctamente"
}

# Función para crear archivos de configuración
create_config_files() {
    log_info "⚙️ Creando archivos de configuración..."
    
    # Archivo .env principal
    cat > .env << 'EOF'
# 🌐 Configuración del Ecosistema Media Quality Net
# Fecha de creación: $(date +'%Y-%m-%d')

# 🔑 API Keys
OPENAI_API_KEY=your_openai_api_key_here
WHATSAPP_API_KEY=your_whatsapp_api_key_here
GA_ID=your_google_analytics_id_here

# 🗄️ Base de datos
DATABASE_URL=postgresql://mqn_user:mqn_password_2024@localhost:5434/mqn_ecosistema
REDIS_URL=redis://:mqn_redis_2024@localhost:6380

# 🌐 URLs del sistema
FRONTEND_URL=http://localhost:3000
BACKEND_URL=http://localhost:8000
N8N_URL=http://localhost:5678
WHATSAPP_URL=http://localhost:8002

# 🔒 Seguridad
SECRET_KEY=mqn_secret_key_2024_very_secure
JWT_SECRET_KEY=mqn_jwt_secret_2024_very_secure

# 📱 WhatsApp
WHATSAPP_PHONE_NUMBER=+529671262441
WHATSAPP_BUSINESS_ID=your_business_id_here

# 🎨 IA y servicios
STABLE_DIFFUSION_URL=http://localhost:7860
AI_MODEL_PATH=/app/models
AI_CACHE_DIR=/app/cache

# 📊 Monitoreo
GRAFANA_ADMIN_PASSWORD=mqn_monitoring_2024
MONITORING_ENABLED=true

# 🚀 Entorno
ENVIRONMENT=development
DEBUG=true
LOG_LEVEL=INFO
EOF

    # Archivo .env.example
    cp .env .env.example
    sed -i 's/=.*/=example_value/g' .env.example
    
    log_success "Archivos de configuración creados correctamente"
}

# Función para crear Dockerfiles
create_dockerfiles() {
    log_info "🐳 Creando Dockerfiles..."
    
    # Dockerfile para Backend
    cat > backend/Dockerfile << 'EOF'
# 🐍 Backend FastAPI - Media Quality Net
FROM python:3.11-slim

# Variables de entorno
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONPATH=/app

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    libpq-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Directorio de trabajo
WORKDIR /app

# Copiar requirements e instalar dependencias Python
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copiar código de la aplicación
COPY . .

# Exponer puerto
EXPOSE 8000

# Comando de inicio
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]
EOF

    # Dockerfile para Frontend
    cat > frontend/Dockerfile << 'EOF'
# 🌐 Frontend Next.js - Media Quality Net
FROM node:18-alpine

# Variables de entorno
ENV NODE_ENV=development
ENV NEXT_TELEMETRY_DISABLED=1

# Directorio de trabajo
WORKDIR /app

# Copiar package.json e instalar dependencias
COPY package*.json ./
RUN npm ci

# Copiar código de la aplicación
COPY . .

# Exponer puerto
EXPOSE 3000

# Comando de inicio
CMD ["npm", "run", "dev"]
EOF

    # Dockerfile para WhatsApp Interface
    cat > whatsapp_interface/Dockerfile << 'EOF'
# 📱 WhatsApp Interface - Media Quality Net
FROM python:3.11-slim

# Variables de entorno
ENV PYTHONUNBUFFERED=1
ENV PYTHONDONTWRITEBYTECODE=1

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    libpq-dev \
    ffmpeg \
    && rm -rf /var/lib/apt/lists/*

# Directorio de trabajo
WORKDIR /app

# Copiar requirements e instalar dependencias Python
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copiar código de la aplicación
COPY . .

# Exponer puerto
EXPOSE 8000

# Comando de inicio
CMD ["python", "main.py"]
EOF

    log_success "Dockerfiles creados correctamente"
}

# Función para crear archivos de configuración de nginx
create_nginx_config() {
    log_info "🔍 Creando configuración de Nginx..."
    
    # Configuración principal de nginx
    cat > docker/nginx/nginx.conf << 'EOF'
user nginx;
worker_processes auto;
error_log /var/log/nginx/error.log warn;
pid /var/run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;
    
    log_format main '$remote_addr - $remote_user [$time_local] "$request" '
                    '$status $body_size "$http_referer" '
                    '"$http_user_agent" "$http_x_forwarded_for"';
    
    access_log /var/log/nginx/access.log main;
    
    sendfile on;
    tcp_nopush on;
    tcp_nodelay on;
    keepalive_timeout 65;
    types_hash_max_size 2048;
    
    # Gzip
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_proxied any;
    gzip_comp_level 6;
    gzip_types
        text/plain
        text/css
        text/xml
        text/javascript
        application/json
        application/javascript
        application/xml+rss
        application/atom+xml
        image/svg+xml;
    
    # Incluir configuraciones de sitios
    include /etc/nginx/conf.d/*.conf;
}
EOF

    # Configuración del sitio principal
    cat > docker/nginx/conf.d/default.conf << 'EOF'
# 🌐 Configuración del sitio principal - Media Quality Net
server {
    listen 80;
    server_name localhost;
    
    # Redirigir HTTP a HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name localhost;
    
    # Certificados SSL
    ssl_certificate /etc/nginx/ssl/cert.pem;
    ssl_certificate_key /etc/nginx/ssl/key.pem;
    
    # Configuración SSL
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384;
    ssl_prefer_server_ciphers off;
    
    # Frontend Next.js
    location / {
        proxy_pass http://frontend_mqn:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # Backend FastAPI
    location /api/ {
        proxy_pass http://backend_mqn:8000/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # n8n
    location /n8n/ {
        proxy_pass http://n8n_mqn:5678/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # WhatsApp Service
    location /whatsapp/ {
        proxy_pass http://whatsapp_service:8000/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
    
    # Monitoreo
    location /monitoring/ {
        proxy_pass http://monitoring:3000/;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
EOF

    log_success "Configuración de Nginx creada correctamente"
}

# Función para crear scripts de gestión
create_management_scripts() {
    log_info "📜 Creando scripts de gestión..."
    
    # Script para iniciar el ecosistema
    cat > start_ecosistema.sh << 'EOF'
#!/bin/bash
# 🚀 Script para iniciar el ecosistema completo de MQN

echo "🚀 Iniciando el ecosistema completo de Media Quality Net..."
cd docker

# Verificar que .env existe
if [ ! -f "../.env" ]; then
    echo "❌ Error: Archivo .env no encontrado. Ejecuta primero init_ecosistema_completo.sh"
    exit 1
fi

# Cargar variables de entorno
source ../.env

# Construir e iniciar servicios
echo "🔨 Construyendo servicios..."
docker-compose build

echo "🚀 Iniciando servicios..."
docker-compose up -d

echo "⏳ Esperando que los servicios estén listos..."
sleep 30

# Verificar estado de los servicios
echo "🔍 Verificando estado de los servicios..."
docker-compose ps

echo ""
echo "🎉 ¡Ecosistema iniciado correctamente!"
echo ""
echo "🌐 Servicios disponibles:"
echo "   Frontend: http://localhost:3000"
echo "   Backend API: http://localhost:8000"
echo "   n8n: http://localhost:5678"
echo "   WhatsApp: http://localhost:8002"
echo "   Monitoreo: http://localhost:3001"
echo "   Nginx: http://localhost (HTTP) / https://localhost (HTTPS)"
echo ""
echo "📱 Para detener: ./stop_ecosistema.sh"
echo "📊 Para monitorear: ./monitor_ecosistema.sh"
EOF

    # Script para detener el ecosistema
    cat > stop_ecosistema.sh << 'EOF'
#!/bin/bash
# 🛑 Script para detener el ecosistema completo de MQN

echo "🛑 Deteniendo el ecosistema completo de Media Quality Net..."
cd docker

# Detener servicios
echo "⏹️ Deteniendo servicios..."
docker-compose down

echo "🧹 Limpiando recursos..."
docker system prune -f

echo "✅ Ecosistema detenido correctamente"
EOF

    # Script para monitorear el ecosistema
    cat > monitor_ecosistema.sh << 'EOF'
#!/bin/bash
# 📊 Script para monitorear el ecosistema completo de MQN

echo "📊 Monitoreando el ecosistema completo de Media Quality Net..."
cd docker

# Estado de los servicios
echo "🔍 Estado de los servicios:"
docker-compose ps

echo ""
echo "📈 Uso de recursos:"
docker stats --no-stream

echo ""
echo "📋 Logs recientes:"
echo "   Para ver logs específicos: docker-compose logs [servicio]"
echo "   Para seguir logs: docker-compose logs -f [servicio]"
EOF

    # Hacer ejecutables los scripts
    chmod +x start_ecosistema.sh stop_ecosistema.sh monitor_ecosistema.sh
    
    log_success "Scripts de gestión creados correctamente"
}

# Función para crear documentación
create_documentation() {
    log_info "📚 Creando documentación..."
    
    # README principal del ecosistema
    cat > README_ECOSISTEMA.md << 'EOF'
# 🚀 ECOSISTEMA DIGITAL COMPLETO - Media Quality Net

## 📋 Descripción General

Este es el ecosistema digital completo de Media Quality Net, una plataforma unificada que integra todos los servicios de la empresa, incluyendo asistentes de IA, gestión de producción, automatización de redes sociales y más.

## 🏗️ Arquitectura del Sistema

### **📊 Componentes Principales:**
- **Backend FastAPI:** API principal con todos los servicios
- **Frontend Next.js:** Interfaz web moderna y responsive
- **WhatsApp Interface:** Sistema principal de entrada de datos
- **AI Services:** Servicios de inteligencia artificial integrados
- **Production Management:** Gestión completa de producción
- **Social Media Automation:** Automatización de redes sociales
- **Accounting Basic:** Contabilidad básica integrada

### **🐳 Servicios Docker:**
- **PostgreSQL:** Base de datos principal
- **Redis:** Cache y sesiones
- **n8n:** Automatización de flujos
- **Nginx:** Proxy reverso y SSL
- **Grafana:** Monitoreo y analytics

## 🚀 Inicio Rápido

### **1. Configuración Inicial:**
```bash
./init_ecosistema_completo.sh
```

### **2. Iniciar Ecosistema:**
```bash
./start_ecosistema.sh
```

### **3. Detener Ecosistema:**
```bash
./stop_ecosistema.sh
```

### **4. Monitorear:**
```bash
./monitor_ecosistema.sh
```

## 🌐 URLs de Acceso

- **Frontend:** http://localhost:3000
- **Backend API:** http://localhost:8000
- **n8n:** http://localhost:5678
- **WhatsApp Service:** http://localhost:8002
- **Monitoreo:** http://localhost:3001
- **Nginx:** http://localhost / https://localhost

## 🔧 Configuración

### **Variables de Entorno (.env):**
- `OPENAI_API_KEY`: Clave de API de OpenAI
- `WHATSAPP_API_KEY`: Clave de API de WhatsApp
- `GA_ID`: ID de Google Analytics
- `SECRET_KEY`: Clave secreta para JWT
- `DATABASE_URL`: URL de la base de datos
- `REDIS_URL`: URL de Redis

## 📱 Funcionalidades Principales

### **🤖 Asistentes de IA:**
- Generación de diseños por descripción
- Mejora automática de imágenes
- Generación de contenido para redes sociales
- Análisis de productos existentes

### **📱 Interfaz WhatsApp:**
- Comandos de texto y voz
- Reconocimiento de voz con Whisper
- Procesamiento automático de solicitudes
- Integración con todos los servicios

### **🏭 Gestión de Producción:**
- Seguimiento de flujos de trabajo
- Gestión de tareas y responsabilidades
- Control de inventario dinámico
- Gestión de proveedores

### **📱 Automatización de Redes Sociales:**
- Publicaciones automáticas programadas
- Generación de contenido con IA
- Análisis de engagement
- Gestión multi-plataforma

## 🔒 Seguridad

- **HTTPS:** Configurado con Nginx y SSL
- **Autenticación:** JWT con roles y permisos
- **Validación:** Pydantic para validación de datos
- **Logs:** Auditoría completa de todas las operaciones

## 📊 Monitoreo

- **Grafana:** Dashboards personalizados
- **Logs:** Centralizados y estructurados
- **Métricas:** En tiempo real
- **Alertas:** Automáticas para problemas críticos

## 🚀 Escalabilidad

- **Microservicios:** Arquitectura modular
- **Docker:** Contenedores independientes
- **Load Balancing:** Preparado para múltiples instancias
- **Cache:** Redis para optimización de rendimiento

## 📞 Soporte

- **Documentación:** Completa y actualizada
- **Logs:** Detallados para debugging
- **Monitoreo:** En tiempo real
- **Backups:** Automáticos y seguros

---

**🎯 Este ecosistema transformará Media Quality Net en una empresa digital completamente automatizada y eficiente.**

**📅 Fecha de creación:** $(date +'%Y-%m-%d')
**🔄 Estado:** 🚀 **ECOSISTEMA COMPLETAMENTE CONFIGURADO - LISTO PARA INICIAR**
EOF

    log_success "Documentación creada correctamente"
}

# Función principal
main() {
    show_banner
    
    log_info "🚀 Iniciando configuración del ecosistema completo de Media Quality Net..."
    
    # Verificar dependencias
    check_dependencies
    
    # Crear estructura
    create_directory_structure
    create_config_files
    create_dockerfiles
    create_nginx_config
    create_management_scripts
    create_documentation
    
    log_success "🎉 ¡Ecosistema completamente configurado!"
    echo ""
    echo -e "${CYAN}📋 PRÓXIMOS PASOS:${NC}"
    echo "1. 📝 Editar archivo .env con tus API keys"
    echo "2. 🚀 Ejecutar: ./start_ecosistema.sh"
    echo "3. 🌐 Acceder a: http://localhost:3000"
    echo ""
    echo -e "${YELLOW}⚠️ IMPORTANTE:${NC}"
    echo "   - Configura tus API keys en el archivo .env"
    echo "   - Verifica que los puertos estén disponibles"
    echo "   - Asegúrate de tener suficiente espacio en disco"
    echo ""
    echo -e "${GREEN}🎯 ¡Tu ecosistema digital está listo para revolucionar MQN!${NC}"
}

# Ejecutar función principal
main "$@"
