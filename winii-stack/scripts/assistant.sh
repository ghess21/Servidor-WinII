#!/bin/bash

# ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
# ┃ 🧠 ASISTENTE INTERACTIVO DE SETUP   ┃
# ┃ Autor: Guillermo                    ┃
# ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛

ENV_FILE="$WORKDIR/.env"
if [ -f "$ENV_FILE" ]; then
  export $(grep -v '^#' "$ENV_FILE" | xargs)
  echo "[ASSISTANT] Variables de entorno cargadas desde .env" >> "$LOG_FILE"
fi



WORKDIR="$(pwd)"
CHANGELOG_FILE="$WORKDIR/CHANGELOG.md"
LOG_FILE="$WORKDIR/logs/activity.log"
mkdir -p "$WORKDIR/logs"
[ ! -f "$LOG_FILE" ] && touch "$LOG_FILE"

source "$WORKDIR/scripts/log_action.sh"
clear

echo "🛠️ Bienvenido al asistente de configuración"
echo "🔍 Preparando entorno inicial..."

# ──────────────────────────────────────────
# 🔐 Activar permisos en scripts esenciales
# ──────────────────────────────────────────
bash scripts/fix_permissions.sh

# ──────────────────────────────────────────
# 🧪 Validación del entorno con inventario
# ──────────────────────────────────────────
bash scripts/preflight_inventory.sh

# ──────────────────────────────────────────
# 🎛️ Selección de flujo principal
# ──────────────────────────────────────────
echo ""
echo "🧭 ¿Qué deseas hacer?"
echo "1) Configurar servicios (setup_services.sh)"
echo "2) Ejecutar validaciones (validate.sh)"
echo "3) Renderizar docker-compose (render_compose.sh)"
echo "4) Instalar stack completo (install_stack.sh)"
echo "5) Configurar vía flujo interactivo (setup_interactivo.sh)"
echo "6) Crear archivo .env (create_env.sh)"
echo "7) 🚀 Instalación avanzada con monitoreo (install_stack_advanced.sh)"
echo "8) 📊 Monitoreo del stack (monitor_stack.sh)"
echo "9) 📈 Monitoreo de recursos (monitor_resources.sh)"
echo "10) 🧪 Probar conectividad SMB (test_smb_connection.sh)"
echo "11) 🔧 Configurar backup automático SMB (setup_backup_cron.sh)"
echo "12) 💾 Backup manual a SMB (backup_smb_diario.sh)"
echo "13) 🎛️ Gestor unificado de backups (gestor_backups_unificado.sh)"
echo "0) Salir"

read -p "📝 Selecciona una opción [0-13]: " opcion

case "$opcion" in
  1) bash scripts/setup_services.sh ;;
  2) bash scripts/validate.sh ;;
  3) bash scripts/render_compose.sh ;;
  4) bash scripts/install_stack.sh ;;
  5) bash scripts/setup_interactivo.sh ;;
  6) bash scripts/create_env.sh ;;
  7) bash scripts/install_stack_advanced.sh ;;
  8) bash scripts/monitor_stack.sh ;;
  9) bash scripts/monitor_resources.sh ;;
  10) bash scripts/test_smb_connection.sh ;;
  11) bash scripts/setup_backup_cron.sh ;;
  12) bash scripts/backup_smb_diario.sh ;;
  13) bash scripts/gestor_backups_unificado.sh ;;
  0) echo "👋 Saliendo del asistente. ¡Hasta pronto!" ;;
  *) echo "❌ Opción inválida. Intenta nuevamente." ;;
esac
