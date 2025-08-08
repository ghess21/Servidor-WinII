#!/bin/bash
echo "🔧 Asistente avanzado — Configuración modular" | tee -a logs/interactive_trace.log

ENV_FILE=".env"

# 🚧 Check y regeneración de .env si falta
if [[ ! -f "$ENV_FILE" ]]; then
  echo "⚙️ Generando archivo .env básico" | tee -a logs/interactive_trace.log
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
  echo "✅ Archivo .env creado exitosamente"
fi

# 🔍 Validación de dependencias
for cmd in gomplate docker; do
  if ! command -v $cmd &> /dev/null; then
    echo "❌ Falta $cmd. ¿Instalar automáticamente? (s/n)" | tee -a logs/interactive_trace.log
    read input
    [[ "$input" == "s" ]] && bash scripts/install_$cmd.sh
  fi
done

# ⚙️ Activar servicios
echo "¿Activar Redis? (s/n)"; read redis
echo "ENABLE_REDIS=$([[ "$redis" == "s" ]] && echo true || echo false)" >> "$ENV_FILE"
echo "✔️ Redis: $redis" >> logs/interactive_trace.log

# 🔢 Puertos y validación
read -p "Puerto para Redis: " redis_port
while lsof -i:"$redis_port" &> /dev/null; do
  echo "🚫 Puerto $redis_port ocupado. Ingrese otro:"
  read redis_port
done
echo "REDIS_PORT=$redis_port" >> "$ENV_FILE"
echo "🔌 Redis port seleccionado: $redis_port" >> logs/interactive_trace.log

# 📡 Validación del entorno
bash scripts/validate.sh | tee -a logs/interactive_trace.log || {
  echo "🛑 Validación fallida. Abortando." | tee -a logs/interactive_trace.log
  exit 1
}

# 🧱 Renderización
bash scripts/render_compose.sh | tee -a logs/interactive_trace.log || {
  echo "❌ Error en renderización." | tee -a logs/interactive_trace.log
  exit 1
}
