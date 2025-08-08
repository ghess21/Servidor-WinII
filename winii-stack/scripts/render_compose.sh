#!/bin/bash
source scripts/env.sh

echo "[RENDER] Generando docker-compose.yml desde plantilla..."

TPL_PATH="templates/docker-compose.yml.tpl"
OUT_PATH="docker-compose.yml"
BACKUP_PATH="docker-compose.yml.bak"

# Validación de existencia
if [[ ! -f "$TPL_PATH" ]]; then
  echo "❌ Plantilla no encontrada: $TPL_PATH"
  exit 1
fi

# Backup previo si ya existe
if [[ -f "$OUT_PATH" ]]; then
  cp "$OUT_PATH" "$BACKUP_PATH"
  echo "📦 Backup creado: $BACKUP_PATH"
fi

if ! command -v gomplate &> /dev/null; then
  echo "❌ 'gomplate' no está instalado. Abortando renderización."
  exit 1
fi


# Renderización
gomplate -f "$TPL_PATH" -o "$OUT_PATH"
status=$?
if [[ $status -eq 0 ]]; then
  echo "✅ Compose generado exitosamente: $OUT_PATH"
else
  echo "❌ Error en gomplate (code: $status)"
  exit 1
fi

