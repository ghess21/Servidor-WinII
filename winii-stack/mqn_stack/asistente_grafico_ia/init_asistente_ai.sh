#!/bin/bash
# ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
# ┃    INICIALIZACIÓN ASISTENTE GRÁFICO   ┃
# ┃    Media Quality Net - IA Designer    ┃
# ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

WORKDIR="$(pwd)"
LOG_FILE="$WORKDIR/logs/asistente_ai.log"

# Crear directorios necesarios
mkdir -p "$(dirname "$LOG_FILE")"
mkdir -p uploads generated validation_reports templates models database

# Función de logging
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log_message "🚀 Iniciando Asistente Gráfico de IA para MQN"

# 1. Verificar dependencias del sistema
log_message "🔍 Verificando dependencias del sistema..."

# Verificar Docker
if ! command -v docker >/dev/null 2>&1; then
    log_message "❌ Error: Docker no está instalado"
    echo "💡 Instala Docker: https://docs.docker.com/get-docker/"
    exit 1
fi

# Verificar Docker Compose
if ! command -v docker-compose >/dev/null 2>&1; then
    log_message "❌ Error: Docker Compose no está instalado"
    echo "💡 Instala Docker Compose: https://docs.docker.com/compose/install/"
    exit 1
fi

log_message "✅ Docker y Docker Compose verificados"

# 2. Crear archivo de variables de entorno
log_message "⚙️ Creando archivo de variables de entorno..."
cat > .env << EOF
# Configuración del Asistente Gráfico de IA
OPENAI_API_KEY=your_openai_api_key_here
STABLE_DIFFUSION_URL=http://localhost:7860
STABILITY_API_KEY=your_stability_api_key_here

# Configuración de la base de datos
POSTGRES_DB=ai_designs_db
POSTGRES_USER=mqn_user
POSTGRES_PASSWORD=mqn_password

# Configuración de Redis
REDIS_PASSWORD=your_redis_password_here

# Configuración de seguridad
JWT_SECRET_KEY=your_jwt_secret_key_here
ENCRYPTION_KEY=your_encryption_key_here

# Configuración de WhatsApp
WHATSAPP_API_KEY=your_whatsapp_api_key_here
WHATSAPP_PHONE_NUMBER=9671262441

# Configuración de validación
AUTO_APPROVAL=false
VALIDATION_LEVEL=strict
MAX_FILE_SIZE=50MB
EOF

log_message "✅ Archivo .env creado"

# 3. Crear estructura de directorios
log_message "📁 Creando estructura de directorios..."

# Directorios principales
mkdir -p {frontend,backend,ai_engine,eps_generator,validation_system,client_interface,design_templates,quality_checker,integration}

# Directorios de datos
mkdir -p {uploads,generated,validation_reports,templates,models,database,logs,backups}

# Directorios de frontend
mkdir -p frontend/{src,public,src/{components,pages,services,utils,assets,styles}}

# Directorios de backend
mkdir -p backend/{app,tests,alembic,app/{api,core,models,schemas,services,utils}}

# Directorios de IA
mkdir -p ai_engine/{models,prompts,training,outputs}

# Directorios de EPS
mkdir -p eps_generator/{converters,validators,optimizers}

# Directorios de validación
mkdir -p validation_system/{checkers,reports,approvals}

# Directorios de plantillas
mkdir -p design_templates/{playeras,tazas,posters,tarjetas,logos}

# Directorios de integración
mkdir -p integration/{whatsapp,email,telegram,webhook}

log_message "✅ Estructura de directorios creada"

# 4. Crear archivos de configuración base
log_message "⚙️ Creando archivos de configuración base..."

# Configuración de Nginx
mkdir -p nginx/ssl
cat > nginx/nginx.conf << 'EOF'
events {
    worker_connections 1024;
}

http {
    upstream frontend {
        server frontend_ai:3000;
    }
    
    upstream backend {
        server backend_ai:8000;
    }
    
    server {
        listen 80;
        server_name localhost;
        
        location / {
            proxy_pass http://frontend;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
        }
        
        location /api {
            proxy_pass http://backend;
            proxy_set_header Host \$host;
            proxy_set_header X-Real-IP \$remote_addr;
        }
        
        location /generated {
            alias /var/www/generated;
            expires 1h;
        }
    }
}
EOF

# Script de inicialización de base de datos
cat > database/init.sql << 'EOF'
-- Crear base de datos para diseños de IA
CREATE DATABASE IF NOT EXISTS ai_designs_db;

-- Tabla de usuarios/clientes
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    company VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de diseños
CREATE TABLE IF NOT EXISTS designs (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    design_type VARCHAR(100) NOT NULL,
    status VARCHAR(50) DEFAULT 'pending',
    ai_generated BOOLEAN DEFAULT true,
    eps_file_path VARCHAR(500),
    preview_image_path VARCHAR(500),
    validation_status VARCHAR(50) DEFAULT 'pending',
    technical_notes TEXT,
    price DECIMAL(10,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de validaciones técnicas
CREATE TABLE IF NOT EXISTS validations (
    id SERIAL PRIMARY KEY,
    design_id INTEGER REFERENCES designs(id),
    validator_id INTEGER REFERENCES users(id),
    status VARCHAR(50) NOT NULL,
    notes TEXT,
    quality_score INTEGER CHECK (quality_score >= 1 AND quality_score <= 10),
    approved_at TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de plantillas de diseño
CREATE TABLE IF NOT EXISTS design_templates (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    category VARCHAR(100) NOT NULL,
    description TEXT,
    template_file_path VARCHAR(500),
    preview_image_path VARCHAR(500),
    tags TEXT[],
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de cotizaciones
CREATE TABLE IF NOT EXISTS quotes (
    id SERIAL PRIMARY KEY,
    design_id INTEGER REFERENCES designs(id),
    user_id INTEGER REFERENCES users(id),
    base_price DECIMAL(10,2) NOT NULL,
    quantity INTEGER NOT NULL,
    technique VARCHAR(100) NOT NULL,
    product_type VARCHAR(100) NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    status VARCHAR(50) DEFAULT 'pending',
    valid_until DATE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Índices para optimización
CREATE INDEX idx_designs_user_id ON designs(user_id);
CREATE INDEX idx_designs_status ON designs(status);
CREATE INDEX idx_validations_design_id ON validations(design_id);
CREATE INDEX idx_quotes_user_id ON quotes(user_id);
EOF

log_message "✅ Archivos de configuración base creados"

# 5. Crear Dockerfiles base
log_message "🐳 Creando Dockerfiles base..."

# Dockerfile para el backend
cat > backend/Dockerfile << 'EOF'
FROM python:3.11-slim

WORKDIR /app

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    gcc \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Copiar requirements
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copiar código
COPY . .

# Exponer puerto
EXPOSE 8000

# Comando de inicio
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000", "--reload"]
EOF

# Dockerfile para el frontend
cat > frontend/Dockerfile << 'EOF'
FROM node:18-alpine

WORKDIR /app

# Copiar package.json
COPY package*.json ./

# Instalar dependencias
RUN npm install

# Copiar código
COPY . .

# Exponer puerto
EXPOSE 3000

# Comando de inicio
CMD ["npm", "start"]
EOF

# Dockerfile para el generador de EPS
cat > eps_generator/Dockerfile << 'EOF'
FROM ubuntu:22.04

WORKDIR /app

# Instalar dependencias
RUN apt-get update && apt-get install -y \
    inkscape \
    imagemagick \
    python3 \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# Copiar requirements
COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

# Copiar código
COPY . .

# Comando de inicio
CMD ["python3", "main.py"]
EOF

log_message "✅ Dockerfiles base creados"

# 6. Crear archivos de requirements
log_message "📦 Creando archivos de requirements..."

# Requirements para el backend
cat > backend/requirements.txt << 'EOF'
fastapi==0.104.1
uvicorn[standard]==0.24.0
sqlalchemy==2.0.23
alembic==1.12.1
psycopg2-binary==2.9.9
redis==5.0.1
python-multipart==0.0.6
python-jose[cryptography]==3.3.0
passlib[bcrypt]==1.7.4
python-dotenv==1.0.0
httpx==0.25.2
pillow==10.1.0
opencv-python==4.8.1.78
numpy==1.24.3
pandas==2.1.3
openai==1.3.7
stability-sdk==0.8.4
celery==5.3.4
flower==2.0.1
pytest==7.4.3
pytest-asyncio==0.21.1
EOF

# Requirements para el frontend
cat > frontend/package.json << 'EOF'
{
  "name": "mqn-ai-designer-frontend",
  "version": "1.0.0",
  "private": true,
  "dependencies": {
    "@testing-library/jest-dom": "^5.16.4",
    "@testing-library/react": "^13.3.0",
    "@testing-library/user-event": "^13.5.0",
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-scripts": "5.0.1",
    "react-router-dom": "^6.8.1",
    "axios": "^1.3.4",
    "socket.io-client": "^4.6.1",
    "fabric": "^5.2.1",
    "react-dropzone": "^14.2.3",
    "react-color": "^2.19.3",
    "react-select": "^5.7.0",
    "styled-components": "^5.3.9",
    "framer-motion": "^10.12.4",
    "react-query": "^3.39.3",
    "zustand": "^4.3.6",
    "web-vitals": "^2.1.4"
  },
  "scripts": {
    "start": "react-scripts start",
    "build": "react-scripts build",
    "test": "react-scripts test",
    "eject": "react-scripts eject"
  },
  "eslintConfig": {
    "extends": [
      "react-app",
      "react-app/jest"
    ]
  },
  "browserslist": {
    "production": [
      ">0.2%",
      "not dead",
      "not op_mini all"
    ],
    "development": [
      "last 1 chrome version",
      "last 1 firefox version",
      "last 1 safari version"
    ]
  }
}
EOF

# Requirements para el generador de EPS
cat > eps_generator/requirements.txt << 'EOF'
pillow==10.1.0
svgwrite==1.4.3
cairosvg==2.7.1
reportlab==4.0.4
pypdf2==3.0.1
svgpathtools==1.6.1
numpy==1.24.3
opencv-python==4.8.1.78
EOF

log_message "✅ Archivos de requirements creados"

# 7. Crear script de inicio rápido
log_message "🚀 Creando script de inicio rápido..."
cat > start_asistente_ai.sh << 'EOF'
#!/bin/bash
# Script de inicio rápido para el Asistente Gráfico de IA

echo "🎨 Iniciando Asistente Gráfico de IA para MQN..."

# Verificar que estamos en el directorio correcto
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ Error: No se encontró docker-compose.yml"
    echo "💡 Asegúrate de estar en el directorio asistente_grafico_ia"
    exit 1
fi

# Verificar archivo .env
if [ ! -f ".env" ]; then
    echo "⚠️ Advertencia: No se encontró archivo .env"
    echo "💡 Ejecuta primero: ./init_asistente_ai.sh"
    exit 1
fi

# Construir y levantar servicios
echo "🔨 Construyendo servicios..."
docker-compose build

echo "🚀 Levantando servicios..."
docker-compose up -d

# Esperar a que los servicios estén listos
echo "⏳ Esperando a que los servicios estén listos..."
sleep 30

# Verificar estado de los servicios
echo "📊 Estado de los servicios:"
docker-compose ps

echo ""
echo "🎉 ¡Asistente Gráfico de IA iniciado exitosamente!"
echo ""
echo "🌐 URLs de acceso:"
echo "  • Frontend: http://localhost:3000"
echo "  • Backend API: http://localhost:8000"
echo "  • Documentación API: http://localhost:8000/docs"
echo "  • Nginx: http://localhost:80"
echo ""
echo "🔧 Comandos útiles:"
echo "  • Ver logs: docker-compose logs -f"
echo "  • Parar servicios: docker-compose down"
echo "  • Reiniciar: docker-compose restart"
echo "  • Ver estado: docker-compose ps"
EOF

chmod +x start_asistente_ai.sh

# 8. Crear script de parada
log_message "🛑 Creando script de parada..."
cat > stop_asistente_ai.sh << 'EOF'
#!/bin/bash
# Script de parada para el Asistente Gráfico de IA

echo "🛑 Deteniendo Asistente Gráfico de IA..."

# Verificar que estamos en el directorio correcto
if [ ! -f "docker-compose.yml" ]; then
    echo "❌ Error: No se encontró docker-compose.yml"
    exit 1
fi

# Parar servicios
echo "⏹️ Parando servicios..."
docker-compose down

echo "🧹 Limpiando contenedores..."
docker-compose down --volumes --remove-orphans

echo "✅ Servicios detenidos y limpiados"
EOF

chmod +x stop_asistente_ai.sh

# 9. Crear script de monitoreo
log_message "📊 Creando script de monitoreo..."
cat > monitor_asistente_ai.sh << 'EOF'
#!/bin/bash
# Script de monitoreo para el Asistente Gráfico de IA

echo "📊 Monitoreo del Asistente Gráfico de IA"
echo "========================================"

# Verificar estado de los servicios
echo "🔍 Estado de los servicios:"
docker-compose ps

echo ""
echo "💾 Uso de recursos:"
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"

echo ""
echo "📁 Espacio en disco:"
du -sh uploads generated validation_reports templates models database logs backups 2>/dev/null || echo "Algunos directorios no existen"

echo ""
echo "📋 Logs recientes:"
echo "Backend:"
docker-compose logs --tail=10 backend_ai

echo ""
echo "Frontend:"
docker-compose logs --tail=10 frontend_ai

echo ""
echo "EPS Generator:"
docker-compose logs --tail=10 eps_generator
EOF

chmod +x monitor_asistente_ai.sh

# 10. Crear README de inicio rápido
log_message "📚 Creando README de inicio rápido..."
cat > QUICKSTART.md << 'EOF'
# 🚀 INICIO RÁPIDO - Asistente Gráfico de IA

## ⚡ Inicio en 3 pasos:

### 1. Configuración inicial (solo una vez):
```bash
./init_asistente_ai.sh
```

### 2. Editar variables de entorno:
```bash
nano .env
# Configura tus API keys y contraseñas
```

### 3. Iniciar servicios:
```bash
./start_asistente_ai.sh
```

## 🌐 Acceso:
- **Frontend:** http://localhost:3000
- **API:** http://localhost:8000
- **Docs:** http://localhost:8000/docs

## 🔧 Comandos útiles:
- **Monitoreo:** `./monitor_asistente_ai.sh`
- **Parar:** `./stop_asistente_ai.sh`
- **Logs:** `docker-compose logs -f`

## 📁 Estructura del proyecto:
```
asistente_grafico_ia/
├── frontend/          # Interfaz web React
├── backend/           # API FastAPI
├── ai_engine/         # Motor de IA
├── eps_generator/     # Generador de EPS
├── validation_system/ # Sistema de validación
└── docker-compose.yml # Configuración Docker
```

## 🆘 En caso de problemas:
1. Verificar logs: `docker-compose logs -f`
2. Reiniciar servicios: `docker-compose restart`
3. Reconstruir: `docker-compose build --no-cache`
4. Limpiar todo: `docker-compose down --volumes --remove-orphans`
EOF

log_message "✅ Scripts de gestión creados"

# 11. Crear directorio de plantillas base
log_message "🎨 Creando plantillas de diseño base..."

# Crear algunas plantillas básicas
mkdir -p design_templates/playeras/{logos,artisticos,texto,ilustraciones}
mkdir -p design_templates/tazas/{circulares,patrones,texto_curvo}
mkdir -p design_templates/posters/{alta_resolucion,tipografia,graficos}
mkdir -p design_templates/tarjetas/{corporativas,personales,eventos}

# Crear archivo de metadatos de plantillas
cat > design_templates/templates_metadata.json << 'EOF'
{
  "playeras": {
    "logos": [
      {
        "id": "logo_corporativo_001",
        "name": "Logo Corporativo Básico",
        "description": "Plantilla para logos empresariales simples",
        "category": "corporativo",
        "tags": ["logo", "empresa", "profesional"],
        "file_path": "playeras/logos/logo_corporativo_001.svg",
        "preview_path": "playeras/logos/logo_corporativo_001_preview.png",
        "price": 50.00
      }
    ],
    "artisticos": [
      {
        "id": "dragon_azul_001",
        "name": "Dragón Azul Estilizado",
        "description": "Diseño artístico de dragón en estilo japonés",
        "category": "artistico",
        "tags": ["dragon", "japones", "azul", "arte"],
        "file_path": "playeras/artisticos/dragon_azul_001.svg",
        "preview_path": "playeras/artisticos/dragon_azul_001_preview.png",
        "price": 150.00
      }
    ]
  },
  "tazas": {
    "circulares": [
      {
        "id": "taza_circular_001",
        "name": "Diseño Circular Básico",
        "description": "Plantilla circular para tazas y objetos redondos",
        "category": "circular",
        "tags": ["taza", "circular", "basico"],
        "file_path": "tazas/circulares/taza_circular_001.svg",
        "preview_path": "tazas/circulares/taza_circular_001_preview.png",
        "price": 75.00
      }
    ]
  }
}
EOF

log_message "✅ Plantillas de diseño base creadas"

# 12. Resumen final
log_message "🎉 Inicialización del Asistente Gráfico de IA completada"
echo ""
echo "🎨 ASISTENTE GRÁFICO DE IA - INICIALIZACIÓN COMPLETADA"
echo "========================================================"
echo ""
echo "✅ Estructura del proyecto creada"
echo "✅ Archivos de configuración generados"
echo "✅ Dockerfiles y requirements creados"
echo "✅ Scripts de gestión preparados"
echo "✅ Plantillas de diseño base configuradas"
echo ""
echo "🚀 PRÓXIMOS PASOS:"
echo "1. Editar archivo .env con tus API keys"
echo "2. Ejecutar: ./start_asistente_ai.sh"
echo "3. Acceder a: http://localhost:3000"
echo ""
echo "📚 Documentación:"
echo "• README.md - Documentación completa"
echo "• QUICKSTART.md - Guía de inicio rápido"
echo "• docs/ - Documentación técnica"
echo ""
echo "🔧 Comandos disponibles:"
echo "• ./start_asistente_ai.sh - Iniciar servicios"
echo "• ./stop_asistente_ai.sh - Parar servicios"
echo "• ./monitor_asistente_ai.sh - Monitorear estado"
echo ""
echo "🎯 ¡Tu Asistente Gráfico de IA está listo para revolucionar MQN!"
