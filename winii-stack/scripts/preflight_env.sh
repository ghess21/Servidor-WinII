ENV_FILE="$WORKDIR/.env"
touch "$ENV_FILE"

require_env() {
  VAR_NAME=$1
  PROMPT=$2

  if [ -z "${!VAR_NAME}" ]; then
    read -p "$PROMPT: " VALUE
    export "$VAR_NAME"="$VALUE"
    echo "$VAR_NAME=$VALUE" >> "$ENV_FILE"
    echo "[ENV] $VAR_NAME seteado como '$VALUE'" >> "$LOG_FILE"
  else
    echo "$VAR_NAME=${!VAR_NAME}" >> "$ENV_FILE"
    echo "[ENV] $VAR_NAME ya está definido como '${!VAR_NAME}'" >> "$LOG_FILE"
  fi
}
