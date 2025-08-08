#!/bin/bash
# Script para crear el archivo .env automáticamente

ENV_FILE=".env"

echo "🔧 Creando archivo .env..."

if [[ -f "$ENV_FILE" ]]; then
  echo "⚠️ El archivo .env ya existe. ¿Deseas sobrescribirlo? (s/n)"
  read -r response
  if [[ "$response" != "s" ]]; then
    echo "❌ Operación cancelada"
    exit 0
  fi
fi

cat > "$ENV_FILE" << EOF
# WinII Stack Environment Configuration
# Generated automatically - Do not edit manually

# Redis Configuration
ENABLE_REDIS=true
REDIS_PORT=6379

# PostgreSQL Configuration
ENABLE_POSTGRES=true
POSTGRES_PORT=5432

# N8N Configuration
ENABLE_N8N=true
N8N_PORT=5678

# Logging Configuration
LOG_LEVEL=INFO
LOG_FILE=logs/activity.log
EOF

echo "✅ Archivo .env creado exitosamente en $(pwd)/$ENV_FILE"
echo "📝 Variables configuradas:"
echo "   - ENABLE_REDIS=true"
echo "   - REDIS_PORT=6379"
echo "   - ENABLE_POSTGRES=true"
echo "   - POSTGRES_PORT=5432"
echo "   - ENABLE_N8N=true"
echo "   - N8N_PORT=5678"
