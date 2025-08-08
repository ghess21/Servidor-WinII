#!/bin/bash
# scripts/env.sh — Cargador y validador del entorno

ENV_FILE=".env"
LOG_FILE="logs/env_trace.log"

mkdir -p "$(dirname "$LOG_FILE")"
echo "📦 Cargando entorno desde $ENV_FILE — $(date '+%Y-%m-%d %H:%M:%S')" > "$LOG_FILE"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "❌ Archivo .env no encontrado"
  exit 1
fi

# Exportar todas las variables definidas en .env
set -a
source "$ENV_FILE"
set +a

# Validar claves mínimas
REQUIRED_VARS=("ENABLE_REDIS" "REDIS_PORT" "ENABLE_POSTGRES" "POSTGRES_PORT" "ENABLE_N8N" "N8N_PORT")
for var in "${REQUIRED_VARS[@]}"; do
  value="${!var}"
  if [[ -z "$value" ]]; then
    echo "❌ Variable obligatoria no definida: $var" | tee -a "$LOG_FILE"
    exit 1
  fi
  echo "✔️ $var=$value" >> "$LOG_FILE"
done

# Validación semántica
BOOL_VARS=("ENABLE_REDIS" "ENABLE_POSTGRES" "ENABLE_N8N")
for var in "${BOOL_VARS[@]}"; do
  value="${!var}"
  if [[ "$value" != "true" && "$value" != "false" ]]; then
    echo "❌ $var debe ser 'true' o 'false'. Valor actual: '$value'" | tee -a "$LOG_FILE"
    exit 1
  fi
done

PORT_VARS=("REDIS_PORT" "POSTGRES_PORT" "N8N_PORT")
for var in "${PORT_VARS[@]}"; do
  value="${!var}"
  if ! [[ "$value" =~ ^[0-9]{4,5}$ ]] || (( value < 1024 || value > 65535 )); then
    echo "❌ $var fuera de rango válido (1024–65535). Valor: '$value'" | tee -a "$LOG_FILE"
    exit 1
  fi
done

echo "✅ Entorno cargado y validado correctamente" | tee -a "$LOG_FILE"
