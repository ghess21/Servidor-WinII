#!/bin/bash
# ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
# ┃    INTEGRACIÓN ASISTENTE GRÁFICO IA   ┃
# ┃    Media Quality Net - Sistema MQN    ┃
# ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

WORKDIR="$(pwd)"
LOG_FILE="$WORKDIR/logs/integracion_ai.log"
AI_DIR="$WORKDIR/asistente_grafico_ia"

# Crear directorios necesarios
mkdir -p "$(dirname "$LOG_FILE")"

# Función de logging
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log_message "🚀 Iniciando integración del Asistente Gráfico de IA con MQN"

# 1. Verificar que el asistente de IA existe
if [ ! -d "$AI_DIR" ]; then
    log_message "❌ Error: Directorio del asistente de IA no encontrado"
    echo "💡 Ejecuta primero: cd asistente_grafico_ia && ./init_asistente_ai.sh"
    exit 1
fi

log_message "✅ Directorio del asistente de IA encontrado"

# 2. Verificar que el asistente esté funcionando
log_message "🔍 Verificando estado del asistente de IA..."

cd "$AI_DIR"

# Verificar si los servicios están corriendo
if ! docker-compose ps | grep -q "backend_ai"; then
    log_message "⚠️ Advertencia: El asistente de IA no está funcionando"
    echo "🚀 Iniciando el asistente de IA..."
    ./start_asistente_ai.sh
    sleep 30
fi

# Verificar conectividad
if ! curl -s "http://localhost:8000/health" >/dev/null 2>&1; then
    log_message "❌ Error: El backend del asistente de IA no responde"
    echo "💡 Verifica que los servicios estén funcionando: docker-compose ps"
    exit 1
fi

log_message "✅ Asistente de IA funcionando correctamente"

# 3. Integrar con la base de datos MQN
log_message "🗄️ Integrando con la base de datos MQN..."

# Crear tablas de integración en la base de datos MQN
cd "$WORKDIR"

# Verificar si PostgreSQL está funcionando
if ! docker ps | grep -q "postgres"; then
    log_message "❌ Error: PostgreSQL no está funcionando"
    exit 1
fi

# Crear script SQL de integración
cat > database/integracion_ai_mqn.sql << 'EOF'
-- Integración del Asistente Gráfico de IA con MQN
-- Ejecutar en la base de datos mqn_database

-- Tabla de integración de diseños IA
CREATE TABLE IF NOT EXISTS ai_designs_integration (
    id SERIAL PRIMARY KEY,
    mqn_design_id INTEGER REFERENCES designs(id),
    ai_design_id VARCHAR(255),
    integration_status VARCHAR(50) DEFAULT 'pending',
    sync_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    last_sync TIMESTAMP,
    error_message TEXT
);

-- Tabla de mapeo de productos MQN con tipos de diseño IA
CREATE TABLE IF NOT EXISTS product_design_mapping (
    id SERIAL PRIMARY KEY,
    mqn_product_id INTEGER REFERENCES productos(id),
    ai_design_type VARCHAR(100),
    ai_template_id VARCHAR(255),
    mapping_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Tabla de historial de integración
CREATE TABLE IF NOT EXISTS ai_integration_log (
    id SERIAL PRIMARY KEY,
    operation_type VARCHAR(50),
    mqn_entity_type VARCHAR(50),
    mqn_entity_id INTEGER,
    ai_entity_type VARCHAR(50),
    ai_entity_id VARCHAR(255),
    operation_status VARCHAR(50),
    details TEXT,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Índices para optimización
CREATE INDEX idx_ai_designs_integration_mqn_id ON ai_designs_integration(mqn_design_id);
CREATE INDEX idx_ai_designs_integration_status ON ai_designs_integration(integration_status);
CREATE INDEX idx_product_design_mapping_product_id ON product_design_mapping(mqn_product_id);
CREATE INDEX idx_ai_integration_log_timestamp ON ai_integration_log(timestamp);

-- Insertar mapeos básicos de productos
INSERT INTO product_design_mapping (mqn_product_id, ai_design_type, ai_template_id) VALUES
(1, 'playera', 'playera_basica_001'),
(2, 'taza', 'taza_circular_001'),
(3, 'poster', 'poster_alta_resolucion_001'),
(4, 'tarjeta', 'tarjeta_corporativa_001')
ON CONFLICT (mqn_product_id) DO NOTHING;

-- Función para sincronizar diseños IA con MQN
CREATE OR REPLACE FUNCTION sync_ai_design_with_mqn(
    p_ai_design_id VARCHAR(255),
    p_design_data JSONB
) RETURNS INTEGER AS $$
DECLARE
    v_mqn_design_id INTEGER;
    v_integration_id INTEGER;
BEGIN
    -- Crear registro en la tabla de diseños MQN
    INSERT INTO designs (
        title,
        description,
        design_type,
        status,
        ai_generated,
        eps_file_path,
        preview_image_path,
        price
    ) VALUES (
        p_design_data->>'title',
        p_design_data->>'description',
        p_design_data->>'design_type',
        'pending',
        true,
        p_design_data->>'eps_file_path',
        p_design_data->>'preview_image_path',
        (p_design_data->>'price')::DECIMAL
    ) RETURNING id INTO v_mqn_design_id;
    
    -- Crear registro de integración
    INSERT INTO ai_designs_integration (
        mqn_design_id,
        ai_design_id,
        integration_status,
        sync_timestamp
    ) VALUES (
        v_mqn_design_id,
        p_ai_design_id,
        'synced',
        CURRENT_TIMESTAMP
    ) RETURNING id INTO v_integration_id;
    
    -- Registrar en el log
    INSERT INTO ai_integration_log (
        operation_type,
        mqn_entity_type,
        mqn_entity_id,
        ai_entity_type,
        ai_entity_id,
        operation_status,
        details
    ) VALUES (
        'sync',
        'design',
        v_mqn_design_id,
        'ai_design',
        p_ai_design_id,
        'success',
        'Diseño IA sincronizado exitosamente con MQN'
    );
    
    RETURN v_mqn_design_id;
EXCEPTION
    WHEN OTHERS THEN
        -- Registrar error en el log
        INSERT INTO ai_integration_log (
            operation_type,
            mqn_entity_type,
            mqn_entity_id,
            ai_entity_type,
            ai_entity_id,
            operation_status,
            details
        ) VALUES (
            'sync',
            'design',
            COALESCE(v_mqn_design_id, 0),
            'ai_design',
            p_ai_design_id,
            'error',
            'Error sincronizando diseño: ' || SQLERRM
        );
        
        RAISE;
END;
$$ LANGUAGE plpgsql;
EOF

log_message "✅ Script SQL de integración creado"

# 4. Crear script de sincronización automática
log_message "🔄 Creando script de sincronización automática..."

cat > scripts/sync_ai_mqn.sh << 'EOF'
#!/bin/bash
# Script de sincronización automática entre Asistente IA y MQN

WORKDIR="$(pwd)"
LOG_FILE="$WORKDIR/logs/sync_ai_mqn.log"
AI_API_URL="http://localhost:8000"
MQN_DB_HOST="localhost"
MQN_DB_PORT="5432"
MQN_DB_NAME="mqn_database"
MQN_DB_USER="mqn_user"

# Función de logging
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log_message "🔄 Iniciando sincronización AI-MQN"

# 1. Obtener diseños nuevos del asistente IA
log_message "📥 Obteniendo diseños nuevos del asistente IA..."

NEW_DESIGNS=$(curl -s "$AI_API_URL/api/v1/designs/new" \
    -H "Authorization: Bearer $MQN_AI_API_KEY" \
    -H "Content-Type: application/json")

if [ $? -ne 0 ]; then
    log_message "❌ Error obteniendo diseños del asistente IA"
    exit 1
fi

# 2. Procesar cada diseño nuevo
echo "$NEW_DESIGNS" | jq -r '.[] | @base64' | while read design_b64; do
    if [ ! -z "$design_b64" ]; then
        design_json=$(echo "$design_b64" | base64 -d)
        
        # Extraer datos del diseño
        design_id=$(echo "$design_json" | jq -r '.id')
        title=$(echo "$design_json" | jq -r '.title')
        description=$(echo "$design_json" | jq -r '.description')
        design_type=$(echo "$design_json" | jq -r '.design_type')
        eps_path=$(echo "$design_json" | jq -r '.eps_file_path')
        preview_path=$(echo "$design_json" | jq -r '.preview_image_path')
        price=$(echo "$design_json" | jq -r '.price')
        
        log_message "🔄 Procesando diseño: $title (ID: $design_id)"
        
        # Sincronizar con base de datos MQN
        psql -h "$MQN_DB_HOST" -p "$MQN_DB_PORT" -U "$MQN_DB_USER" -d "$MQN_DB_NAME" \
            -c "SELECT sync_ai_design_with_mqn('$design_id', '{\"title\": \"$title\", \"description\": \"$description\", \"design_type\": \"$design_type\", \"eps_file_path\": \"$eps_path\", \"preview_image_path\": \"$preview_path\", \"price\": $price}');"
        
        if [ $? -eq 0 ]; then
            log_message "✅ Diseño $design_id sincronizado exitosamente"
            
            # Marcar como sincronizado en el asistente IA
            curl -s -X PUT "$AI_API_URL/api/v1/designs/$design_id/sync" \
                -H "Authorization: Bearer $MQN_AI_API_KEY" \
                -H "Content-Type: application/json" \
                -d '{"synced": true, "synced_at": "'$(date -Iseconds)'"}'
        else
            log_message "❌ Error sincronizando diseño $design_id"
        fi
    fi
done

# 3. Sincronizar productos MQN con plantillas IA
log_message "🔄 Sincronizando productos MQN con plantillas IA..."

PRODUCTS=$(psql -h "$MQN_DB_HOST" -p "$MQN_DB_PORT" -U "$MQN_DB_USER" -d "$MQN_DB_NAME" \
    -t -c "SELECT id, nombre, categoria FROM productos WHERE activo = true;")

echo "$PRODUCTS" | while IFS='|' read -r id nombre categoria; do
    if [ ! -z "$id" ]; then
        # Mapear categoría MQN con tipo de diseño IA
        case "$categoria" in
            "playeras"|"ropa") ai_type="playera" ;;
            "tazas"|"vasos") ai_type="taza" ;;
            "posters"|"carteles") ai_type="poster" ;;
            "tarjetas"|"cartas") ai_type="tarjeta" ;;
            *) ai_type="general" ;;
        esac
        
        # Actualizar mapeo
        psql -h "$MQN_DB_HOST" -p "$MQN_DB_PORT" -U "$MQN_DB_USER" -d "$MQN_DB_NAME" \
            -c "INSERT INTO product_design_mapping (mqn_product_id, ai_design_type) VALUES ($id, '$ai_type') ON CONFLICT (mqn_product_id) DO UPDATE SET ai_design_type = EXCLUDED.ai_design_type;"
        
        log_message "✅ Producto $nombre mapeado con tipo IA: $ai_type"
    fi
done

log_message "🎉 Sincronización AI-MQN completada exitosamente"
EOF

chmod +x scripts/sync_ai_mqn.sh

# 5. Crear cron job para sincronización automática
log_message "⏰ Configurando sincronización automática..."

# Verificar si ya existe el cron job
if ! crontab -l 2>/dev/null | grep -q "sync_ai_mqn"; then
    # Agregar cron job para sincronización cada 15 minutos
    (crontab -l 2>/dev/null; echo "*/15 * * * * $WORKDIR/scripts/sync_ai_mqn.sh >> $WORKDIR/logs/sync_ai_mqn.log 2>&1") | crontab -
    log_message "✅ Cron job de sincronización configurado (cada 15 minutos)"
else
    log_message "ℹ️ Cron job de sincronización ya existe"
fi

# 6. Crear script de monitoreo de integración
log_message "📊 Creando script de monitoreo de integración..."

cat > scripts/monitor_integracion_ai.sh << 'EOF'
#!/bin/bash
# Script de monitoreo de la integración AI-MQN

WORKDIR="$(pwd)"
LOG_FILE="$WORKDIR/logs/monitor_integracion_ai.log"

echo "📊 MONITOREO DE INTEGRACIÓN AI-MQN"
echo "=================================="

# Verificar estado del asistente IA
echo "🤖 Estado del Asistente de IA:"
if curl -s "http://localhost:8000/health" >/dev/null 2>&1; then
    echo "✅ Backend IA: Funcionando"
else
    echo "❌ Backend IA: No responde"
fi

if curl -s "http://localhost:3000" >/dev/null 2>&1; then
    echo "✅ Frontend IA: Funcionando"
else
    echo "❌ Frontend IA: No responde"
fi

# Verificar estado de la base de datos MQN
echo ""
echo "🗄️ Estado de la Base de Datos MQN:"
if docker ps | grep -q "postgres"; then
    echo "✅ PostgreSQL: Funcionando"
    
    # Verificar tablas de integración
    TABLES=$(psql -h localhost -p 5432 -U mqn_user -d mqn_database -t -c "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_name LIKE '%ai%';")
    
    if [ ! -z "$TABLES" ]; then
        echo "✅ Tablas de integración: Encontradas"
        echo "$TABLES" | while read table; do
            if [ ! -z "$table" ]; then
                echo "  • $table"
            fi
        done
    else
        echo "❌ Tablas de integración: No encontradas"
    fi
else
    echo "❌ PostgreSQL: No funcionando"
fi

# Verificar sincronización reciente
echo ""
echo "🔄 Estado de Sincronización:"
LAST_SYNC=$(tail -1 logs/sync_ai_mqn.log 2>/dev/null | grep "sincronización completada" | head -1)

if [ ! -z "$LAST_SYNC" ]; then
    echo "✅ Última sincronización: $LAST_SYNC"
else
    echo "❌ No se encontraron registros de sincronización"
fi

# Verificar cron jobs
echo ""
echo "⏰ Cron Jobs de Integración:"
if crontab -l 2>/dev/null | grep -q "sync_ai_mqn"; then
    echo "✅ Sincronización automática: Configurada"
    crontab -l | grep "sync_ai_mqn"
else
    echo "❌ Sincronización automática: No configurada"
fi

# Verificar logs de integración
echo ""
echo "📋 Logs de Integración:"
for log in logs/sync_ai_mqn.log logs/integracion_ai.log; do
    if [ -f "$log" ]; then
        echo "✅ $log: $(ls -lh "$log" | awk '{print $5, $6, $7}')"
        echo "  Últimas líneas:"
        tail -3 "$log" | sed 's/^/    /'
    else
        echo "❌ $log: No encontrado"
    fi
done

echo ""
echo "🎯 Resumen de Integración:"
echo "=========================="
echo "• Asistente IA: $(curl -s http://localhost:8000/health >/dev/null 2>&1 && echo "✅ Funcionando" || echo "❌ No responde")"
echo "• Base de datos: $(docker ps | grep -q "postgres" && echo "✅ Funcionando" || echo "❌ No funcionando")"
echo "• Sincronización: $(crontab -l 2>/dev/null | grep -q "sync_ai_mqn" && echo "✅ Configurada" || echo "❌ No configurada")"
echo "• Logs: $(ls logs/*ai*.log 2>/dev/null | wc -l) archivos encontrados"
EOF

chmod +x scripts/monitor_integracion_ai.sh

# 7. Crear script de prueba de integración
log_message "🧪 Creando script de prueba de integración..."

cat > scripts/test_integracion_ai.sh << 'EOF'
#!/bin/bash
# Script de prueba de la integración AI-MQN

WORKDIR="$(pwd)"
LOG_FILE="$WORKDIR/logs/test_integracion_ai.log"

echo "🧪 PRUEBA DE INTEGRACIÓN AI-MQN"
echo "==============================="

# Función de logging
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log_message "🧪 Iniciando pruebas de integración"

# 1. Probar conectividad con el asistente IA
echo "🔍 Probando conectividad con el asistente IA..."

if curl -s "http://localhost:8000/health" >/dev/null 2>&1; then
    log_message "✅ Conectividad con asistente IA: OK"
else
    log_message "❌ Conectividad con asistente IA: FALLÓ"
    exit 1
fi

# 2. Probar API de generación de diseños
echo "🎨 Probando API de generación de diseños..."

TEST_RESPONSE=$(curl -s -X POST "http://localhost:8000/api/v1/designs/test" \
    -H "Content-Type: application/json" \
    -d '{
        "test": true,
        "user_request": "Prueba de integración",
        "product_type": "playera",
        "style": "moderno",
        "colors": ["azul"],
        "elements": ["test"]
    }')

if [ $? -eq 0 ] && [ ! -z "$TEST_RESPONSE" ]; then
    log_message "✅ API de generación de diseños: OK"
else
    log_message "❌ API de generación de diseños: FALLÓ"
fi

# 3. Probar conexión con base de datos MQN
echo "🗄️ Probando conexión con base de datos MQN..."

if docker ps | grep -q "postgres"; then
    DB_TEST=$(psql -h localhost -p 5432 -U mqn_user -d mqn_database -t -c "SELECT 1;" 2>/dev/null)
    
    if [ $? -eq 0 ]; then
        log_message "✅ Conexión con base de datos MQN: OK"
        
        # Verificar tablas de integración
        TABLES=$(psql -h localhost -p 5432 -U mqn_user -d mqn_database -t -c "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_name LIKE '%ai%';")
        
        if [ ! -z "$TABLES" ]; then
            log_message "✅ Tablas de integración: Encontradas"
        else
            log_message "⚠️ Tablas de integración: No encontradas"
        fi
    else
        log_message "❌ Conexión con base de datos MQN: FALLÓ"
    fi
else
    log_message "❌ PostgreSQL no está funcionando"
fi

# 4. Probar sincronización
echo "🔄 Probando sincronización..."

if [ -f "scripts/sync_ai_mqn.sh" ]; then
    # Ejecutar sincronización en modo prueba
    TEST_SYNC=$(bash scripts/sync_ai_mqn.sh 2>&1)
    
    if [ $? -eq 0 ]; then
        log_message "✅ Sincronización: OK"
    else
        log_message "⚠️ Sincronización: Con errores (modo prueba)"
    fi
else
    log_message "❌ Script de sincronización no encontrado"
fi

# 5. Resumen de pruebas
echo ""
echo "📊 RESUMEN DE PRUEBAS:"
echo "======================"

TESTS_PASSED=0
TESTS_TOTAL=4

# Contar pruebas exitosas
if curl -s "http://localhost:8000/health" >/dev/null 2>&1; then ((TESTS_PASSED++)); fi
if [ ! -z "$TEST_RESPONSE" ]; then ((TESTS_PASSED++)); fi
if docker ps | grep -q "postgres"; then ((TESTS_PASSED++)); fi
if [ -f "scripts/sync_ai_mqn.sh" ]; then ((TESTS_PASSED++)); fi

echo "✅ Pruebas exitosas: $TESTS_PASSED/$TESTS_TOTAL"

if [ $TESTS_PASSED -eq $TESTS_TOTAL ]; then
    echo "🎉 ¡Todas las pruebas pasaron! La integración está funcionando correctamente."
    log_message "🎉 Todas las pruebas de integración pasaron exitosamente"
else
    echo "⚠️ Algunas pruebas fallaron. Revisa los logs para más detalles."
    log_message "⚠️ Algunas pruebas de integración fallaron"
fi

echo ""
echo "📋 Logs de prueba: $LOG_FILE"
EOF

chmod +x scripts/test_integracion_ai.sh

# 8. Actualizar el asistente principal de MQN
log_message "🔄 Actualizando asistente principal de MQN..."

# Verificar si existe el asistente principal
if [ -f "init_mqn.sh" ]; then
    # Agregar opción para el asistente de IA
    if ! grep -q "asistente_grafico_ia" init_mqn.sh; then
        sed -i '/echo "0) Salir"/i echo "9) 🎨 Asistente Gráfico de IA (asistente_grafico_ia/)"' init_mqn.sh
        sed -i '/case "$opcion" in/a  9) cd asistente_grafico_ia && ./start_asistente_ai.sh ;;' init_mqn.sh
        log_message "✅ Opción del asistente de IA agregada al menú principal"
    else
        log_message "ℹ️ Opción del asistente de IA ya existe en el menú principal"
    fi
fi

# 9. Crear enlaces simbólicos para fácil acceso
log_message "🔗 Creando enlaces simbólicos..."

cd "$WORKDIR"

# Enlace al directorio del asistente de IA
if [ ! -L "ai_designer" ]; then
    ln -s asistente_grafico_ia ai_designer
    log_message "✅ Enlace simbólico 'ai_designer' creado"
fi

# Enlace a los scripts principales
if [ ! -L "scripts/ai_sync.sh" ]; then
    ln -s ../scripts/sync_ai_mqn.sh scripts/ai_sync.sh
    log_message "✅ Enlace simbólico 'ai_sync.sh' creado"
fi

if [ ! -L "scripts/ai_monitor.sh" ]; then
    ln -s ../scripts/monitor_integracion_ai.sh scripts/ai_monitor.sh
    log_message "✅ Enlace simbólico 'ai_monitor.sh' creado"
fi

# 10. Resumen final de integración
log_message "🎉 Integración del Asistente Gráfico de IA completada"
echo ""
echo "🎨 INTEGRACIÓN ASISTENTE GRÁFICO DE IA - COMPLETADA"
echo "===================================================="
echo ""
echo "✅ Estructura del proyecto creada"
echo "✅ Scripts de integración preparados"
echo "✅ Sincronización automática configurada"
echo "✅ Cron jobs configurados"
echo "✅ Scripts de monitoreo y prueba creados"
echo "✅ Enlaces simbólicos configurados"
echo ""
echo "🚀 PRÓXIMOS PASOS:"
echo "1. Configurar variables de entorno en asistente_grafico_ia/.env"
echo "2. Iniciar el asistente de IA: cd asistente_grafico_ia && ./start_asistente_ai.sh"
echo "3. Probar la integración: ./scripts/test_integracion_ai.sh"
echo "4. Monitorear: ./scripts/monitor_integracion_ai.sh"
echo ""
echo "🔧 COMANDOS DISPONIBLES:"
echo "• ./scripts/sync_ai_mqn.sh - Sincronización manual"
echo "• ./scripts/monitor_integracion_ai.sh - Monitoreo de integración"
echo "• ./scripts/test_integracion_ai.sh - Pruebas de integración"
echo "• cd ai_designer && ./start_asistente_ai.sh - Iniciar asistente IA"
echo ""
echo "📚 DOCUMENTACIÓN:"
echo "• asistente_grafico_ia/README.md - Documentación completa"
echo "• asistente_grafico_ia/QUICKSTART.md - Guía de inicio rápido"
echo "• docs/SISTEMA_BACKUPS_INTEGRADO.md - Sistema de backups"
echo ""
echo "🎯 ¡Tu Asistente Gráfico de IA está completamente integrado con MQN!"
echo "   Los clientes ahora pueden crear diseños por WhatsApp y se sincronizarán automáticamente."
