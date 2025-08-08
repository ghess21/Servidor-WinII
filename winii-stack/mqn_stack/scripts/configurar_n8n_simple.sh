#!/bin/bash
echo "🔧 Configurando n8n simple para MQN..."

# Detener n8n
docker-compose stop n8n

# Crear configuración simple
cat > docker-compose.yml << 'EOF'
services:
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
  redis:
    image: redis:7-alpine
    ports:
      - "6380:6379"
    volumes:
      - redis_data:/data
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
      GENERIC_TIMEZONE: America/Mexico_City
    volumes:
      - n8n_data:/home/node/.n8n
      - ./workflows:/home/node/.n8n/workflows
    depends_on:
      - postgres
volumes:
  postgres_data:
  redis_data:
  n8n_data:
EOF

echo "✅ Configuración actualizada"

# Iniciar n8n
echo "🔄 Iniciando n8n..."
docker-compose up -d n8n

# Esperar
echo "⏳ Esperando que n8n esté listo..."
sleep 30

# Verificar
if curl -s http://localhost:5679 > /dev/null; then
    echo "✅ n8n funcionando correctamente"
    echo ""
    echo "🌐 Acceder a n8n:"
    echo "• URL: http://172.18.1.158:5679"
    echo "• Usuario: mediaqualitynet@gmail.com"
    echo "• Contraseña: Cadena_2000"
    echo ""
    echo "📁 Para importar workflows:"
    echo "1. Ir a n8n"
    echo "2. Workflows > Import from file"
    echo "3. Seleccionar archivos de la carpeta workflows/"
    echo ""
    echo "🎯 ¡n8n listo para usar!"
else
    echo "❌ n8n no está funcionando"
    echo "💡 Verificando logs..."
    docker-compose logs n8n
fi
