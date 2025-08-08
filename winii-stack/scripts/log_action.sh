#!/usr/bin/env bash
set -euo pipefail

# ┌────────────────────────────────────────────┐
# │ Detect WORKDIR dynamically (project root)  │
# └────────────────────────────────────────────┘
WORKDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# ┌────────────────────────────────────────────┐
# │ Load environment defaults if available     │
# └────────────────────────────────────────────┘
ENV_FILE="$WORKDIR/.env"
if [[ -f "$ENV_FILE" ]]; then
  source "$ENV_FILE"
else
  echo "[WARN] $(date '+%Y-%m-%d %H:%M:%S') - Environment file not found: $ENV_FILE"
fi

# ┌────────────────────────────────────────────┐
# │ Logging function with timestamp            │
# └────────────────────────────────────────────┘
log_action() {
  local action="$1"
  local logfile="$WORKDIR/logs/actions.log"
  local timestamp
  timestamp="$(date '+%Y-%m-%d %H:%M:%S')"

  echo "[$timestamp] $action" >> "$logfile"
  echo "[INFO] $action logged to $logfile"
}

# ┌────────────────────────────────────────────┐
# │ Example usage (can be removed if sourced)  │
# └────────────────────────────────────────────┘
# log_action "Servicio iniciado por usuario $(whoami)"

