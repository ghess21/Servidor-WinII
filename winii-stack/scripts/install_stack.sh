#!/bin/bash
LOG_FILE="logs/install.log"
echo "[INSTALL] Iniciando instalación del stack..." >> "$LOG_FILE"

# 🧪 Validación
bash scripts/validate.sh >> "$LOG_FILE"
VALIDATE_STATUS=$?

if [ $VALIDATE_STATUS -ne 0 ]; then
  echo "❌ Error en la validación. Abortando instalación." >> "$LOG_FILE"
  exit 1
fi

bash scripts/preflight_env.sh >> "$LOG_FILE"

# 🧱 Renderizado del docker-compose
bash scripts/render_compose.sh >> "$LOG_FILE"
RENDER_STATUS=$?

if [ $RENDER_STATUS -ne 0 ]; then
  echo "❌ Error en render_compose. Abortando instalación." >> "$LOG_FILE"
  exit 1
fi

# 🚀 Despliegue con Docker Compose
echo "[INSTALL] Deploy con Docker Compose..." >> "$LOG_FILE"
docker-compose up -d >> "$LOG_FILE"
DOCKER_STATUS=$?

if [ $DOCKER_STATUS -ne 0 ]; then
  echo "❌ Fallo en docker compose. Revisar configuración." >> "$LOG_FILE"
  exit 1
fi

echo "[INSTALL] Stack instalado correctamente 🟢" >> "$LOG_FILE"

# ⏳ Espera antes de invocar el asistente si todo salió bien
echo "[INSTALL] Esperando 30 segundos antes de iniciar assistant..." >> "$LOG_FILE"
sleep 30

# 🧠 Invocar el asistente
bash scripts/assistant.sh >> "$LOG_FILE"
