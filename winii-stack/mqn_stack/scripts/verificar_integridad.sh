#!/bin/bash
# Script para verificar integridad del sistema MQN

echo "🔍 Verificando integridad del sistema MQN..."

# Verificar servicios
echo "🔧 Verificando servicios..."
if curl -s http://localhost:5679 > /dev/null; then
    echo "✅ n8n funcionando"
else
    echo "❌ n8n no está funcionando"
fi

if docker-compose exec postgres pg_isready -U mqn_user > /dev/null 2>&1; then
    echo "✅ PostgreSQL funcionando"
else
    echo "❌ PostgreSQL no está funcionando"
fi

# Verificar workflows
echo "📁 Verificando workflows..."
WORKFLOWS_COUNT=$(curl -s -X GET "http://localhost:5679/api/v1/workflows" \
  -H "X-N8N-API-KEY: mqn_api_key_2024" | jq '.data | length' 2>/dev/null || echo "0")
echo "📊 Workflows activos: $WORKFLOWS_COUNT"

# Verificar base de datos
echo "📊 Verificando base de datos..."
CONVERSACIONES_COUNT=$(docker-compose exec -T postgres psql -U mqn_user -d mqn_db -t -c "SELECT COUNT(*) FROM conversaciones;" 2>/dev/null | tr -d ' ')
echo "💬 Conversaciones: $CONVERSACIONES_COUNT"

PRODUCTOS_COUNT=$(docker-compose exec -T postgres psql -U mqn_user -d mqn_db -t -c "SELECT COUNT(*) FROM productos;" 2>/dev/null | tr -d ' ')
echo "📦 Productos: $PRODUCTOS_COUNT"

# Verificar knowledge base
echo "📚 Verificando base de conocimiento..."
if [ -d "knowledge_base" ]; then
    KB_FILES=$(find knowledge_base -type f | wc -l)
    echo "📁 Archivos de conocimiento: $KB_FILES"
else
    echo "❌ Base de conocimiento no encontrada"
fi

# Verificar backups
echo "💾 Verificando backups..."
if [ -d "backups" ]; then
    BACKUP_COUNT=$(find backups -name "*.json" | wc -l)
    echo "📁 Backups disponibles: $BACKUP_COUNT"
else
    echo "❌ Directorio de backups no encontrado"
fi

echo ""
echo "🎯 Estado del sistema:"
if [ "$WORKFLOWS_COUNT" -gt 0 ] && [ "$CONVERSACIONES_COUNT" -ge 0 ]; then
    echo "✅ Sistema funcionando correctamente"
else
    echo "⚠️ Sistema con problemas detectados"
fi
