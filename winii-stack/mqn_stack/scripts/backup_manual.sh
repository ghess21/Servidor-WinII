#!/bin/bash
# Script de backup manual para MQN

echo "🔄 Iniciando backup manual..."

# Crear timestamp
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="backups/mqn_backup_manual_${TIMESTAMP}.json"

# Exportar workflows
echo "📁 Exportando workflows..."
curl -s -X GET "http://localhost:5679/api/v1/workflows" \
  -H "X-N8N-API-KEY: mqn_api_key_2024" > "${BACKUP_FILE}"

# Exportar base de datos
echo "📊 Exportando base de datos..."
docker-compose exec -T postgres pg_dump -U mqn_user mqn_db > "backups/db_backup_${TIMESTAMP}.sql"

# Crear backup de knowledge base
echo "📚 Exportando base de conocimiento..."
tar -czf "backups/knowledge_base_${TIMESTAMP}.tar.gz" knowledge_base/

echo "✅ Backup manual completado: ${BACKUP_FILE}"
echo "📁 Archivos creados:"
echo "  • ${BACKUP_FILE}"
echo "  • backups/db_backup_${TIMESTAMP}.sql"
echo "  • backups/knowledge_base_${TIMESTAMP}.tar.gz"
