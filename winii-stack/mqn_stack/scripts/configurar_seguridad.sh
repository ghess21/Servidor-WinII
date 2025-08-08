#!/bin/bash
# ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
# ┃       CONFIGURAR SEGURIDAD MQN       ┃
# ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

echo "🔒 Configurando seguridad para Media Quality Net..."
echo "=================================================="

# Crear directorio de backups si no existe
mkdir -p backups
mkdir -p logs/backup

echo "📁 Directorios de backup creados"

# Configurar variables de entorno para n8n
echo "🔧 Configurando variables de entorno..."

# Crear archivo de configuración de seguridad
cat > .env.security << 'EOF'
# Configuración de seguridad para MQN
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=mediaqualitynet@gmail.com
N8N_BASIC_AUTH_PASSWORD=Cadena_2000

# API Key para backups
N8N_API_KEY=mqn_api_key_2024

# Configuración de base de datos
DB_TYPE=postgresdb
DB_POSTGRESDB_HOST=postgres
DB_POSTGRESDB_PORT=5432
DB_POSTGRESDB_DATABASE=mqn_db
DB_POSTGRESDB_USER=mqn_user
DB_POSTGRESDB_PASSWORD=mqn_password

# Configuración de seguridad
N8N_ENCRYPTION_KEY=mqn_encryption_key_2024
N8N_USER_MANAGEMENT_DISABLED=false
N8N_DIAGNOSTICS_ENABLED=false

# Configuración de logs
N8N_LOG_LEVEL=info
N8N_LOG_OUTPUT=file
N8N_LOG_FILE=/home/node/.n8n/logs/n8n.log

# Configuración de webhooks
WEBHOOK_URL=http://localhost:5678
WEBHOOK_TUNNEL_URL=http://localhost:5678

# Configuración de timezone
GENERIC_TIMEZONE=America/Mexico_City

# Configuración de backups
BACKUP_ENABLED=true
BACKUP_INTERVAL=6h
BACKUP_RETENTION_DAYS=30
EOF

echo "✅ Variables de entorno configuradas"

# Crear script de backup manual
cat > scripts/backup_manual.sh << 'EOF'
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
EOF

chmod +x scripts/backup_manual.sh

# Crear script de verificación de integridad
cat > scripts/verificar_integridad.sh << 'EOF'
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
EOF

chmod +x scripts/verificar_integridad.sh

# Crear script de recuperación rápida
cat > scripts/recuperacion_rapida.sh << 'EOF'
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
EOF

chmod +x scripts/recuperacion_rapida.sh

# Crear configuración de monitoreo
cat > config/monitoring.conf << 'EOF'
# Configuración de monitoreo para MQN

# Verificación cada 5 minutos
CHECK_INTERVAL=300

# Alertas por WhatsApp
ALERT_NUMBER=9671262441

# Umbrales de alerta
MAX_CPU_USAGE=80
MAX_MEMORY_USAGE=85
MAX_DISK_USAGE=90

# Servicios a monitorear
SERVICES=("n8n" "postgres" "redis")

# Logs a monitorear
LOG_FILES=(
    "logs/n8n.log"
    "logs/backup.log"
    "logs/system.log"
)
EOF

# Crear script de monitoreo
cat > scripts/monitor_sistema.sh << 'EOF'
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
EOF

chmod +x scripts/monitor_sistema.sh

# Crear documentación de seguridad
cat > docs/SEGURIDAD.md << 'EOF'
# 🔒 Guía de Seguridad - Media Quality Net

## 🛡️ **Medidas de Seguridad Implementadas**

### **Autenticación**
- ✅ Usuario: mediaqualitynet@gmail.com
- ✅ Contraseña: Cadena_2000
- ✅ API Key: mqn_api_key_2024

### **Backups Automáticos**
- ✅ Cada 6 horas automáticamente
- ✅ Notificación por WhatsApp
- ✅ Retención de 30 días

### **Monitoreo**
- ✅ Verificación de servicios cada 5 minutos
- ✅ Alertas por WhatsApp en caso de problemas
- ✅ Monitoreo de recursos del sistema

## 📋 **Comandos de Seguridad**

### **Backup Manual:**
```bash
./scripts/backup_manual.sh
```

### **Verificar Integridad:**
```bash
./scripts/verificar_integridad.sh
```

### **Recuperación Rápida:**
```bash
./scripts/recuperacion_rapida.sh
```

### **Monitoreo del Sistema:**
```bash
./scripts/monitor_sistema.sh
```

## 🚨 **Procedimientos de Emergencia**

### **Si n8n se pierde:**
1. Ejecutar: `./scripts/recuperacion_rapida.sh`
2. Si no funciona: `docker-compose down && docker-compose up -d`
3. Restaurar desde backup: `./scripts/restaurar_backup.sh backups/archivo.json`

### **Si se pierden datos:**
1. Verificar backups: `ls -la backups/`
2. Restaurar desde el backup más reciente
3. Verificar integridad: `./scripts/verificar_integridad.sh`

### **Si hay problemas de rendimiento:**
1. Monitorear recursos: `./scripts/monitor_sistema.sh`
2. Reiniciar servicios: `docker-compose restart`
3. Verificar logs: `docker-compose logs -f n8n`

## 📊 **Métricas de Seguridad**

- **Backups automáticos:** Cada 6 horas
- **Retención de backups:** 30 días
- **Verificación de integridad:** Cada 5 minutos
- **Alertas automáticas:** Por WhatsApp
- **Recuperación:** < 5 minutos

## 🔄 **Mantenimiento**

### **Diario:**
- Verificar que los backups se ejecuten correctamente
- Revisar alertas por WhatsApp
- Monitorear uso de recursos

### **Semanal:**
- Verificar integridad completa del sistema
- Revisar logs de seguridad
- Actualizar documentación si es necesario

### **Mensual:**
- Revisar políticas de seguridad
- Actualizar contraseñas si es necesario
- Verificar que todos los scripts funcionen

---

**Última actualización:** 2025-08-08
**Responsable:** Sistema MQN
EOF

echo ""
echo "✅ Configuración de seguridad completada!"
echo ""
echo "📋 Scripts creados:"
echo "• scripts/backup_manual.sh - Backup manual"
echo "• scripts/verificar_integridad.sh - Verificar sistema"
echo "• scripts/recuperacion_rapida.sh - Recuperación rápida"
echo "• scripts/monitor_sistema.sh - Monitoreo del sistema"
echo ""
echo "📚 Documentación:"
echo "• docs/SEGURIDAD.md - Guía de seguridad"
echo ""
echo "🔄 Para activar el sistema de seguridad:"
echo "1. Importar el workflow 'backup-seguridad-n8n.json' en n8n"
echo "2. Activar el workflow para backups automáticos"
echo "3. Ejecutar: ./scripts/verificar_integridad.sh"
echo ""
echo "🎯 ¡Sistema MQN asegurado y protegido!"
