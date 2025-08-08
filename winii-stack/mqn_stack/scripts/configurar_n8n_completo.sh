#!/bin/bash
# ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
# ┃       CONFIGURAR N8N COMPLETO MQN    ┃
# ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

echo "🔧 Configurando n8n completo para Media Quality Net..."
echo "====================================================="

# Verificar que los servicios estén funcionando
echo "🔍 Verificando servicios..."

if ! docker-compose ps | grep -q "Up"; then
    echo "❌ Error: Los servicios no están funcionando"
    echo "💡 Inicia los servicios: docker-compose up -d"
    exit 1
fi

echo "✅ Servicios funcionando"

# Crear directorios necesarios
mkdir -p backups
mkdir -p logs
mkdir -p config

echo "📁 Directorios creados"

# Configurar n8n con variables de entorno
echo "🔧 Configurando n8n..."

# Detener n8n para aplicar nueva configuración
docker-compose stop n8n

# Crear archivo de configuración de n8n
cat > docker-compose.yml << 'EOF'
version: '3.8'
services:
  # Base de datos
  postgres:
    image: postgres:16
    environment:
      POSTGRES_DB: mqn_db
      POSTGRES_USER: mqn_user
      POSTGRES_PASSWORD: mqn_password
    ports:
      - "5433:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
      - ./config/database.sql:/docker-entrypoint-initdb.d/init.sql
  # Cache y broker
  redis:
    image: redis:7-alpine
    ports:
      - "6380:6379"
    volumes:
      - redis_data:/data
  # n8n para automatización
  n8n:
    image: n8nio/n8n:latest
    ports:
      - "5679:5678"
    environment:
      DB_TYPE: postgresdb
      DB_POSTGRESDB_HOST: postgres
      DB_POSTGRESDB_PORT: 5432
      DB_POSTGRESDB_DATABASE: mqn_db
      DB_POSTGRESDB_USER: mqn_user
      DB_POSTGRESDB_PASSWORD: mqn_password
      N8N_BASIC_AUTH_ACTIVE: true
      N8N_BASIC_AUTH_USER: mediaqualitynet@gmail.com
      N8N_BASIC_AUTH_PASSWORD: Cadena_2000
      N8N_API_KEY: mqn_api_key_2024
      N8N_ENCRYPTION_KEY: mqn_encryption_key_2024
      N8N_USER_MANAGEMENT_DISABLED: false
      N8N_DIAGNOSTICS_ENABLED: false
      N8N_LOG_LEVEL: info
      N8N_LOG_OUTPUT: file
      N8N_LOG_FILE: /home/node/.n8n/logs/n8n.log
      WEBHOOK_URL: http://localhost:5678
      WEBHOOK_TUNNEL_URL: http://localhost:5678
      GENERIC_TIMEZONE: America/Mexico_City
    volumes:
      - n8n_data:/home/node/.n8n
      - ./workflows:/home/node/.n8n/workflows
      - ./logs:/home/node/.n8n/logs
    depends_on:
      - postgres
volumes:
  postgres_data:
  redis_data:
  n8n_data:
EOF

echo "✅ Configuración de n8n actualizada"

# Reiniciar n8n con nueva configuración
echo "🔄 Reiniciando n8n..."
docker-compose up -d n8n

# Esperar a que n8n esté listo
echo "⏳ Esperando que n8n esté listo..."
sleep 30

# Verificar que n8n esté funcionando
if ! curl -s http://localhost:5679 > /dev/null; then
    echo "❌ Error: n8n no está funcionando después del reinicio"
    echo "💡 Verificando logs..."
    docker-compose logs n8n
    exit 1
fi

echo "✅ n8n funcionando correctamente"

# Crear script de importación manual
cat > importar_manual.md << 'EOF'
# 📁 Importación Manual de Workflows

## 🎯 Pasos para importar workflows:

1. **Acceder a n8n:**
   - URL: http://172.18.1.158:5679
   - Usuario: mediaqualitynet@gmail.com
   - Contraseña: Cadena_2000

2. **Importar workflows uno por uno:**
   - Ir a "Workflows" en el menú lateral
   - Hacer clic en "Import from file"
   - Seleccionar cada archivo de la carpeta `workflows/`

3. **Workflows a importar:**
   - `bienvenida-mqn.json` - Workflow de bienvenida
   - `whatsapp-handler.json` - Manejo de mensajes WhatsApp
   - `catalogador-visual.json` - Procesamiento de imágenes
   - `backup-seguridad-n8n.json` - Sistema de respaldo

4. **Activar workflows:**
   - Después de importar, hacer clic en "Activate" en cada workflow
   - Verificar que los webhooks estén funcionando

5. **Probar workflows:**
   ```bash
   # Probar bienvenida
   curl -X POST http://172.18.1.158:5679/webhook/bienvenida-mqn
   
   # Probar WhatsApp handler
   curl -X POST http://172.18.1.158:5679/webhook/whatsapp-handler
   
   # Probar catalogador
   curl -X POST http://172.18.1.158:5679/webhook/catalogador-visual
   ```

## 🔧 Configuración de seguridad:

- **API Key:** mqn_api_key_2024
- **Encryption Key:** mqn_encryption_key_2024
- **Backup automático:** Cada 6 horas
- **Notificaciones:** Por WhatsApp al 9671262441

## 📊 Verificar sistema:

```bash
./scripts/verificar_integridad.sh
./scripts/monitor_sistema.sh
```

EOF

echo "✅ Documentación de importación creada"

# Crear script de prueba rápida
cat > scripts/probar_sistema.sh << 'EOF'
#!/bin/bash
echo "🧪 Probando sistema MQN..."

echo "🔍 Verificando n8n..."
if curl -s http://localhost:5679 > /dev/null; then
    echo "✅ n8n funcionando"
else
    echo "❌ n8n no está funcionando"
    exit 1
fi

echo "🔍 Verificando base de datos..."
if docker-compose exec postgres pg_isready -U mqn_user > /dev/null 2>&1; then
    echo "✅ PostgreSQL funcionando"
else
    echo "❌ PostgreSQL no está funcionando"
fi

echo "🔍 Verificando workflows..."
workflows_count=$(curl -s -X GET "http://localhost:5679/api/v1/workflows" \
  -H "X-N8N-API-KEY: mqn_api_key_2024" | jq '.data | length' 2>/dev/null || echo "0")
echo "📊 Workflows activos: $workflows_count"

echo ""
echo "🎯 Sistema listo para usar!"
echo "🌐 Acceder: http://172.18.1.158:5679"
echo "👤 Usuario: mediaqualitynet@gmail.com"
echo "🔑 Contraseña: Cadena_2000"
EOF

chmod +x scripts/probar_sistema.sh

echo ""
echo "✅ Configuración completa finalizada!"
echo ""
echo "📋 Próximos pasos:"
echo "1. Importar workflows manualmente desde n8n"
echo "2. Activar los workflows importados"
echo "3. Probar el sistema con: ./scripts/probar_sistema.sh"
echo ""
echo "📚 Documentación:"
echo "• importar_manual.md - Guía de importación"
echo "• docs/SEGURIDAD.md - Guía de seguridad"
echo ""
echo "🎯 ¡n8n configurado y listo para Media Quality Net!"
