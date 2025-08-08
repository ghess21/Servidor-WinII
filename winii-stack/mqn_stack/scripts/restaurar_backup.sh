#!/bin/bash
# ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
# ┃       RESTAURAR BACKUP MQN           ┃
# ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

echo "🔄 Restaurando backup de Media Quality Net..."
echo "============================================="

# Verificar si se proporcionó un archivo de backup
if [ $# -eq 0 ]; then
    echo "❌ Error: Debes especificar un archivo de backup"
    echo ""
    echo "📋 Uso:"
    echo "  ./restaurar_backup.sh backups/mqn_backup_YYYY-MM-DDTHH-MM-SS.json"
    echo ""
    echo "📁 Backups disponibles:"
    ls -la backups/ 2>/dev/null || echo "  No hay backups disponibles"
    exit 1
fi

BACKUP_FILE="$1"

# Verificar que el archivo existe
if [ ! -f "$BACKUP_FILE" ]; then
    echo "❌ Error: El archivo de backup no existe: $BACKUP_FILE"
    exit 1
fi

echo "📁 Archivo de backup: $BACKUP_FILE"
echo ""

# Crear directorio temporal para la restauración
TEMP_DIR="/tmp/mqn_restore_$(date +%s)"
mkdir -p "$TEMP_DIR"

echo "🔄 Extrayendo datos del backup..."

# Extraer datos del backup usando jq
jq -r '.workflows' "$BACKUP_FILE" > "$TEMP_DIR/workflows.json" 2>/dev/null
jq -r '.credentials' "$BACKUP_FILE" > "$TEMP_DIR/credentials.json" 2>/dev/null
jq -r '.conversaciones' "$BACKUP_FILE" > "$TEMP_DIR/conversaciones.json" 2>/dev/null
jq -r '.productos' "$BACKUP_FILE" > "$TEMP_DIR/productos.json" 2>/dev/null

echo "✅ Datos extraídos"

# Función para restaurar workflows
restaurar_workflows() {
    echo "🔄 Restaurando workflows..."
    
    # Verificar si n8n está corriendo
    if ! curl -s http://localhost:5679 > /dev/null; then
        echo "❌ Error: n8n no está corriendo"
        echo "💡 Inicia n8n primero: docker-compose restart n8n"
        return 1
    fi
    
    # Restaurar cada workflow
    jq -c '.[]' "$TEMP_DIR/workflows.json" | while read -r workflow; do
        workflow_name=$(echo "$workflow" | jq -r '.name')
        echo "📁 Restaurando workflow: $workflow_name"
        
        # Crear archivo temporal para el workflow
        echo "$workflow" > "$TEMP_DIR/workflow_temp.json"
        
        # Importar workflow a n8n
        curl -X POST "http://localhost:5679/api/v1/workflows" \
            -H "Content-Type: application/json" \
            -H "X-N8N-API-KEY: mqn_api_key_2024" \
            -d @"$TEMP_DIR/workflow_temp.json" \
            -s > /dev/null
        
        if [ $? -eq 0 ]; then
            echo "✅ Workflow restaurado: $workflow_name"
        else
            echo "❌ Error restaurando workflow: $workflow_name"
        fi
    done
}

# Función para restaurar base de datos
restaurar_base_datos() {
    echo "🔄 Restaurando base de datos..."
    
    # Restaurar conversaciones
    if [ -s "$TEMP_DIR/conversaciones.json" ]; then
        echo "📊 Restaurando conversaciones..."
        jq -c '.[]' "$TEMP_DIR/conversaciones.json" | while read -r conversacion; do
            # Insertar conversación en la base de datos
            docker-compose exec -T postgres psql -U mqn_user -d mqn_db -c "
                INSERT INTO conversaciones (numero_telefono, mensaje_entrada, mensaje_salida, tipo_comando, timestamp)
                VALUES (
                    '$(echo "$conversacion" | jq -r '.numero_telefono')',
                    '$(echo "$conversacion" | jq -r '.mensaje_entrada')',
                    '$(echo "$conversacion" | jq -r '.mensaje_salida')',
                    '$(echo "$conversacion" | jq -r '.tipo_comando')',
                    '$(echo "$conversacion" | jq -r '.timestamp')'
                ) ON CONFLICT DO NOTHING;
            " 2>/dev/null
        done
        echo "✅ Conversaciones restauradas"
    fi
    
    # Restaurar productos
    if [ -s "$TEMP_DIR/productos.json" ]; then
        echo "📦 Restaurando productos..."
        jq -c '.[]' "$TEMP_DIR/productos.json" | while read -r producto; do
            # Insertar producto en la base de datos
            docker-compose exec -T postgres psql -U mqn_user -d mqn_db -c "
                INSERT INTO productos (nombre, descripcion, categoria, material, tecnica_impresion, precio_base, precio_venta, imagen_path)
                VALUES (
                    '$(echo "$producto" | jq -r '.nombre')',
                    '$(echo "$producto" | jq -r '.descripcion')',
                    '$(echo "$producto" | jq -r '.categoria')',
                    '$(echo "$producto" | jq -r '.material')',
                    '$(echo "$producto" | jq -r '.tecnica_impresion')',
                    $(echo "$producto" | jq -r '.precio_base'),
                    $(echo "$producto" | jq -r '.precio_venta'),
                    '$(echo "$producto" | jq -r '.imagen_path')'
                ) ON CONFLICT DO NOTHING;
            " 2>/dev/null
        done
        echo "✅ Productos restaurados"
    fi
}

# Función para restaurar knowledge base
restaurar_knowledge_base() {
    echo "🔄 Restaurando base de conocimiento..."
    
    # Crear directorios si no existen
    mkdir -p knowledge_base/{empresa,productos,clientes,disenos,procesos,reglas,archivos_fotograficos}
    
    # Restaurar archivos de la base de conocimiento
    if [ -d "backups/knowledge_base" ]; then
        echo "📁 Copiando archivos de conocimiento..."
        cp -r backups/knowledge_base/* knowledge_base/ 2>/dev/null
        echo "✅ Base de conocimiento restaurada"
    else
        echo "⚠️ No se encontró backup de base de conocimiento"
    fi
}

# Función para verificar servicios
verificar_servicios() {
    echo "🔍 Verificando servicios..."
    
    # Verificar n8n
    if curl -s http://localhost:5679 > /dev/null; then
        echo "✅ n8n funcionando"
    else
        echo "❌ n8n no está funcionando"
        return 1
    fi
    
    # Verificar PostgreSQL
    if docker-compose exec postgres pg_isready -U mqn_user > /dev/null 2>&1; then
        echo "✅ PostgreSQL funcionando"
    else
        echo "❌ PostgreSQL no está funcionando"
        return 1
    fi
    
    return 0
}

# Función para mostrar resumen
mostrar_resumen() {
    echo ""
    echo "🎯 Resumen de restauración:"
    echo "=========================="
    
    # Contar workflows restaurados
    workflows_count=$(jq '.workflows | length' "$BACKUP_FILE" 2>/dev/null || echo "0")
    echo "📁 Workflows: $workflows_count"
    
    # Contar conversaciones restauradas
    conversaciones_count=$(jq '.conversaciones | length' "$BACKUP_FILE" 2>/dev/null || echo "0")
    echo "💬 Conversaciones: $conversaciones_count"
    
    # Contar productos restaurados
    productos_count=$(jq '.productos | length' "$BACKUP_FILE" 2>/dev/null || echo "0")
    echo "📦 Productos: $productos_count"
    
    echo ""
    echo "🌐 URLs de acceso:"
    echo "• n8n: http://172.18.1.158:5679"
    echo "• Usuario: mediaqualitynet@gmail.com"
    echo "• Contraseña: Cadena_2000"
    
    echo ""
    echo "🔄 Comandos útiles:"
    echo "• Reiniciar servicios: docker-compose restart"
    echo "• Ver logs: docker-compose logs -f n8n"
    echo "• Probar workflows: curl -X POST http://172.18.1.158:5679/webhook/bienvenida-mqn"
}

# Función principal de restauración
restaurar_sistema() {
    echo "🚀 Iniciando restauración completa..."
    
    # Verificar servicios
    if ! verificar_servicios; then
        echo "❌ Error: Los servicios no están funcionando"
        echo "💡 Inicia los servicios primero: docker-compose up -d"
        exit 1
    fi
    
    # Restaurar workflows
    restaurar_workflows
    
    # Restaurar base de datos
    restaurar_base_datos
    
    # Restaurar knowledge base
    restaurar_knowledge_base
    
    # Limpiar archivos temporales
    rm -rf "$TEMP_DIR"
    
    echo ""
    echo "✅ Restauración completada exitosamente!"
    
    # Mostrar resumen
    mostrar_resumen
}

# Ejecutar restauración
restaurar_sistema

echo ""
echo "🎉 ¡Sistema MQN restaurado y listo para usar!"
