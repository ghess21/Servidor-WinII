#!/bin/bash
# ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
# ┃      GESTOR UNIFICADO DE BACKUPS      ┃
# ┃    WinII Stack - Sistema Completo     ┃
# ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

WORKDIR="$(pwd)"
LOG_FILE="$WORKDIR/logs/gestor_backups.log"
BACKUP_DIR="$WORKDIR/backups"

# Crear directorios necesarios
mkdir -p "$BACKUP_DIR"
mkdir -p "$(dirname "$LOG_FILE")"

# Función de logging
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Función de mostrar menú
mostrar_menu() {
    clear
    echo "┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
    echo "┃      GESTOR UNIFICADO DE BACKUPS      ┃"
    echo "┃    WinII Stack - Sistema Completo     ┃"
    echo "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛"
    echo ""
    echo "🔍 ESTADO ACTUAL DEL SISTEMA:"
    echo "================================"
    
    # Verificar servicios activos
    echo "🐳 Docker: $(docker ps -q | wc -l) contenedores activos"
    echo "🤖 n8n: $(curl -s http://localhost:5678 >/dev/null 2>&1 && echo "✅ Activo (5678)" || echo "❌ Inactivo")"
    echo "🗄️ PostgreSQL: $(docker ps | grep -q postgres && echo "✅ Activo" || echo "❌ Inactivo")"
    echo "📦 Redis: $(docker ps | grep -q redis && echo "✅ Activo" || echo "❌ Inactivo")"
    
    echo ""
    echo "📊 BACKUPS CONFIGURADOS:"
    echo "========================="
    echo "1. 📋 docker-compose.yml.bak (automático en render_compose.sh)"
    echo "2. 🤖 n8n backup-seguridad-n8n.json (cada 6 horas)"
    echo "3. 💾 MQN backup manual (manual)"
    echo "4. 🚀 SMB diario automático (cada 2:00 AM)"
    
    echo ""
    echo "🧭 OPCIONES DISPONIBLES:"
    echo "========================"
    echo "1) 🔍 Ver estado de backups"
    echo "2) 📋 Backup de docker-compose.yml"
    echo "3) 🤖 Backup de n8n (workflows, credenciales)"
    echo "4) 💾 Backup MQN completo"
    echo "5) 🚀 Backup SMB completo"
    echo "6) 🔧 Configurar backup automático SMB"
    echo "7) 🧪 Probar conectividad SMB"
    echo "8) 📊 Ver logs de backup"
    echo "9) 🗑️ Limpiar backups antiguos"
    echo "10) 📈 Reporte de estado del sistema"
    echo "0) Salir"
    echo ""
}

# Función: Ver estado de backups
ver_estado_backups() {
    log_message "🔍 Verificando estado de backups..."
    echo ""
    echo "📊 ESTADO DE BACKUPS:"
    echo "====================="
    
    # Verificar backup de docker-compose
    if [ -f "docker-compose.yml.bak" ]; then
        echo "✅ docker-compose.yml.bak: $(ls -lh docker-compose.yml.bak | awk '{print $5, $6, $7}')"
    else
        echo "❌ docker-compose.yml.bak: No existe"
    fi
    
    # Verificar directorio de backups
    if [ -d "$BACKUP_DIR" ]; then
        echo "📁 Directorio backups: $(ls -1 "$BACKUP_DIR" | wc -l) archivos"
        echo "💾 Tamaño total: $(du -sh "$BACKUP_DIR" 2>/dev/null | cut -f1 || echo "No disponible")"
    else
        echo "❌ Directorio backups: No existe"
    fi
    
    # Verificar cron jobs
    echo ""
    echo "⏰ CRON JOBS ACTIVOS:"
    echo "===================="
    if crontab -l 2>/dev/null | grep -q "backup"; then
        crontab -l | grep "backup"
    else
        echo "❌ No hay cron jobs de backup configurados"
    fi
    
    # Verificar logs
    echo ""
    echo "📋 LOGS DISPONIBLES:"
    echo "===================="
    for log in logs/backup_*.log logs/gestor_backups.log; do
        if [ -f "$log" ]; then
            echo "✅ $log: $(ls -lh "$log" | awk '{print $5, $6, $7}')"
        fi
    done
}

# Función: Backup de docker-compose.yml
backup_docker_compose() {
    log_message "📋 Creando backup de docker-compose.yml..."
    if [ -f "docker-compose.yml" ]; then
        cp "docker-compose.yml" "docker-compose.yml.bak"
        echo "✅ Backup de docker-compose.yml creado: docker-compose.yml.bak"
        log_message "✅ Backup de docker-compose.yml creado exitosamente"
    else
        echo "❌ Error: docker-compose.yml no encontrado"
        log_message "❌ Error: docker-compose.yml no encontrado"
    fi
}

# Función: Backup de n8n
backup_n8n() {
    log_message "🤖 Iniciando backup de n8n..."
    echo "🤖 Exportando datos de n8n..."
    
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    
    # Intentar puerto 5678 (actual) y 5679 (documentado)
    for port in 5678 5679; do
        if curl -s "http://localhost:$port" >/dev/null 2>&1; then
            echo "🌐 n8n detectado en puerto $port"
            
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
            
            echo "✅ Datos de n8n exportados desde puerto $port"
            log_message "✅ Backup de n8n completado desde puerto $port"
            return 0
        fi
    done
    
    echo "❌ Error: n8n no está accesible en ningún puerto"
    log_message "❌ Error: n8n no está accesible"
}

# Función: Backup MQN completo
backup_mqn() {
    log_message "💾 Iniciando backup MQN completo..."
    echo "💾 Creando backup MQN completo..."
    
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    
    # Exportar workflows
    echo "📁 Exportando workflows..."
    curl -s -X GET "http://localhost:5678/api/v1/workflows" \
        -H "X-N8N-API-KEY: mqn_api_key_2024" > "$BACKUP_DIR/mqn_workflows_${TIMESTAMP}.json" 2>/dev/null || \
        curl -s -X GET "http://localhost:5678/api/v1/workflows" > "$BACKUP_DIR/mqn_workflows_${TIMESTAMP}.json"
    
    # Exportar base de datos
    echo "📊 Exportando base de datos..."
    if docker ps | grep -q "postgres"; then
        docker exec $(docker ps -q --filter "name=postgres") pg_dump -U postgres postgres > "$BACKUP_DIR/mqn_db_${TIMESTAMP}.sql" 2>/dev/null || \
        docker exec $(docker ps -q --filter "name=postgres") pg_dump -U postgres mqn_db > "$BACKUP_DIR/mqn_db_${TIMESTAMP}.sql" 2>/dev/null || \
        echo "⚠️ No se pudo exportar base de datos"
    fi
    
    # Crear backup de knowledge base
    echo "📚 Exportando base de conocimiento..."
    if [ -d "mqn_stack/knowledge_base" ]; then
        tar -czf "$BACKUP_DIR/mqn_knowledge_base_${TIMESTAMP}.tar.gz" -C mqn_stack knowledge_base/
        echo "✅ Base de conocimiento exportada"
    fi
    
    echo "✅ Backup MQN completado"
    log_message "✅ Backup MQN completado exitosamente"
}

# Función: Backup SMB completo
backup_smb() {
    log_message "🚀 Iniciando backup SMB completo..."
    echo "🚀 Ejecutando backup SMB completo..."
    
    if [ -f "scripts/backup_smb_diario.sh" ]; then
        bash "scripts/backup_smb_diario.sh"
        log_message "✅ Backup SMB ejecutado exitosamente"
    else
        echo "❌ Error: Script de backup SMB no encontrado"
        log_message "❌ Error: Script de backup SMB no encontrado"
    fi
}

# Función: Ver logs de backup
ver_logs_backup() {
    echo "📋 LOGS DE BACKUP DISPONIBLES:"
    echo "==============================="
    
    for log in logs/backup_*.log logs/gestor_backups.log; do
        if [ -f "$log" ]; then
            echo ""
            echo "📄 $log:"
            echo "----------------------------------------"
            tail -20 "$log" 2>/dev/null || echo "No se puede leer el archivo"
        fi
    done
    
    echo ""
    read -p "Presiona Enter para continuar..."
}

# Función: Limpiar backups antiguos
limpiar_backups_antiguos() {
    log_message "🧹 Iniciando limpieza de backups antiguos..."
    echo "🧹 Limpiando backups antiguos..."
    
    # Limpiar backups de más de 7 días
    find "$BACKUP_DIR" -name "*.tar.gz" -mtime +7 -delete 2>/dev/null
    find "$BACKUP_DIR" -name "*.sql" -mtime +7 -delete 2>/dev/null
    find "$BACKUP_DIR" -name "*.json" -mtime +7 -delete 2>/dev/null
    
    # Limpiar docker-compose.yml.bak antiguos
    if [ -f "docker-compose.yml.bak" ]; then
        if [ $(find "docker-compose.yml.bak" -mtime +7 | wc -l) -gt 0 ]; then
            rm -f "docker-compose.yml.bak"
            echo "✅ docker-compose.yml.bak antiguo eliminado"
        fi
    fi
    
    echo "✅ Limpieza de backups antiguos completada"
    log_message "✅ Limpieza de backups antiguos completada"
}

# Función: Reporte de estado del sistema
reporte_estado_sistema() {
    log_message "📈 Generando reporte de estado del sistema..."
    echo "📈 GENERANDO REPORTE DE ESTADO..."
    
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    REPORT_FILE="$BACKUP_DIR/estado_sistema_${TIMESTAMP}.txt"
    
    {
        echo "=== REPORTE DE ESTADO DEL SISTEMA WINII STACK ==="
        echo "Fecha: $(date '+%Y-%m-%d %H:%M:%S')"
        echo "Usuario: $USER"
        echo "Directorio: $WORKDIR"
        echo ""
        echo "=== SERVICIOS DOCKER ==="
        docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
        echo ""
        echo "=== VOLÚMENES DOCKER ==="
        docker volume ls
        echo ""
        echo "=== ESPACIO EN DISCO ==="
        df -h
        echo ""
        echo "=== MEMORIA RAM ==="
        free -h
        echo ""
        echo "=== BACKUPS DISPONIBLES ==="
        ls -la "$BACKUP_DIR" 2>/dev/null || echo "Directorio de backups no disponible"
        echo ""
        echo "=== CRON JOBS ACTIVOS ==="
        crontab -l 2>/dev/null | grep -v "^#" | grep -v "^$" || echo "No hay cron jobs activos"
        echo ""
        echo "=== LOGS DEL SISTEMA ==="
        echo "Logs disponibles:"
        ls -la logs/*.log 2>/dev/null || echo "No hay logs disponibles"
    } > "$REPORT_FILE"
    
    echo "✅ Reporte generado: $REPORT_FILE"
    log_message "✅ Reporte de estado del sistema generado: $REPORT_FILE"
}

# Función principal
main() {
    while true; do
        mostrar_menu
        read -p "📝 Selecciona una opción [0-10]: " opcion
        
        case "$opcion" in
            1) ver_estado_backups ;;
            2) backup_docker_compose ;;
            3) backup_n8n ;;
            4) backup_mqn ;;
            5) backup_smb ;;
            6) bash scripts/setup_backup_cron.sh ;;
            7) bash scripts/test_smb_connection.sh ;;
            8) ver_logs_backup ;;
            9) limpiar_backups_antiguos ;;
            10) reporte_estado_sistema ;;
            0) 
                echo "👋 Saliendo del gestor de backups. ¡Hasta pronto!"
                log_message "👋 Usuario salió del gestor de backups"
                exit 0
                ;;
            *) 
                echo "❌ Opción inválida. Intenta nuevamente."
                sleep 2
                ;;
        esac
        
        echo ""
        read -p "Presiona Enter para continuar..."
    done
}

# Ejecutar función principal
main
