#!/bin/bash
# ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
# ┃       INIT - WinII Bootstrap CLI      ┃
# ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

WORKDIR="$(pwd)"
LOG="$WORKDIR/logs/init.log"
STATE="$WORKDIR/logs/asistente.state.json"
HIST="$WORKDIR/logs/asistente.history.md"

mkdir -p "$(dirname "$LOG")"
echo "[INIT] Inicio - $(date '+%Y-%m-%d %H:%M:%S')" | tee -a "$LOG"

##############################
# 🤖 Asistente persistente
##############################
bash "$WORKDIR/scripts/assistant.sh" --resume | tee -a "$LOG"

##############################
# 🔐 Corrección de permisos
##############################
bash "$WORKDIR/scripts/fix_permissions.sh" | tee -a "$LOG"

##############################
# 🧪 Inventario preflight
##############################
bash "$WORKDIR/scripts/preflight_inventory.sh" | tee -a "$LOG"

##############################
# 🧑‍💻 Configuración interactiva
##############################
bash "$WORKDIR/scripts/setup_interactivo.sh" | tee -a "$LOG"

##############################
# 🧪 Validación final
##############################
bash "$WORKDIR/scripts/validate.sh" | tee -a "$LOG" || {
  echo "[INIT] ❌ Validación fallida. Abortando." | tee -a "$LOG"
  bash "$WORKDIR/scripts/assistant.sh" --audit-mode | tee -a "$LOG"
  exit 1
}

##############################
# 🧱 Render del stack
##############################
bash "$WORKDIR/scripts/render_compose.sh" | tee -a "$LOG"

##############################
# 🛠️ Instalación del stack
##############################
bash "$WORKDIR/scripts/install_stack.sh" | tee -a "$LOG"

##############################
# 📊 Estado final
##############################
echo "[INIT] Estado de contenedores:" | tee -a "$LOG"
docker ps --format "table {{.Names}}\t{{.Status}}" | tee -a "$LOG"

##############################
# 🧠 Registro en asistente
##############################
echo "{ \"fecha\": \"$(date '+%Y-%m-%d %H:%M:%S')\", \"fase\": \"init.sh\", \"resultado\": \"completo\" }" > "$STATE"
echo "- [$(date '+%Y-%m-%d %H:%M:%S')] Ejecución completada exitosamente" >> "$HIST"
