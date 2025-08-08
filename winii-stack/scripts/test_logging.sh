#!/bin/bash
export WORKDIR="$(pwd)"
source "$WORKDIR/scripts/log_action.sh"

echo "🧪 Ejecutando pruebas de log_action..."

log_action INFO "Prueba de nivel INFO"
log_action ERROR "Prueba de nivel ERROR"
log_action DEBUG "Prueba de nivel DEBUG"

log_action
log_action "" "Mensaje sin nivel"
log_action DEBUG

rm -rf "$WORKDIR/logs"
log_action INFO "Recreación automática del directorio"

PORT=8080
log_action DEBUG "Puerto asignado: $PORT"

log_action INFO "Prueba desde script externo"

echo "✅ Pruebas completadas. Verifica logs/actions.log"
