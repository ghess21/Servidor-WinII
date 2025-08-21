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
