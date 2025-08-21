#!/bin/bash
# ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
# ┃    BACKUP DIARIO AUTOMÁTICO SMB       ┃
# ┃    WinII Stack - Backup Server        ┃
# ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

WORKDIR="$(pwd)"
LOG_FILE="$WORKDIR/logs/backup_smb.log"
BACKUP_DIR="$WORKDIR/backups"
SMB_MOUNT="/mnt/backup_server"
SMB_PATH="//192.168.1.170/BackupServer/Respado Win Stack"

# Configuración SMB
SMB_USER="ghess21"
SMB_PASS="Cadena"

# Crear directorios necesarios
mkdir -p "$BACKUP_DIR"
mkdir -p "$(dirname "$LOG_FILE")"
mkdir -p "$SMB_MOUNT"

# Función de logging
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Función de limpieza
cleanup() {
    log_message "🧹 Limpiando montaje SMB..."
    umount "$SMB_MOUNT" 2>/dev/null || true
    rmdir "$SMB_MOUNT" 2>/dev/null || true
}

# Capturar señales para limpieza
trap cleanup EXIT INT TERM

log_message "🚀 Iniciando backup diario automático a SMB"

# 1. Montar servidor SMB
log_message "📁 Montando servidor SMB: $SMB_PATH"
if mount -t cifs "$SMB_PATH" "$SMB_MOUNT" -o "username=$SMB_USER,password=$SMB_PASS,vers=3.0,uid=$(id -u),gid=$(id -g)"; then
    log_message "✅ Servidor SMB montado exitosamente"
else
    log_message "❌ Error montando servidor SMB"
    exit 1
fi

# 2. Crear timestamp para el backup
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="winii_stack_backup_${TIMESTAMP}"
BACKUP_FILE="$BACKUP_DIR/${BACKUP_NAME}.tar.gz"

log_message "📦 Creando backup: $BACKUP_NAME"

# 3. Backup de contenedores Docker
log_message "🐳 Exportando estado de contenedores..."
docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" > "$BACKUP_DIR/containers_status.txt"

# 4. Backup de volúmenes Docker
log_message "💾 Exportando volúmenes Docker..."
docker volume ls --format "{{.Name}}" | while read volume; do
    if [ ! -z "$volume" ]; then
        docker run --rm -v "$volume:/data" -v "$BACKUP_DIR:/backup" alpine tar czf "/backup/volume_${volume}_${TIMESTAMP}.tar.gz" -C /data .
        log_message "  ✅ Volumen $volume exportado"
    fi
done

# 5. Backup de archivos de configuración
log_message "⚙️ Exportando configuración..."
tar -czf "$BACKUP_FILE" \
    --exclude="*.log" \
    --exclude="backups/*" \
    --exclude="node_modules/*" \
    --exclude=".git/*" \
    .

# 6. Backup de docker-compose.yml (si existe)
if [ -f "docker-compose.yml" ]; then
    log_message "📋 Creando backup de docker-compose.yml..."
    cp "docker-compose.yml" "docker-compose.yml.bak"
    log_message "✅ Backup de docker-compose.yml creado"
fi

# 7. Backup de n8n (workflows, credenciales, ejecuciones)
log_message "🤖 Exportando datos de n8n..."
if command -v curl >/dev/null 2>&1; then
    # Intentar puerto 5678 (actual) y 5679 (documentado)
    for port in 5678 5679; do
        if curl -s "http://localhost:$port" >/dev/null 2>&1; then
            log_message "🌐 n8n detectado en puerto $port"
            
            # Exportar workflows
            curl -s -X GET "http://localhost:$port/api/v1/workflows" \
                -H "X-N8N-API-KEY: mqn_api_key_2024" > "$BACKUP_DIR/n8n_workflows_${TIMESTAMP}.json" 2>/dev/null || \
                curl -s -X GET "http://localhost:$port/api/v1/workflows" > "$BACKUP_DIR/n8n_workflows_${TIMESTAMP}.json"
            
            # Exportar credenciales
            curl -s -X GET "http://localhost:$port/api/v1/credentials" \
                -H "X-N8N-API-KEY: mqn_api_key_2024" > "$BACKUP_DIR/n8n_credentials_${TIMESTAMP}.json" 2>/dev/null || \
                curl -s -X GET "http://localhost:$port/api/v1/credentials" > "$BACKUP_DIR/n8n_credentials_${TIMESTAMP}.json"
            
            # Exportar ejecuciones
            curl -s -X GET "http://localhost:$port/api/v1/executions" \
                -H "X-N8N-API-KEY: mqn_api_key_2024" > "$BACKUP_DIR/n8n_executions_${TIMESTAMP}.json" 2>/dev/null || \
                curl -s -X GET "http://localhost:$port/api/v1/executions" > "$BACKUP_DIR/n8n_executions_${TIMESTAMP}.json"
            
            log_message "✅ Datos de n8n exportados desde puerto $port"
            break
        fi
    done
else
    log_message "⚠️ curl no disponible, saltando exportación de n8n"
fi

# 8. Backup de base de datos PostgreSQL (si está activo)
log_message "🗄️ Verificando base de datos PostgreSQL..."
if docker ps | grep -q "postgres"; then
    log_message "📊 Exportando base de datos PostgreSQL..."
    docker exec $(docker ps -q --filter "name=postgres") pg_dumpall -U postgres > "$BACKUP_DIR/postgres_full_${TIMESTAMP}.sql" 2>/dev/null || \
    docker exec $(docker ps -q --filter "name=postgres") pg_dump -U postgres postgres > "$BACKUP_DIR/postgres_${TIMESTAMP}.sql" 2>/dev/null || \
    log_message "⚠️ No se pudo exportar base de datos PostgreSQL"
else
    log_message "ℹ️ PostgreSQL no está activo, saltando backup de BD"
fi

# 9. Backup de knowledge base MQN (si existe)
if [ -d "mqn_stack/knowledge_base" ]; then
    log_message "📚 Exportando base de conocimiento MQN..."
    tar -czf "$BACKUP_DIR/mqn_knowledge_base_${TIMESTAMP}.tar.gz" -C mqn_stack knowledge_base/
    log_message "✅ Base de conocimiento MQN exportada"
fi

# 10. Copiar backup al servidor SMB
log_message "📤 Copiando backup al servidor SMB..."
if cp "$BACKUP_FILE" "$SMB_MOUNT/"; then
    log_message "✅ Backup copiado exitosamente al servidor SMB"
    
    # 11. Copiar archivos individuales al SMB
    log_message "📁 Copiando archivos individuales al SMB..."
    cp "$BACKUP_DIR"/*.txt "$SMB_MOUNT/" 2>/dev/null || true
    cp "$BACKUP_DIR"/*.json "$SMB_MOUNT/" 2>/dev/null || true
    cp "$BACKUP_DIR"/*.sql "$SMB_MOUNT/" 2>/dev/null || true
    cp "$BACKUP_DIR"/*.tar.gz "$SMB_MOUNT/" 2>/dev/null || true
    
    # 12. Limpiar backups antiguos (mantener solo últimos 7 días)
    log_message "🧹 Limpiando backups antiguos..."
    find "$SMB_MOUNT" -name "winii_stack_backup_*.tar.gz" -mtime +7 -delete
    find "$BACKUP_DIR" -name "winii_stack_backup_*.tar.gz" -mtime +7 -delete
    
    # 13. Crear reporte de backup
    REPORT_FILE="$SMB_MOUNT/backup_report_${TIMESTAMP}.txt"
    {
        echo "=== REPORTE DE BACKUP WINII STACK ==="
        echo "Fecha: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "Backup: $BACKUP_NAME"
        echo "Tamaño: $(du -h "$BACKUP_FILE" | cut -f1)"
        echo "Estado: ✅ EXITOSO"
        echo ""
        echo "=== SERVICIOS ACTIVOS ==="
        docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
        echo ""
        echo "=== ARCHIVOS DE BACKUP CREADOS ==="
        ls -la "$BACKUP_DIR"/*"${TIMESTAMP}"* 2>/dev/null || echo "No se encontraron archivos de backup"
        echo ""
        echo "=== ESPACIO EN DISCO ==="
        df -h
        echo ""
        echo "=== LOGS DE BACKUP ==="
        tail -20 "$LOG_FILE"
    } > "$REPORT_FILE"
    
    log_message "📋 Reporte de backup creado: $REPORT_FILE"
    
else
    log_message "❌ Error copiando backup al servidor SMB"
    exit 1
fi

log_message "🎉 Backup diario completado exitosamente"
log_message "📁 Archivo principal: $BACKUP_FILE"
log_message "📤 Ubicación SMB: $SMB_MOUNT/"

# 14. Notificación (opcional - si tienes n8n configurado)
if command -v curl >/dev/null 2>&1; then
    log_message "📱 Enviando notificación de backup completado..."
    # Aquí puedes agregar webhook a n8n o notificación por email
fi

log_message "✅ Backup diario automático finalizado"
