#!/bin/bash
# Script de monitoreo del sistema MQN

echo "📊 Monitoreando sistema MQN..."

# Verificar uso de recursos
CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | cut -d'%' -f1)
MEMORY_USAGE=$(free | grep Mem | awk '{printf("%.0f", $3/$2 * 100.0)}')
DISK_USAGE=$(df / | tail -1 | awk '{print $5}' | cut -d'%' -f1)

echo "💻 CPU: ${CPU_USAGE}%"
echo "🧠 Memoria: ${MEMORY_USAGE}%"
echo "💾 Disco: ${DISK_USAGE}%"

# Verificar servicios críticos
SERVICES=("n8n" "postgres" "redis")
for service in "${SERVICES[@]}"; do
    if docker-compose ps "$service" | grep -q "Up"; then
        echo "✅ $service funcionando"
    else
        echo "❌ $service no está funcionando"
        # Enviar alerta por WhatsApp
        curl -X POST "http://localhost:8080/instance/connect" \
            -H "apikey: mqn_evolution_key_2024" \
            -d "number=9671262441&text=🚨 Alerta: $service no está funcionando"
    fi
done

# Verificar backups recientes
LATEST_BACKUP=$(find backups -name "*.json" -type f -mtime -1 | wc -l)
if [ "$LATEST_BACKUP" -eq 0 ]; then
    echo "⚠️ No hay backups recientes"
    # Enviar alerta
    curl -X POST "http://localhost:8080/instance/connect" \
        -H "apikey: mqn_evolution_key_2024" \
        -d "number=9671262441&text=⚠️ Alerta: No hay backups recientes"
else
    echo "✅ Backups recientes encontrados"
fi

echo "✅ Monitoreo completado"
