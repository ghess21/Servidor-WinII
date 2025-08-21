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
