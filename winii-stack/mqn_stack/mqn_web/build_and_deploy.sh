#!/bin/bash

# 🚀 Script de Construcción y Despliegue - Media Quality Net
# Este script construye y despliega el frontend de MQN

set -e

echo "🚀 Iniciando construcción y despliegue de Media Quality Net..."

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para imprimir mensajes con colores
print_message() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Verificar que estamos en el directorio correcto
if [ ! -f "docker-compose.yml" ]; then
    print_error "Este script debe ejecutarse desde el directorio docker/"
    exit 1
fi

# Verificar que Docker esté ejecutándose
if ! docker info > /dev/null 2>&1; then
    print_error "Docker no está ejecutándose. Por favor, inicia Docker y vuelve a intentar."
    exit 1
fi

# Verificar que el directorio frontend exista
if [ ! -d "../frontend" ]; then
    print_error "El directorio frontend no existe. Por favor, crea la estructura del proyecto primero."
    exit 1
fi

print_step "1. Preparando entorno de construcción..."

# Navegar al directorio frontend
cd ../frontend

# Verificar que package.json exista
if [ ! -f "package.json" ]; then
    print_error "package.json no encontrado en el directorio frontend"
    exit 1
fi

print_step "2. Instalando dependencias..."

# Instalar dependencias
if command -v yarn &> /dev/null; then
    print_message "Usando Yarn para instalar dependencias..."
    yarn install --frozen-lockfile
else
    print_message "Usando npm para instalar dependencias..."
    npm ci
fi

print_step "3. Verificando configuración..."

# Verificar que las dependencias estén instaladas
if [ ! -d "node_modules" ]; then
    print_error "Las dependencias no se instalaron correctamente"
    exit 1
fi

print_step "4. Construyendo aplicación..."

# Construir la aplicación
if command -v yarn &> /dev/null; then
    yarn build
else
    npm run build
fi

# Verificar que la construcción fue exitosa
if [ ! -d ".next" ]; then
    print_error "La construcción falló. Verifica los errores y vuelve a intentar."
    exit 1
fi

print_message "✅ Construcción completada exitosamente"

print_step "5. Regresando al directorio docker..."

# Regresar al directorio docker
cd ../docker

print_step "6. Construyendo y desplegando servicios..."

# Construir y desplegar todos los servicios
print_message "Construyendo imagen del frontend..."
docker-compose build frontend_mqn

print_message "Iniciando todos los servicios..."
docker-compose up -d

print_step "7. Verificando estado de los servicios..."

# Esperar un momento para que los servicios se inicien
sleep 10

# Verificar estado de los servicios
print_message "Estado de los servicios:"
docker-compose ps

print_step "8. Verificando salud de los servicios..."

# Verificar salud de los servicios principales
services=("frontend_mqn" "n8n_mqn" "ai_analysis_service" "whatsapp_evolution")

for service in "${services[@]}"; do
    if docker-compose ps | grep -q "$service.*Up"; then
        print_message "✅ $service está ejecutándose"
    else
        print_warning "⚠️  $service no está ejecutándose correctamente"
    fi
done

print_step "9. Información de acceso..."

echo ""
echo "🎉 ¡Despliegue completado exitosamente!"
echo ""
echo "📱 Servicios disponibles:"
echo "   🌐 Página web pública: http://localhost:3000"
echo "   🤖 Panel de administración: http://localhost:3000/admin"
echo "   ⚡ n8n (automatización): http://localhost:5678"
echo "   🧠 Servicio de IA: http://localhost:8001"
echo "   📱 WhatsApp Evolution: http://localhost:8080"
echo "   📊 Monitoreo (Grafana): http://localhost:3001"
echo ""
echo "🔑 Credenciales de acceso:"
echo "   n8n: admin / MQNn8n2024!"
echo "   Grafana: admin / mqn_monitoring_2024"
echo ""
echo "📁 Archivos de configuración:"
echo "   - Docker Compose: docker-compose.yml"
echo "   - Base de datos: database/init/"
echo "   - Frontend: ../frontend/"
echo "   - Servicios: ai_service/, whatsapp/, n8n/"
echo ""
echo "🚀 Para detener los servicios: docker-compose down"
echo "🔄 Para reiniciar: docker-compose restart"
echo "📊 Para ver logs: docker-compose logs [servicio]"
echo ""

print_step "10. Verificando conectividad..."

# Verificar que el frontend esté respondiendo
if curl -f http://localhost:3000 > /dev/null 2>&1; then
    print_message "✅ Frontend responde correctamente en http://localhost:3000"
else
    print_warning "⚠️  Frontend no responde. Verifica los logs con: docker-compose logs frontend_mqn"
fi

# Verificar que n8n esté respondiendo
if curl -f http://localhost:5678 > /dev/null 2>&1; then
    print_message "✅ n8n responde correctamente en http://localhost:5678"
else
    print_warning "⚠️  n8n no responde. Verifica los logs con: docker-compose logs n8n_mqn"
fi

echo ""
print_message "🎯 ¡Tu ecosistema Media Quality Net está listo para usar!"
print_message "Visita http://localhost:3000 para ver tu página web pública"
print_message "Visita http://localhost:3000/admin para acceder al panel de administración"
echo ""

# Mostrar uso de recursos
print_step "11. Uso de recursos del sistema:"
docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"

echo ""
print_message "✅ Script de construcción y despliegue completado exitosamente!"
