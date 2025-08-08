#!/bin/bash
# Script de recuperación rápida para MQN

echo "🚀 Iniciando recuperación rápida..."

# Verificar si hay backups disponibles
LATEST_BACKUP=$(find backups -name "*.json" -type f | sort | tail -1)

if [ -z "$LATEST_BACKUP" ]; then
    echo "❌ No se encontraron backups"
    exit 1
fi

echo "📁 Usando backup: $LATEST_BACKUP"

# Reiniciar servicios
echo "🔄 Reiniciando servicios..."
docker-compose restart

# Esperar a que los servicios estén listos
echo "⏳ Esperando que los servicios estén listos..."
sleep 30

# Restaurar desde el backup
echo "🔄 Restaurando desde backup..."
./scripts/restaurar_backup.sh "$LATEST_BACKUP"

echo "✅ Recuperación rápida completada"
