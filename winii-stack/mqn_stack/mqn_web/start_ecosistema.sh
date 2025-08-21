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
